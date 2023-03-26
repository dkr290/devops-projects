```
curl -s https://falco.org/repo/falcosecurity-packages.asc | apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
apt-get update -y
apt-get install -y falco


```

HELM 


```
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
Installing the Chart
To install the chart with the release name falco in namespace falco run:

helm install falco falcosecurity/falco --namespace falco --create-namespace
After a few minutes Falco instances should be running on all your nodes. The status of Falco pods can be inspected through kubectl:

kubectl get pods -n falco -o wide


build dependencies if install failed

apt install -y dkms make linux-headers-$(uname -r)
# If you use the falco-driver-loader to build the BPF probe locally you need also clang toolchain
apt install -y clang llvm
# You can install also the dialog package if you want it
apt install -y dialog


## upgrade with custom rules and fast logs in the stdout

helm upgrade  falco falcosecurity/falco -f falco-values.yaml  --set tty=true -n falco

```