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

for file in k8s harbor 3rd; do
    rm -rf ${file}.txt
done

declare -A map

map["kube-system"]=k8s
map["harbor"]=harbor
# map["kube-flannel"]=3rd

for ns in ${!map[*]}; do
    kubectl get po -n $ns -ojson | jq -r '.items[] | .spec.containers[] | .image' >> ${map[$ns]}.txt
    kubectl get po -n $ns -ojson | jq -r '.items[] | .spec.initContainers[]? | .image' >> ${map[$ns]}.txt
done

# put additional special or abnormal images
cat <<EOF >>3rd.txt
docker.io/rancher/local-path-provisioner:v0.0.22
docker.io/library/busybox:1.31
EOF

cat <<EOF >>k8s.txt
registry.k8s.io/kube-proxy:v1.25.3
registry.k8s.io/pause:3.8
EOF

# de-duplicated images
for file in k8s harbor 3rd; do
    awk -i inplace '!seen[$0]++' ${file}.txt
    sort -o ${file}.txt ${file}.txt
done
