#!/bin/bash
path=`pwd`/images/
xargs -n 1 docker pull < ${path}/all-images.txt 
xargs docker save -o ${path}/k8s-1.27.2.tar < ${path}/all-images.txt 