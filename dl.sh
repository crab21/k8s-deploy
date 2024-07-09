# Copyright 2022 kennylong@tencent.com.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

export arch=${arch:=amd64}
k8s_version=1.30.2
nerdctl_version=1.7.6
cri_tools_version=1.30.0
helm_version=3.15.2
harbor_version=1.11.1
cilium_version=1.15.6
openebs_version=3.5.0
containerd_version=1.7.19

echo "======== downloading all the artifacts with linux/${arch} platform..."

function dldd(){
    if [ $# != 3 ] ; then
        echo "最少三个参数： 下载路径 重命名文件  链接"
        exit 1;
    fi
    echo $1 $2 $3
    nowpath=`pwd`
    mkdir -p $1
    cd $1
    if [ $2 == 0 ]; then
        wget -v $3
        cd $nowpath
    else
        wget -v -O $2 $3
        cd $nowpath
    fi

}

dldd containerd cri-containerd-cni.tar.gz https://github.com/containerd/containerd/releases/download/v${containerd_version}/cri-containerd-cni-${containerd_version}-linux-${arch}.tar.gz
dldd containerd nerdctl.tar.gz  https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/nerdctl-full-${nerdctl_version}-linux-${arch}.tar.gz


dldd containerd crictl.tar.gz  https://github.com/kubernetes-sigs/cri-tools/releases/download/v${cri_tools_version}/crictl-v${cri_tools_version}-linux-${arch}.tar.gz

dldd helm helm.tar.gz https://get.helm.sh/helm-v${helm_version}-linux-${arch}.tar.gz
tar zxvf helm/helm.tar.gz -C helm linux-${arch}/helm --strip-components 1 && rm helm/helm.tar.gz

dldd helm harbor.tgz https://helm.goharbor.io/harbor-${harbor_version}.tgz
dldd helm cilium.tgz https://github.com/cilium/charts/raw/master/cilium-${cilium_version}.tgz

dldd k8s kubelet https://dl.k8s.io/release/v${k8s_version}/bin/linux/${arch}/kubelet
dldd k8s kubeadm https://dl.k8s.io/release/v${k8s_version}/bin/linux/${arch}/kubeadm
dldd k8s kubectl https://dl.k8s.io/release/v${k8s_version}/bin/linux/${arch}/kubectl

dldd misc kube-flannel.yml https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
dldd misc local-path-storage.yaml https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.22/deploy/local-path-storage.yaml

# dldd misc openebs.tar.gz https://github.com/openebs/charts/releases/download/openebs-${openebs_version}/openebs-${openebs_version}.tgz
dldd containerd runc https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.${arch}