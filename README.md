# k8s yyds

The one click fashion Kubernetes cluster setup playbook. It contains:

- offline artifacts
- containerd runtime
- HA k8s cluster
- cilium/flannel cni plugin depends on your kernel
- local path default storage class
- builtin harbor setup

It's easy to use, lightning fast with just 5m to setup all the stuff.

Pure and latest k8s version you can customizes as you like.

## Verified Environments

The following pre-requirement must be satisfied:

- A `systemd` based os.
- Linux kernel MUST `>= 3.10.0`.
- Ansible 2.11.8 (other ansible 2.5+ version **should work** but not yet been tested, feel free to contact me for anything)

If your OS package manager is not apt or yum, you should install `socat conntrack iptables` on your way.

Verified Linux distros:

- debian 11.1 (fully offline)
- debian 10.2 (require `apt install socat conntrack iptables`)
- debian 9.0 (require `apt install socat conntrack iptables`)
- ubuntu 22.04 LTS (require `apt install socat conntrack iptables`)
- ubuntu 20.04 LTS (require `apt install socat conntrack iptables`)
- ubuntu 18.04.1 LTS (require `apt install socat conntrack iptables`)
- ubuntu 16.04.1 LTS (require `apt install socat conntrack iptables`)
- centOS 8.4 (require `dnf install socat conntrack iptables`)
- centOS 7.2 (require `yum install socat conntrack iptables`)
- tencentOS 3.1 (require `dnf install socat conntrack iptables`)
- tencentOS 2.4 (require `yum install socat conntrack iptables`)

Debian/Ubuntu 2c2g is okay, CentOS/TencentOS require 4g memory, however.

## Usage

### 1: Install underlying package (required if has no network access)

Install `socat conntrack iptables` with your system package manager.

### 2: Inventory (required)

Control plane master nodes must be put on `[masters]` section and `master0` **MUST** be set. It will be final control plane endpoint, i.e., `kubeconfig` server field. For example:

```ini
[masters]
master0 ansible_host=114.132.78.246 # will be the apiserver lb ip
master1 ansible_host=43.139.28.80
# more...
```

Set other nodes name as you like.

The workers nodes must be put on `[workers]` section, the name has no constraint.

If you don't need HA, only set `master0` is totally fine.

Note you **MUST** have all the ssh key login rights.

### 3: Customize k8s (optional)

Change the behaviors of apiserver, etcd, schedule and so on, go to [./k8s/kubeadm-init.yaml] for more.

### 4: Customize containerd runtime (optional)

Go to `./containerd/config.toml` for more if you want to change things like OCI image store location(default to `/var/lib`) and other cri stuff.

### 5: Customize harbor (optional)

Go to `harbor.yaml` to change the default static host and password for your needs, even disable it.

Note if your cni plugin is not cilium but flannel you may use other k8s service type to export harbor endpoint.

Or set the external_url to k8s domain `harbor.harbor.svc.cluster.local`.

Default harbor access url and password are `harbor.k8s.local`, `k8s-yyds`, respectively.

### Final: Run ansible play book

```sh
ansible-playbook -i hosts.ini all.yaml -f 6
```

If everything is OK, the cluster's kube config will be located in `out/kubeconfig.yaml`.

## Open Issues

- openCloudOS 8, no route to host (self public ip...), however localhost access is ok
- If your system already installed docker and containerd, not sure docker will be broken since containerd will be reinstall by us. You can use more lightweight and standard tool like `ctr` or `crictl` to do the same stuff.

## Misc

- `dl.sh` contains all download the artifacts to specific directories.
- `images/` have all the images required oci images (k8s, harbor and others).
- `misc/` put other stuff like debian 11 apt offline packages and k8s yaml manifest.
- `helm/` includes helm binary and some chart tgz files.
- `containerd/` places cri and cni binary and configs.
- `k8s/` consists of k8s binary(kubeadm, kubelet, kubectl) and kubeadm init config jinja2 template.
- If your system is Debian 11, you can utilize the fully offline method, which is auto done by the playbook.
- If you want to modify docker registry mirror, go to `containerd/certs.d/` and <https://github.com/containerd/containerd/blob/main/docs/hosts.md>.
