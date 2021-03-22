#!/bin/sh
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
# Test for Role
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Create role
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Create role"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role create "test_role" --policies "[\"yrn:yahoo:::test_tenant:policy:test_policy\"]" --alias "[\"yrn:yahoo:::test_tenant:role:test_role_sub\"]" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Show role
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Show role"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role show "test_role" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : Delete role
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Delete role"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role delete "test_role" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : Add role host
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Add role host"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role host add "test_role" --host localhost --port 0 --cuk TEST_CUK --extra TEST_EXTRA --tag TEST_TAG --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Delete role host
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Delete role host"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role host delete "test_role" --host localhost --port 0 --cuk TEST_CUK --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Create role token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Create role token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role token create "test_role" --expire 600 --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (7) Normal : Delete role token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(7) Normal : Delete role token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role token delete "test_role" "TEST_TOKEN_ROLE1" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (8) Normal : Check role token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(8) Normal : Check role token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role token check "test_role" "TEST_TOKEN_ROLE1" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (9) Normal : Get role token list without expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(9) Normal : Get role token list without expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role token show "test_role" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (10) Normal : Get role token list with expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(10) Normal : Get role token list with expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" role token show "test_role" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# Check update log
#---------------------------------------------------------------------
test_update_snapshot
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

exit ${TEST_EXIT_CODE}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
