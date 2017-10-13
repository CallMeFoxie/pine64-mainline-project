#!/bin/bash

VERSION=$1

VERSION=$1
PKGVERSION=`dpkg-parsechangelog -S Version`

if [ x"$VERSION" != x"$PKGVERSION" ]; then
  echo "Updating meta package..."



  cat > /tmp/changelog.tmp << EOF
linux-image-pine64 (${VERSION}) stable; urgency=medium

  * upgrade kernel to ${VERSION}

 -- Ashley the Foxie <pine64@victorianfox.com>  $(date -R)

EOF

  mv debian/changelog debian/changelog_old
  cat /tmp/changelog.tmp debian/changelog_old > debian/changelog
  rm debian/changelog_old
fi

cat debian/control.in | sed "s/@VERSION@/${VERSION}/g" > debian/control

dpkg-buildpackage -tc -uc -b

rm debian/control || :
