#!/bin/bash

VERSION="v17.09-ce"

echo "This has to be run on the PINE itself! Cross compiling is crazy annoying apparently..."

pushd docker
git clone https://github.com/docker/docker-ce.git --depth 1 --single-branch -b ${VERSION}
cp config/docker-Dockerfile.aarch64 docker/docker-ce/components/packaging/deb/debian-stretch/Dockerfile.aarch64
pushd docker-ce/components/packaging/deb
make debian-stretch
popd

cp docker-ce/components/packaging/deb/debbuild/debian-stretch/docker-ce_*_arm64.deb ../output/output
popd
