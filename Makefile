NAME     = xapp-xchat
TITLE    = Xchat-Xapp
APP_ID   = org.webosinternals.${NAME}
SIGNER   = org.webosinternals
BLDFLAGS = -p
VERSION  = 0.0.1
TYPE	 = Linux Application
CATEGORY = Utilities
HOMEPAGE = http://www.webos-internals.org/wiki/UbuntuChroot
ICON	 = http://www.webos-internals.org/images/5/5e/Icon_WebOSInternals_Ubuntu.png
DESCRIPTION = ${APPINFO_DESCRIPTION}
APPINFO_DESCRIPTION = A Xapp to Launch Xchat. Requires Ubuntu-Natty-Chroot.
CHANGELOG = \
0.0.1-1: Initial test. 
APPINFO_CHANGELOG = [ \
{ "version" : "0.0.1-1",  "log" : [ "Initial test" ] } \
]

SCREENSHOTS = [\
 ]
LICENSE  = GPL v2 Open Source

# Also requires upstart changes from:
# http://gyp.blogs.balabit.com/2011/01/using-upstart-in-a-chroot/
# http://git.balabit.hu/?p=gyp/upstart-dummy.git;a=summary

include ../../support/download.mk

HEADLESSAPP_VERSION = 0.2.0

include ../../support/headlessapp.mk

.PHONY: package
package: ipkgs/${APP_ID}_${VERSION}_arm.ipk # ipkgs/${APP_ID}_${VERSION}_i686.ipk
include ../../support/package.mk

.PHONY: unpack
unpack: build/.unpacked-${VERSION}

build/.unpacked-${VERSION}:
	rm -rf build
	mkdir -p build
	touch $@

.PHONY: build
build: build/.built-${VERSION}

build/.built-${VERSION}: build/arm.built-${VERSION} # build/i686.built-${VERSION}
	touch $@

include ../../support/cross-compile.mk

build/${NAME}.tgz:
	rm -f build/${NAME}.tgz
	( cd build ; rootstock --no-root --fqdn ${NAME} --dist natty )
	mv build/armel-rootfs*.tgz build/${NAME}.tgz

build/%.built-${VERSION}: build/.unpacked-${VERSION} build/${NAME}.tgz ${DL_DIR}/headlessapp-${HEADLESSAPP_VERSION}.tar.gz
	rm -rf build/$*
	mkdir -p build/$*/usr/palm/applications/${APP_ID}
	tar -C build/$*/usr/palm/applications/${APP_ID} -xf ${DL_DIR}/headlessapp-${HEADLESSAPP_VERSION}.tar.gz
	rm -rf build/$*/usr/palm/applications/${APP_ID}/.git
	install -m 644 build/${NAME}.tgz build/$*/usr/palm/applications/${APP_ID}/${NAME}.tgz 
	install -m 644 icon.png build/$*/usr/palm/applications/${APP_ID}/icon.png
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/upstart
	install -m 644 upstart/${APP_ID} build/$*/usr/palm/applications/${APP_ID}/upstart/
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/bin
	install -m 755 bin/*.sh build/$*/usr/palm/applications/${APP_ID}/bin/
	echo "{" > build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "\"title\": \"${TITLE}\"," >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "\"id\": \"${APP_ID}\"," >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "\"version\": \"${VERSION}\"," >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "\"vendor\": \"WebOS Internals\"," >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "\"type\": \"web\"," >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "\"main\": \"index.html\"," >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "\"icon\": \"icon.png\"," >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
ifdef APPINFO_DESCRIPTION
	echo '"message": "${APPINFO_DESCRIPTION}",' >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
endif
ifdef APPINFO_CHANGELOG
	echo '"changeLog": ${APPINFO_CHANGELOG},' >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
endif
	echo "\"noWindow\": true" >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	echo "}" >> build/$*/usr/palm/applications/${APP_ID}/appinfo.json
	touch $@
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/usr/sbin
	install -m 744 usr/sbin/*.sh build/$*/usr/palm/applications/${APP_ID}/usr/sbin/

clobber::
	rm -rf build
