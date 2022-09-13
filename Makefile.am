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

# [BUILD]
# Since it is a shell script-only project, there is nothing to build,
# but we will create a VERSION file.
# Then, shellcheck checks all the source code.
#
build: build_version shellcheck

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
SHELLCHECK_CMD =				shellcheck
SHELLCHECK_OPT =				--shell=sh
SHELLCHECK_COMMON_IGN =			--exclude=SC1117,SC1090,SC1091,SC2181
SHELLCHECK_CUSTOM_IGN =			--exclude=SC1117,SC1090,SC1091,SC2181,SC2034
EXCLUDE_SHELLCHECK_DIR_OPT =	\( -name '.git' -o -name 'rpmbuild' -o -name 'debian_build' -o -name 'autom4te.cache' -o -name 'm4' \) -prune -not \( -name '.git' -o -name 'rpmbuild' -o -name 'debian_build' -o -name 'autom4te.cache' -o -name 'm4' \)
EXCLUDE_SHELLCHECK_FILE_OPT =	-not -name '*.sh' \
								-not -name 'compile' \
								-not -name 'config.guess' \
								-not -name 'config.status' \
								-not -name 'config.sub' \
								-not -name 'configure' \
								-not -name 'configure~' \
								-not -name 'depcomp' \
								-not -name 'install-sh' \
								-not -name 'libtool' \
								-not -name 'missing' \
								-not -name 'test-driver' \
								-not -name 'rules'

SHELLCHECK_FILES = $(shell find . -type d $(EXCLUDE_SHELLCHECK_DIR_OPT) -o -executable -type f $(EXCLUDE_SHELLCHECK_FILE_OPT))
SHELLCHECK_FILES_COMMON_SH = $(shell find . -type d $(EXCLUDE_SHELLCHECK_DIR_OPT) -o -type f -name '*.sh' | grep -v ostypevars.sh)
SHELLCHECK_FILES_CUSTOM_SH = $(shell find . -type d $(EXCLUDE_SHELLCHECK_DIR_OPT) -o -type f -name '*.sh' | grep ostypevars.sh)

shellcheck:
	@if type shellcheck > /dev/null 2>&1; then \
		echo "*** Check all files with ShellCheck"; \
		if [ -n "$(SHELLCHECK_FILES_ALL)" ]; then \
			$(SHELLCHECK_CMD) $(SHELLCHECK_OPT) $(SHELLCHECK_COMMON_IGN) $(SHELLCHECK_FILES_ALL) || exit 1; \
		fi; \
		if [ -n "$(SHELLCHECK_FILES_COMMON_SH)" ]; then \
			$(SHELLCHECK_CMD) $(SHELLCHECK_OPT) $(SHELLCHECK_COMMON_IGN) $(SHELLCHECK_FILES_COMMON_SH) || exit 1; \
		fi; \
		if [ -n "$(SHELLCHECK_FILES_CUSTOM_SH)" ]; then \
			$(SHELLCHECK_CMD) $(SHELLCHECK_OPT) $(SHELLCHECK_CUSTOM_IGN) $(SHELLCHECK_FILES_CUSTOM_SH) || exit 1; \
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
