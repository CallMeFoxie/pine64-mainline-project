#!/bin/bash

VERSION=$1

pushd debian/

cat > /tmp/changelog.tmp << EOF
linux-image-pine64 (${VERSION}) stable; urgency=medium

  * upgrade kernel to ${VERSION}

 -- Ashley the Foxie <pine64@victorianfox.com> $(date -R)

EOF

mv changelog changelog_old
cat /tmp/changelog.tmp changelog_old > changelog
rm changelog_old

rm control || :
cat control.in | sed "s/@VERSION@/${VERSION}/g" > control

rm linux-image-pine64-${VERSION}.postinst
cat linux-image-pine64-kernel.postinst.in | sed "s/@VERSION@/${VERSION}/g" > linux-image-pine64-${VERSION}.postinst

rm linux-image-pine64-${VERSION}.install
cat linux-image-pine64-kernel.install.in | sed "s/@VERSION@/${VERSION}/g" > linux-image-pine64-${VERSION}.install

popd
