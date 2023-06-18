# 一键部署 k8s/harbor

本文档介绍了利用ansible一键部署高可用的Kubernetes集群，它包含但不限于：

- 离线安装包
- 基于containerd的容器运行时
- 高可用（可选）
- 根据内核版本自动选取 cilium/flannel cni 插件
- 支持默认的存储类（本地文件系统）
- 附带内置的harbor镜像仓库

它易于使用，默认情况下除了机器信息无需任何配置，整个流程只需不到5分钟。原生的k8s最新版，你可以根据自己的需求去定制任何选项。

完整的安装包可以在[这里下载](https://kennylong-1259649581.cos.ap-guangzhou.myqcloud.com/k8s-yyds-v1.0.0.tar.bz2)

## 通过验证的环境

下面的前置条件必须满足：

- 基于 `systemd` 的系统管理
- Linux 内核在 3.10.0 以上
- ansible 2.5+

如果你的系统软件包管理器不是基于apt或者yum的，你需要自行安装 `socat conntrack iptables` 这三个软件。

经过验证的 Linux 发行版:

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

Debian/Ubuntu 推荐 2c2g 以上的配置, 然而 CentOS/TencentOS 2c4g+.

## 目录结构

- `dl.sh` 包含所有的离线软件的下载脚本
- `images/` 目录保护所有的离线oci镜像（k8s, harbor还有别的），已经生成，导入，导出和删除等脚本
- `misc/` 放置了别的东西比如debian 11系统的离线安装deb包以及一些用到的k8s yaml文件
- `helm/` 包括helm的二进制和一些用到的chart包
- `containerd/` 目录存放的时容器运行时，cri cni等二进制软件和配置
- `k8s/` 目录包括一些k8s相关的二进制文件（kubeadm, kubelet, kubectl）以及一些配置模版

其余均是ansible的playbook脚本。

## 使用方式

### 1: 安装底层依赖软件包 (可选)

如果机器没有网络，使用系统的包管理器安装 `socat conntrack iptables`

### 2: 主机信息 (必须)

控制平面（master）节点必须放置在 `[masters]` 部分，并且 `master0` **必须** 设置，它会被用来作为最终集群的访问入口点，也就是 `kubeconfig` 里的 server 字段 host。

> 这里后续版本会优化，由用户提供一个域名或者稳定的ip作为 apiserver 的负载均衡器。

比如：

```ini
[masters]
master0 ansible_host=114.132.78.246 # will be the apiserver lb ip
master1 ansible_host=43.139.28.80
# more...
```

其他节点的名字可以任意填写。

数据平面（Node节点用于部署负载）必须放置在 `[workers]` 部分下，名字没有约束，可以任意写。

如果集群不需要高可用（HA），只设置一个 `master0` 完全没有问题。

注意所有的机器必须拥有ssh免密登录的权限。

### 3: 定制 k8s 组件 (可选)

如果想更改apiserver，etcd，scheduler等组件的选项和行为，在 `./k8s/kubeadm-init.yaml` 文件里有更详细的说明。

### 4: 定制容器运行时 (可选)

如果想修改容器运行时的选项，比如景象存储路径（默认在 `/var/lib`）或者仓库镜像（registry mirrors)，请修改 `./containerd/config.toml` 文件。

### 5: 定制 harbor (可选)

`harbor.yaml` 里设置了harbor的默认配置，比如host和初始密码，设置是禁用选项。

注意如果你的cni插件不是cilium（kernel低于4.9）而是flannel，你可能需要修改k8s service的类型将harbor服务的端点暴露出来。

或者设置 `external_url` 成k8s的域名 `harbor.harbor.svc.cluster.local`。

默认的harbor访问url和密码分别是 `harbor.k8s.local` 和 `k8s-yyds`。

### 6: 最后一步(必须）

```sh
ansible-playbook -i hosts.ini all.yaml -f 6
```

如果没出问题，创建出的集群的 kube config 将会放置在 `out/kubeconfig.yaml`。

## 存在的问题

- openCloudOS 8 访问节点的公网ip 会报 no route to host 的错误, 但是localhost访问是OK的
- 如果你的系统已经安装了docker和containerd，不太清楚是否会影响，因为containerd会重新安装。k8s 1.24 已经废弃了docker，你可以选用更轻量和标准的工具，比如`ctr`或者`crictl`

## Misc

- 如果你的系统是 Debian 11，可以做到完全的离线安装，这个是在ansible playbook里自动实施的
- 如果你想修改镜像仓库的registry mirror，请参考 `containerd/certs.d/` 目录和 <https://github.com/containerd/containerd/blob/main/docs/hosts.md>.

最后有任何使用或者功能上的问题欢迎讨论和贡献。
