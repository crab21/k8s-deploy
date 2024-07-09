#!/bin/bash

rm -rf helm/*.tgz helm/helm helm/*.gz
rm -rf k8s/kubeadm k8s/kubectl k8s/kubelet helm/helm.tar.gz containerd/*.tar.gz
rm -rf helm/linux-amd64
rm -rf containerd/*.gz
rm -rf containerd/runc