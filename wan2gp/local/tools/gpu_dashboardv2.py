#!/usr/bin/env python3
"""
NVIDIA GPU Monitor — RTX 3090 focused
Tracks VRAM clock drops as indirect VRAM temperature signal.
Press h to toggle the danger reference panel.
"""
import curses
import time
import collections
try:
    import pynvml
except ImportError:
    import nvidia_ml_py as pynvml

# ── RTX 3090 danger reference thresholds ────────────────────────────────────
DANGER_REF = [
    # (metric, warn_val, danger_val, unit, note)
    ("GPU Temp",        75,  83, "°C", "VRAM likely >95°C when GPU hits 83°C"),
    ("VRAM Temp",       90, 100, "°C", "GDDR6X throttles ~110°C, degrades above 95°C"),
    ("VRAM Clock drop", 10,  20,  "%", "Drop from 9501 MHz baseline = VRAM overheating"),
    ("GFX Clock drop",  10,  20,  "%", "Sudden drop mid-workload = thermal/power throttle"),
    ("Power %",         85,  95,  "%", "Sustained 95%+ of TDP = VRM heat risk"),
    ("Fan speed",       85,  95,  "%", "95%+ = card is struggling to cool"),
    ("Perf State",       2,   4,  "P#","P0=full speed. P4+ = active throttling"),
]

RTX3090_VRAM_BASELINE = 9501   # MHz — GDDR6X full speed
VRAM_MIN_VALID = 5000
HISTORY_LEN = 60               # samples kept for sparkline / drop calc

def bar(val, total, width=20):
    if not total or total <= 0:
        return "░" * width
    filled = int(width * min(val, total) / total)
    return "█" * filled + "░" * (width - filled)

def color_temp(t):
    return 2 if t < 55 else (3 if t < 75 else 1)

def color_pct(p):
    return 2 if p < 50 else (3 if p < 80 else 1)

def color_drop(d):
    return 2 if d < 10 else (3 if d < 20 else 1)

def is_under_load(util_gpu, clk_gfx, clk_mem):
    # GPU is considered under load if:
    # - GPU util > 30% OR
    # - GFX clock > 1000 MHz OR
    # - VRAM clock > 5000 MHz
    return util_gpu > 30 or clk_gfx > 1000 or clk_mem > 5000



def safe(fn, *args, default="N/A"):
    try:
        return fn(*args)
    except Exception:
        return default
def get_sys_stats():
    """Read CPU and RAM usage from /proc without extra dependencies."""
    # CPU — compare two /proc/stat snapshots
    def read_cpu():
        with open("/proc/stat") as f:
            line = f.readline()
        fields = list(map(int, line.split()[1:]))
        idle = fields[3]
        total = sum(fields)
        return idle, total

    idle1, total1 = read_cpu()
    time.sleep(0.1)
    idle2, total2 = read_cpu()
    cpu_pct = int(100 * (1 - (idle2 - idle1) / (total2 - total1)))

    # RAM — /proc/meminfo
    mem = {}
    with open("/proc/meminfo") as f:
        for line in f:
            k, v = line.split()[0].rstrip(":"), int(line.split()[1])
            mem[k] = v
    mem_total = mem["MemTotal"] // 1024
    mem_free  = (mem["MemFree"] + mem.get("Buffers", 0) + mem.get("Cached", 0)) // 1024
    mem_used  = mem_total - mem_free

    return cpu_pct, mem_used, mem_total

def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    for i, (fg, bg) in enumerate([
        (curses.COLOR_RED,     -1),   # 1 danger
        (curses.COLOR_GREEN,   -1),   # 2 ok
        (curses.COLOR_YELLOW,  -1),   # 3 warn
        (curses.COLOR_CYAN,    -1),   # 4 header
        (curses.COLOR_MAGENTA, -1),   # 5 accent
        (curses.COLOR_WHITE,   -1),   # 6 normal
        (curses.COLOR_BLUE,    -1),   # 7 info
    ], start=1):
        curses.init_pair(i, fg, bg)

    C = lambda n: curses.color_pair(n)
    RED, GREEN, YELLOW, CYAN, MAGENTA, WHITE, BLUE = [C(n) for n in range(1, 8)]
    BOLD, DIM = curses.A_BOLD, curses.A_DIM

    pynvml.nvmlInit()
    driver    = pynvml.nvmlSystemGetDriverVersion()
    nvml_ver  = pynvml.nvmlSystemGetNVMLVersion()
    gpu_count = pynvml.nvmlDeviceGetCount()

    vram_hist     = [collections.deque(maxlen=HISTORY_LEN) for _ in range(gpu_count)]
    gfx_hist      = [collections.deque(maxlen=HISTORY_LEN) for _ in range(gpu_count)]
    vram_baseline = [None] * gpu_count
    gfx_baseline  = [None] * gpu_count
    show_ref      = False

    def w(y, x, txt, attr=0):
        sh, sw = stdscr.getmaxyx()
        if y < sh - 1 and x < sw:
            try:
                stdscr.addstr(y, x, str(txt)[:sw - x], attr)
            except curses.error:
                pass

    def sparkline(history, baseline, width=30):
        h = list(history)[-width:]
        if len(h) < 2 or not baseline:
            return ""
        chars = " ▁▂▃▄▅▆▇█"
        out = ""
        for v in h:
            idx = int(v / baseline * (len(chars) - 1))
            out += chars[max(0, min(len(chars) - 1, idx))]
        return out

    def ref_panel(row):
        w(row, 2, "─" * 80, DIM); row += 1
        w(row, 2, "  RTX 3090 DANGER REFERENCE  (h to hide)", CYAN | BOLD); row += 1
        w(row, 2, f"  {'METRIC':<22} {'WARN':>8}  {'DANGER':>9}   NOTE", MAGENTA); row += 1
        for metric, warn, danger, unit, note in DANGER_REF:
            w(row, 2,  f"  {metric:<22}", WHITE)
            w(row, 26, f"{warn}{unit}", YELLOW)
            w(row, 36, f"{danger}{unit}", RED | BOLD)
            w(row, 46, f"  {note}", DIM)
            row += 1
        row += 1
        w(row, 2, "  VRAM CLOCK GUIDE:", WHITE | BOLD)
        w(row, 22, "9501 MHz = full speed    <9000 = light throttle    <7000 = heavy throttle", DIM)
        row += 1
        w(row, 2, "  HW Thermal ⚠  /  HW Slowdown ⚠  /  HW Power Brake ⚠  = hardware protecting card", RED)
        row += 1
        w(row, 2, "  VRAM clock sparkline: each char = 1 sample (1s). Dips = throttle events.", DIM)
        return row + 1

    while True:
        stdscr.erase()
        h_scr, w_scr = stdscr.getmaxyx()

        # Header
        w(0, 2, " ▐ NVIDIA GPU DASHBOARD ▌ ", CYAN | BOLD)
        w(0, 30, f"Driver: {driver}   NVML: {nvml_ver}", DIM)
        w(1, 2, f"  {time.strftime('%A %Y-%m-%d  %H:%M:%S')}    GPUs: {gpu_count}", MAGENTA)
        w(2, 2, "─" * min(w_scr - 4, 92), DIM)
       
        row = 3

        # ── System (CPU + RAM) ───────────────────────────────────────────────
        cpu_pct, mem_used, mem_total = get_sys_stats()
        mem_pct = int(mem_used / mem_total * 100) if mem_total else 0
        w(row, 2, "CPU:", WHITE | BOLD)
        w(row, 7,  f"{cpu_pct:3}%  {bar(cpu_pct, 100, 14)}", C(color_pct(cpu_pct)))
        w(row, 30, "RAM:", WHITE | BOLD)
        w(row, 35, f"{mem_used:6} / {mem_total:6} MiB ({mem_pct}%)  {bar(mem_used, mem_total, 14)}",C(color_pct(mem_pct)))
        row += 1
        w(row, 2, "─" * min(w_scr - 4, 92), DIM)
        row += 1


        for i in range(gpu_count):
            hnd = pynvml.nvmlDeviceGetHandleByIndex(i)

            # Identity
            _name   = safe(pynvml.nvmlDeviceGetName, hnd, default="Unknown")
            name    = _name.decode() if isinstance(_name, bytes) else _name
            uuid    = safe(pynvml.nvmlDeviceGetUUID, hnd, default="N/A")
            pci     = safe(pynvml.nvmlDeviceGetPciInfo, hnd)
            pci_str = (pci.busId.decode() if isinstance(pci.busId, bytes) else pci.busId) if pci != "N/A" else "N/A"

            w(row, 2, f"┌─ GPU {i}: {name}", CYAN | BOLD)
            w(row, 14 + len(name), f"  {uuid}", DIM)
            row += 1
            w(row, 4, f"PCI Bus: {pci_str}", DIM)
            row += 1

            # Temperature
            t_gpu = safe(pynvml.nvmlDeviceGetTemperature, hnd,
                         pynvml.NVML_TEMPERATURE_GPU, default=0)
            t_mem = "N/A"
            try:
                t_mem = pynvml.nvmlDeviceGetTemperature(hnd, 1)
            except Exception:
                pass

            w(row, 4, "Temp:  ", WHITE | BOLD)
            w(row, 11, f"GPU {t_gpu}°C {bar(t_gpu, 110, 12)}",
              C(color_temp(t_gpu)) | BOLD)
            if t_mem != "N/A":
                w(row, 42, f"  VRAM {t_mem}°C {bar(t_mem, 110, 12)}",
                  C(color_temp(t_mem)) | BOLD)
            else:
                w(row, 42, "  VRAM N/A → watch VRAM clock drop below", DIM)
            row += 1

            t_slow = safe(pynvml.nvmlDeviceGetTemperatureThreshold, hnd,
                          pynvml.NVML_TEMPERATURE_THRESHOLD_SLOWDOWN)
            t_shut = safe(pynvml.nvmlDeviceGetTemperatureThreshold, hnd,
                          pynvml.NVML_TEMPERATURE_THRESHOLD_SHUTDOWN)
            if t_slow != "N/A":
                w(row, 4, f"Thresholds:  Slowdown {t_slow}°C   Shutdown {t_shut}°C", DIM)
                row += 1


            # ── Clocks ──────────────────────────────────────────────────────
            clk_gfx   = safe(pynvml.nvmlDeviceGetClockInfo, hnd, pynvml.NVML_CLOCK_GRAPHICS, default=0)
            clk_mem   = safe(pynvml.nvmlDeviceGetClockInfo, hnd, pynvml.NVML_CLOCK_MEM,      default=0)
            clk_sm    = safe(pynvml.nvmlDeviceGetClockInfo, hnd, pynvml.NVML_CLOCK_SM,        default=0)
            clk_video = safe(pynvml.nvmlDeviceGetClockInfo, hnd, pynvml.NVML_CLOCK_VIDEO,     default=0)
            clk_max_g = safe(pynvml.nvmlDeviceGetMaxClockInfo, hnd, pynvml.NVML_CLOCK_GRAPHICS, default=1)
            clk_max_m = safe(pynvml.nvmlDeviceGetMaxClockInfo, hnd, pynvml.NVML_CLOCK_MEM,      default=RTX3090_VRAM_BASELINE)

            # Update history + baseline
            if isinstance(clk_mem, int) and clk_mem > 100:
                vram_hist[i].append(clk_mem)
            if isinstance(clk_gfx, int) and clk_gfx > 100:
                gfx_hist[i].append(clk_gfx)

           # if vram_baseline[i] is None and len(vram_hist[i]) >= 5:
           #     vram_baseline[i] = max(vram_hist[i])
            if len(vram_hist[i]) >= 20:
                candidate = max(vram_hist[i])
                if candidate > 5000:  # ignore idle clocks below 5000 MHz
                    vram_baseline[i] = candidate
            #if gfx_baseline[i] is None and len(gfx_hist[i]) >= 5:
            #    gfx_baseline[i] = max(gfx_hist[i])
            if len(gfx_hist[i]) >= 20:
                candidate = max(gfx_hist[i])
                if candidate > 500:
                    gfx_baseline[i] = candidate

            v_base = vram_baseline[i] or (clk_max_m if clk_max_m != "N/A" else RTX3090_VRAM_BASELINE)
            g_base = gfx_baseline[i]  or (clk_max_g if clk_max_g != "N/A" else 1)

            v_drop = max(0, int((1 - clk_mem / v_base) * 100)) if isinstance(clk_mem, int) and v_base > 0 else 0
            g_drop = max(0, int((1 - clk_gfx / g_base) * 100)) if isinstance(clk_gfx, int) and g_base > 0 else 0


            # Utilization
            util = safe(pynvml.nvmlDeviceGetUtilizationRates, hnd)
            gu = util.gpu    if util != "N/A" else 0
            mu = util.memory if util != "N/A" else 0

            under_load = is_under_load(gu, clk_gfx, clk_mem)


            # GFX / SM / Video clocks row
            if not under_load:
                gfx_color = BLUE
            else:
                gfx_color = C(color_drop(g_drop))

            w(row, 4, "Clocks:  ", WHITE | BOLD)
            w(row, 13, f"GFX {clk_gfx}/{clk_max_g} MHz", gfx_color)
            if not under_load:
                w(row, 35, f"▼{g_drop}% idle", BLUE)
            elif g_drop >= 20:
                w(row, 35, f"▼{g_drop}%", RED | BOLD)
            elif g_drop >= 10:
                w(row, 35, f"▼{g_drop}%", YELLOW)

            w(row, 42, f"SM {clk_sm} MHz", GREEN)
            w(row, 56, f"Video {clk_video} MHz", GREEN)
            row += 1

            # ── VRAM CLOCK — dedicated prominent row ─────────────────────────
            if not under_load:
                vram_col = BLUE
            else:
                vram_col = C(color_drop(v_drop))
            w(row, 4, "VRAM Clk:", WHITE | BOLD)
            w(row, 14, f"{clk_mem} MHz", vram_col | BOLD)
            w(row, 24, f"(base {v_base} MHz)  {bar(clk_mem, v_base, 18)}", vram_col)
            if not under_load:
                w(row, 65, f"▼{v_drop}% idle", BLUE)
            elif v_drop >= 20:
                w(row, 65, f"▼{v_drop}% VRAM THROTTLE ⚠", RED | BOLD)
            elif v_drop >= 10:
                w(row, 65, f"▼{v_drop}% warn", YELLOW)
            else:
                w(row, 65, f"▼{v_drop}% OK ✓", GREEN)

            row += 1



            # Sparkline
            spark = sparkline(vram_hist[i], v_base, 40)
            if spark:
                w(row, 4, f"VRAM clk 40s: [", DIM)
                w(row, 19, spark, C(color_drop(v_drop)))
                w(row, 19 + len(spark), "]  low=throttle  high=OK", DIM)
                row += 1

            # Throttle reasons
            try:
                reasons = pynvml.nvmlDeviceGetCurrentClocksThrottleReasons(hnd)
                tmap = {
                    pynvml.nvmlClocksThrottleReasonGpuIdle:                  "Idle",
                    pynvml.nvmlClocksThrottleReasonApplicationsClocksSetting: "App clocks",
                    pynvml.nvmlClocksThrottleReasonSwPowerCap:               "SW Power Cap",
                    pynvml.nvmlClocksThrottleReasonHwSlowdown:               "HW Slowdown ⚠",
                    pynvml.nvmlClocksThrottleReasonSyncBoost:                "Sync Boost",
                    pynvml.nvmlClocksThrottleReasonSwThermalSlowdown:        "SW Thermal",
                    pynvml.nvmlClocksThrottleReasonHwThermalSlowdown:        "HW Thermal ⚠",
                    pynvml.nvmlClocksThrottleReasonHwPowerBrakeSlowdown:     "HW Power Brake ⚠",
                    pynvml.nvmlClocksThrottleReasonDisplayClockSetting:      "Display clocks",
                }
                active = [lbl for mask, lbl in tmap.items() if reasons & mask]
                hw_hot = any("⚠" in a for a in active)
                if active:
                    w(row, 4, f"Throttle: {', '.join(active)}",
                      RED | BOLD if hw_hot else YELLOW)
                else:
                    w(row, 4, "Throttle: none ✓", GREEN)
                row += 1
            except Exception:
                pass

            # Fan
            try:
                fc = pynvml.nvmlDeviceGetNumFans(hnd)
            except Exception:
                fc = 1
            fans = []
            for f in range(fc):
                try:
                    fans.append(pynvml.nvmlDeviceGetFanSpeed_v2(hnd, f))
                except Exception:
                    try:
                        fans.append(pynvml.nvmlDeviceGetFanSpeed(hnd)); break
                    except Exception:
                        pass
            fan_str = "  ".join(f"Fan{j+1} {s}% {bar(s,100,8)}" for j,s in enumerate(fans)) \
                      if fans else "N/A"
            w(row, 4, f"Fans:  {fan_str}", C(color_pct(fans[0] if fans else 0)))
            row += 1

            # Power
            pw_use = safe(pynvml.nvmlDeviceGetPowerUsage, hnd, default=0) / 1000
            pw_lim = safe(pynvml.nvmlDeviceGetPowerManagementLimit, hnd, default=1) / 1000
            pw_def = safe(pynvml.nvmlDeviceGetPowerManagementDefaultLimit, hnd, default=0) / 1000
            pw_pct = int(pw_use / pw_lim * 100) if pw_lim else 0
            w(row, 4, "Power:  ", WHITE | BOLD)
            w(row, 12,
              f"{pw_use:.1f}W / {pw_lim:.1f}W  ({pw_pct}%)  "
              f"{bar(pw_use, pw_lim, 16)}  default: {pw_def:.0f}W",
              C(color_pct(pw_pct)))
            row += 1
            energy = safe(pynvml.nvmlDeviceGetTotalEnergyConsumption, hnd)
            if energy != "N/A":
                w(row, 4, f"Energy since boot: {energy/1000:.1f} kJ", DIM); row += 1

            # Utilization
            util = safe(pynvml.nvmlDeviceGetUtilizationRates, hnd)
            gu = util.gpu    if util != "N/A" else 0
            mu = util.memory if util != "N/A" else 0
            try:
                eu, _ = pynvml.nvmlDeviceGetEncoderUtilization(hnd)
                du, _ = pynvml.nvmlDeviceGetDecoderUtilization(hnd)
                enc_str = f"  ENC {eu}%  DEC {du}%"
            except Exception:
                enc_str = ""
            w(row, 4, "Util:  ", WHITE | BOLD)
            w(row, 11, f"GPU {gu:3}% {bar(gu,100,10)}", C(color_pct(gu)))
            w(row, 34, f"MEM {mu:3}% {bar(mu,100,10)}", C(color_pct(mu)))
            if enc_str:
                w(row, 57, enc_str, DIM)
            row += 1

            # VRAM usage
            mi = safe(pynvml.nvmlDeviceGetMemoryInfo, hnd)
            m_used = mi.used  // 1024**2 if mi != "N/A" else 0
            m_free = mi.free  // 1024**2 if mi != "N/A" else 0
            m_tot  = mi.total // 1024**2 if mi != "N/A" else 1
            m_pct  = int(m_used / m_tot * 100) if m_tot else 0
            bw  = safe(pynvml.nvmlDeviceGetMemoryBusWidth, hnd)
            ecc = safe(pynvml.nvmlDeviceGetTotalEccErrors, hnd,
                       pynvml.NVML_MEMORY_ERROR_TYPE_UNCORRECTED,
                       pynvml.NVML_AGGREGATE_ECC)
            w(row, 4, "VRAM:  ", WHITE | BOLD)
            w(row, 11,
              f"{m_used:6} / {m_tot:6} MiB ({m_pct}%)  "
              f"{bar(m_used, m_tot, 18)}  free: {m_free} MiB",
              C(color_pct(m_pct)))
            row += 1
            extras = []
            if bw != "N/A": extras.append(f"bus: {bw}-bit")
            if ecc not in ("N/A", 0): extras.append(f"ECC uncorrected errors: {ecc} ⚠")
            if extras:
                w(row, 4, "  " + "   ".join(extras), DIM); row += 1

            # PCIe
            try:
                pg=pynvml.nvmlDeviceGetCurrPcieLinkGeneration(hnd)
                pw2=pynvml.nvmlDeviceGetCurrPcieLinkWidth(hnd)
                pmg=pynvml.nvmlDeviceGetMaxPcieLinkGeneration(hnd)
                pmw=pynvml.nvmlDeviceGetMaxPcieLinkWidth(hnd)
                tx=pynvml.nvmlDeviceGetPcieThroughput(hnd,pynvml.NVML_PCIE_UTIL_TX_BYTES)
                rx=pynvml.nvmlDeviceGetPcieThroughput(hnd,pynvml.NVML_PCIE_UTIL_RX_BYTES)
                deg = "  ⚠ DEGRADED" if (pg<pmg or pw2<pmw) else ""
                w(row, 4,
                  f"PCIe:  Gen{pg}x{pw2} (max Gen{pmg}x{pmw})  "
                  f"TX {tx//1024} MB/s  RX {rx//1024} MB/s{deg}",
                  RED if deg else BLUE)
                row += 1
            except Exception:
                pass

            # Perf state
            try:
                ps = pynvml.nvmlDeviceGetPerformanceState(hnd)
                pc = GREEN if ps == 0 else (YELLOW if ps <= 2 else RED)
                w(row, 4, f"Perf State: P{ps}  (P0=max perf  P2=mid  P8=idle  P12=min)", pc)
                row += 1
            except Exception:
                pass

            # Process list
            w(row, 2, "├─ Active GPU Processes:", WHITE | BOLD); row += 1
            try:
                procs = pynvml.nvmlDeviceGetComputeRunningProcesses(hnd)
            except Exception:
                procs = []
            gfx_procs = []
            try:
                gfx_procs = pynvml.nvmlDeviceGetGraphicsRunningProcesses(hnd)
                procs += [p for p in gfx_procs if p.pid not in {x.pid for x in procs}]
            except Exception:
                pass
            procs = sorted(procs, key=lambda p: p.usedGpuMemory, reverse=True)
            gfx_pids = {p.pid for p in gfx_procs}

            if not procs:
                w(row, 4, "  No active GPU processes", DIM); row += 1
            else:
                w(row, 4, f"  {'PID':<8} {'VRAM MiB':<12} {'TYPE':<10} Process", MAGENTA)
                row += 1
                for p in procs:
                    pid  = p.pid
                    used = p.usedGpuMemory // 1024**2
                    try:
                        pname = open(f"/proc/{pid}/comm").read().strip()
                        cmd   = open(f"/proc/{pid}/cmdline").read()\
                                    .replace('\x00',' ').strip()[:40]
                    except Exception:
                        pname, cmd = "unknown", ""
                    ptype = "GFX" if pid in gfx_pids else "COMPUTE"
                    w(row, 4, f"  {pid:<8} {used:<12} {ptype:<10} {pname}", WHITE)
                    if cmd and cmd != pname:
                        w(row, 4+2+8+12+10+1+len(pname)+1, f"({cmd})", DIM)
                    row += 1

            row += 1
            w(row, 2, "└" + "─" * min(w_scr - 6, 90), DIM)
            row += 2

        # Reference panel
        if show_ref:
            row = ref_panel(row)

        # Footer
        w(h_scr - 1, 2, " q:quit   h:toggle danger reference panel ", CYAN)

        stdscr.refresh()
        stdscr.timeout(1000)
        key = stdscr.getch()
        if key == ord('q'):
            break
        elif key == ord('h'):
            show_ref = not show_ref

curses.wrapper(main)

