#!/bin/sh
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

#---------------------------------------------------------------------
# Variables
#---------------------------------------------------------------------
TESTNAME=$(basename "$0")
# shellcheck disable=SC2034
TESTBASENAME=$(echo "${TESTNAME}" | sed 's/[.]sh$//')
TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${TESTDIR}" || exit 1; pwd)

#
# Load utility file for test
#
UTIL_TESTFILE="util_test.sh"
if [ -f "${TESTDIR}/${UTIL_TESTFILE}" ]; then
	. "${TESTDIR}/${UTIL_TESTFILE}"
fi

#=====================================================================
# Test for version
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Version API(/)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Version API(/)"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" version "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Version API(/v1)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Version API(/v1)"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" version v1 "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# Check update log
#---------------------------------------------------------------------
if ! test_update_snapshot; then
	TEST_EXIT_CODE=1
fi

exit "${TEST_EXIT_CODE}"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
