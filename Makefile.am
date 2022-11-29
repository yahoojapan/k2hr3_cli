#
# K2HR3 Utilities - Command Line Interface
#
# Copyright 2021 Yahoo! Japan Corporation.
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

SUBDIRS = docs src buildutils test

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = RELEASE_VERSION @CONFIGURECUSTOM@

CLEANFILES = *.log src/libexec/common/VERSION

# [NOTE]
# Change the default target to build.
#
.DEFAULT_GOAL = build

# [BUILD]
# Since it is a shell script-only project, there is nothing to build,
# but we will create a VERSION file.
#
build: build_version

.PHONY: build_version shellcheck

# [VERSION]
# Create a VERSION file in the src/libexec/common directory.
#
build_version:
	@if true; then \
		echo "*** Create VERSION file in src/libexec/common directory"; \
		RELEASE_VERSION_BASE=`cat RELEASE_VERSION`; \
		GIT_SHORT_HASH=`git rev-parse --short HEAD 2>/dev/null || echo \"Unknown\"`; \
		echo "$${RELEASE_VERSION_BASE}($${GIT_SHORT_HASH})" > src/libexec/common/VERSION 2>&1; \
		echo "   -> Succeed"; \
		echo ""; \
	fi

# [SHELLCHECK]
# This make target executes shellchek on text files with the
# extension '*.sh' under the current directory(other than the
# '.git' directory) and executable files(text files other than
# the extension '*.sh').
#
SHELLCHECK_CMD				= shellcheck
SHELLCHECK_BASE_OPT			= --shell=sh
SHELLCHECK_IGN_OPT			= --exclude=SC1117,SC1090,SC1091
SHELLCHECK_INCLUDE_IGN_OPT	= --exclude=SC1117,SC1090,SC1091,SC2034,SC2148
SHELLCHECK_FILES_NO_SH		= `grep -ril '^\#!/bin/sh' . | grep -v '\.sh' | grep -v '\.log' | grep -e '/\.github/' -e '/buildutils/' -e '/docs/' -e '/src/' -e '/test/' | tr '\n' ' '`
SHELLCHECK_FILES_SH			= `grep -ril '^\#!/bin/sh' . | grep '\.sh' | grep -v '\.sh\.' | grep -v '/\.git/' | grep -v '/rpmbuild/' | grep -v '/debian_build/' | grep -v '/autom4te.cache/' | grep -v '/m4/' | tr '\n' ' '`
SHELLCHECK_FILES_INCLUDE_SH	= `grep -Lir '^\#!/bin/sh' . | grep '\.sh' | grep -v '\.sh\.' | grep -v '/\.git/' | grep -v '/rpmbuild/' | grep -v '/debian_build/' | grep -v '/autom4te.cache/' | grep -v '/m4/' | tr '\n' ' '`

shellcheck:
	@if type shellcheck > /dev/null 2>&1; then \
		echo "*** Check all files with ShellCheck"; \
		if [ -n "$(SHELLCHECK_FILES_NO_SH)" ]; then \
			$(SHELLCHECK_CMD) $(SHELLCHECK_BASE_OPT) $(SHELLCHECK_IGN_OPT) $(SHELLCHECK_FILES_NO_SH) || exit 1; \
		fi; \
		if [ -n "$(SHELLCHECK_FILES_SH)" ]; then \
			$(SHELLCHECK_CMD) $(SHELLCHECK_BASE_OPT) $(SHELLCHECK_IGN_OPT) $(SHELLCHECK_FILES_SH) || exit 1; \
		fi; \
		if [ -n "$(SHELLCHECK_FILES_INCLUDE_SH)" ]; then \
			$(SHELLCHECK_CMD) $(SHELLCHECK_BASE_OPT) $(SHELLCHECK_INCLUDE_IGN_OPT) $(SHELLCHECK_FILES_INCLUDE_SH) || exit 1; \
		fi; \
		echo "   -> No error was detected."; \
		echo ""; \
	else \
		echo "ShellCheck is not installed, so skip check by it."; \
		echo ""; \
	fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
