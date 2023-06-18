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

ns=${ns:=k8s.io}
platform=linux/arm64

export PATH=$PATH:/usr/local/bin

# fix a containerd bug, the image is a bug
# ctr -n ${ns} i pull --all-platforms docker.io/library/busybox:latest

for file in k8s harbor 3rd 3rd; do
    # while read image; do
    #     echo "pulling $image"
    #     ctr -n ${ns} i pull --all-platforms $image --hosts-dir ../containerd/certs.d
    # done <${file}.txt
    # ctr -n ${ns} i export --all-platforms ${file}.tar $(tr '\n' ' '  < ${file}.txt)
    crane pull --platform ${platform} $(tr '\n' ' '  < ${file}.txt) ${file}.tar
done
