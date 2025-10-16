#
# K2HR3 Utilities - Command Line Interface
#
# Copyright 2021 Yahoo Japan Corporation.
#
# K2HR3 is K2hdkc based Resource and Roles and policy Rules, gathers
# common management information for the cloud.
# K2HR3 can dynamically manage information as "who", "what", "operate".
# These are stored as roles, resources, policies in K2hdkc, and the
# client system can dynamically read and modify these information.
#
# For the full copyright and license information, please view
# the license file that was distributed with this source code.
#
# AUTHOR:   Takeshi Nakatani
# CREATE:   Mon Feb 15 2021
# REVISION:
#

#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
#
AC_PREREQ([2.63])
AC_INIT(k2hr3-cli, m4_esyscmd([tr -d '\n' < $(pwd)/RELEASE_VERSION]))
AM_INIT_AUTOMAKE()

#
# Checks for programs.
#
AC_PROG_CXX
AC_PROG_AWK
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET

#
# Load customizable variables
#
AC_CHECK_FILE([configure.custom],
	[
		configure_custom_file="configure.custom"
		custom_git_domain="$(grep '^\s*GIT_DOMAIN\s*=' configure.custom | sed -e 's|^\s*GIT_DOMAIN\s*=\s*||g' -e 's|^\s*||g' -e 's|\s*$||g')"
		custom_git_org="$(grep '^\s*GIT_ORG\s*=' configure.custom | sed -e 's|^\s*GIT_ORG\s*=\s*||g' -e 's|^\s*||g' -e 's|\s*$||g')"
		custom_git_repo="$(grep '^\s*GIT_REPO\s*=' configure.custom | sed -e 's|^\s*GIT_REPO\s*=\s*||g' -e 's|^\s*||g' -e 's|\s*$||g')"
		custom_git_endpoint="$(grep '^\s*GIT_EP_V3_REPO\s*=' configure.custom | sed -e 's|^\s*GIT_EP_V3_REPO\s*=\s*||g' -e 's|^\s*||g' -e 's|\s*$||g')"
		custom_dev_email="$(grep '^\s*DEV_EMAIL\s*=' configure.custom | sed -e 's|^\s*DEV_EMAIL\s*=\s*||g' -e 's|^\s*||g' -e 's|\s*$||g')"
		custom_dev_name="$(grep '^\s*DEB_NAME\s*=' configure.custom | sed -e 's|^\s*DEB_NAME\s*=\s*||g' -e 's|^\s*||g' -e 's|\s*$||g')"
	],
	[
		configure_custom_file=""
		custom_git_domain="github.com"
		custom_git_org="yahoojapan"
		custom_git_repo="k2hr3_cli"
		custom_git_endpoint="https://api.github.com/repos/"
		custom_dev_email="ml-antpickax-support@lycorp.co.jp"
		custom_dev_name="K2HR3_DEVELOPER"
	]
)

#
# Symbols for buildutils
#
AC_SUBST([CONFIGURECUSTOM], "${configure_custom_file}")
AC_SUBST([GIT_DOMAIN], "${custom_git_domain}")
AC_SUBST([GIT_ORG], "${custom_git_org}")
AC_SUBST([GIT_REPO], "${custom_git_repo}")
AC_SUBST([DEV_EMAIL], "$(echo ${DEBEMAIL:-"${custom_dev_email}"})")
AC_SUBST([DEV_NAME], "$(echo ${DEBFULLNAME:-"${custom_dev_name}"})")
#
AC_SUBST([RPMCHANGELOG], "`$(pwd)/buildutils/make_rpm_changelog.sh $(pwd)/ChangeLog`")
AC_SUBST([SHORTDESC], "`$(pwd)/buildutils/make_description.sh $(pwd)/docs/k2hr3.1 --short`")
AC_SUBST([LONGDESC], "`$(pwd)/buildutils/make_description.sh $(pwd)/docs/k2hr3.1 --long`")
AC_SUBST([DEBLONGDESC], "`$(pwd)/buildutils/make_description.sh $(pwd)/docs/k2hr3.1 --deblong`")
AC_SUBST([PKG_VERSION], "`$(pwd)/buildutils/make_variables.sh --pkg_version`")
AC_SUBST([PKGLICENSE], "`grep License COPYING | sed 's/ License//g'`")
AC_SUBST([DEBCOPYING], "`tail -n +5 COPYING | sed 's/^$/./g' | sed 's/^/ /g'`")
AC_SUBST([DEBHELPER_DEP], "`$(pwd)/buildutils/make_variables.sh --debhelper_dep`")
AC_SUBST([RPMPKG_GROUP], ["`$(pwd)/buildutils/make_variables.sh --rpmpkg_group | sed 's#NEEDRPMGROUP#Group: Applications/Other#g'`"])
AC_SUBST([CONFIGUREWITHOPT], "")
AM_SUBST_NOTMAKE([RPMCHANGELOG])
AM_SUBST_NOTMAKE([SHORTDESC])
AM_SUBST_NOTMAKE([LONGDESC])
AM_SUBST_NOTMAKE([DEBLONGDESC])
AM_SUBST_NOTMAKE([DEBCOPYING])
AM_SUBST_NOTMAKE([DEBHELPER_DEP])
AM_SUBST_NOTMAKE([RPMPKG_GROUP])
AM_SUBST_NOTMAKE([CONFIGUREWITHOPT])

#
# pkg-config for old version
#
AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
AS_IF([test "$PKG_CONFIG" = "no"], [AC_MSG_WARN(You have to install pkg-config to compile $PACKAGE_NAME v$PACKAGE_VERSION)])

#
# Config files
#
AC_CONFIG_FILES([Makefile
				docs/Makefile
				src/Makefile
				src/libexec/Makefile
				src/libexec/acr/Makefile
				src/libexec/common/Makefile
				src/libexec/config/Makefile
				src/libexec/extdata/Makefile
				src/libexec/list/Makefile
				src/libexec/policy/Makefile
				src/libexec/resource/Makefile
				src/libexec/role/Makefile
				src/libexec/service/Makefile
				src/libexec/tenant/Makefile
				src/libexec/token/Makefile
				src/libexec/userdata/Makefile
				src/libexec/version/Makefile
				test/Makefile
				test/snapshots/Makefile
				buildutils/Makefile
				buildutils/control
				buildutils/copyright
				buildutils/rules
				buildutils/k2hr3-cli.spec
				buildutils/APKBUILD.templ])

AC_OUTPUT

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
