#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Download Source

git clone --depth 1 --branch "$MAUIKIT_ARCHIVER_BRANCH" https://invent.kde.org/maui/mauikit-archiver.git

rm -rf mauikit-archiver/{LICENSE,README.md,metainfo.yml}


# -- Compile Source

mkdir -p build && cd build

HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR="/usr/lib/${HOST_MULTIARCH}" \
	../mauikit-archiver/

make -j"$(nproc)"

make install


# -- Run checkinstall and Build Debian Package

>> description-pak printf "%s\n" \
	'A free and modular front-end framework for developing user experiences.' \
	'' \
	'MauiKit QtQuick plugin for online archived/compressed files management.' \
	'' \
	'Maui stands for Multi-Adaptable User Interface and allows ' \
	'any Maui app to run on various platforms + devices,' \
	'like Linux Desktop and Phones, Android, or Windows.' \
	'' \
	'This package contains the MauiKit archiver shared library, the MauiKit archiver QML module' \
	'and the MauiKit archiver development headers.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=mauikit-archiver \
	--pkgversion="$PACKAGE_VERSION" \
	--pkgarch="$(dpkg --print-architecture)" \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=mauikit-archiver \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=mauikit-archiver \
	--requires="libc6,libkf6archive6,libkf6coreaddons6,libkf6i18n6,libkf6iconthemes6,libqt6core6,libqt6gui6,libqt6qml6,libqt6quick6,libqt6quickcontrols2-6,qt6-declarative,mauikit \(\>= 4.0.2\),mauikit-filebrowsing \(\>= 4.0.2\)" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
