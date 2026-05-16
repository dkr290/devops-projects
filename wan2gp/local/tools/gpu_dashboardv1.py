#!/usr/bin/env python3
import curses
import time
import pynvml

def color_for_temp(temp):
    if temp < 55:
        return 2
    elif temp < 70:
        return 3
    else:
        return 1

def color_for_util(util):
    if util < 40:
        return 2
    elif util < 80:
        return 3
    else:
        return 1

def main(stdscr):
    curses.curs_set(0)
    curses.start_color()

    curses.init_pair(1, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_YELLOW, curses.COLOR_BLACK)
    curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)
    curses.init_pair(5, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
    curses.init_pair(6, curses.COLOR_WHITE, curses.COLOR_BLACK)

    pynvml.nvmlInit()
    gpu_count = pynvml.nvmlDeviceGetCount()

    while True:
        stdscr.erase()
        stdscr.addstr(0, 2, " NVIDIA GPU TERMINAL DASHBOARD ", curses.color_pair(4) | curses.A_BOLD)
        stdscr.addstr(1, 2, f"Time: {time.strftime('%Y-%m-%d %H:%M:%S')}", curses.color_pair(5))

        row = 3

        for i in range(gpu_count):
            h = pynvml.nvmlDeviceGetHandleByIndex(i)
            name = pynvml.nvmlDeviceGetName(h).decode()
            temp = pynvml.nvmlDeviceGetTemperature(h, 0)
            fan = pynvml.nvmlDeviceGetFanSpeed(h)
            power = pynvml.nvmlDeviceGetPowerUsage(h) / 1000
            power_limit = pynvml.nvmlDeviceGetPowerManagementLimit(h) / 1000
            util = pynvml.nvmlDeviceGetUtilizationRates(h).gpu
            mem = pynvml.nvmlDeviceGetMemoryInfo(h)
            clock = pynvml.nvmlDeviceGetClockInfo(h, pynvml.NVML_CLOCK_GRAPHICS)
            memclock = pynvml.nvmlDeviceGetClockInfo(h, pynvml.NVML_CLOCK_MEM)

            stdscr.addstr(row, 2, f"GPU {i}: {name}", curses.color_pair(4) | curses.A_BOLD)
            row += 1

            stdscr.addstr(row, 4, "Temp: ")
            stdscr.addstr(f"{temp}°C", curses.color_pair(color_for_temp(temp)))
            row += 1

            stdscr.addstr(row, 4, "Fan:  ")
            stdscr.addstr(f"{fan}%", curses.color_pair(3))
            row += 1

            stdscr.addstr(row, 4, "Power: ")
            pct = int((power / power_limit) * 100)
            stdscr.addstr(f"{power:.1f}W / {power_limit:.1f}W", curses.color_pair(color_for_util(pct)))
            row += 1

            stdscr.addstr(row, 4, "GPU Clock: ")
            stdscr.addstr(f"{clock} MHz", curses.color_pair(2))
            row += 1

            stdscr.addstr(row, 4, "VRAM Clock: ")
            stdscr.addstr(f"{memclock} MHz", curses.color_pair(2))
            row += 1

            stdscr.addstr(row, 4, "Utilization: ")
            stdscr.addstr(f"{util}%", curses.color_pair(color_for_util(util)))
            row += 1

            stdscr.addstr(row, 4, "VRAM: ")
            stdscr.addstr(f"{mem.used // 1024**2} MiB / {mem.total // 1024**2} MiB", curses.color_pair(5))
            row += 2

            # PROCESS LIST
            stdscr.addstr(row, 2, "Active GPU Processes:", curses.color_pair(6) | curses.A_BOLD)
            row += 1

            try:
                procs = pynvml.nvmlDeviceGetComputeRunningProcesses(h)
            except pynvml.NVMLError:
                procs = []

            procs = sorted(procs, key=lambda p: p.usedGpuMemory, reverse=True)

            if not procs:
                stdscr.addstr(row, 4, "No active GPU processes", curses.color_pair(3))
                row += 2
            else:
                stdscr.addstr(row, 4, "PID      VRAM(MB)   Process", curses.color_pair(5))
                row += 1

                for p in procs:
                    pid = p.pid
                    used = p.usedGpuMemory // 1024**2

                    try:
                        with open(f"/proc/{pid}/comm") as f:
                            pname = f.read().strip()
                    except:
                        pname = "unknown"

                    stdscr.addstr(row, 4, f"{pid:<8} {used:<10} {pname}", curses.color_pair(6))
                    row += 1

            row += 1

        stdscr.refresh()
        time.sleep(1)

curses.wrapper(main)

