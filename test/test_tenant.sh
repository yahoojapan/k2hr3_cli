#!/bin/sh
#
# K2HR3 Utilities - Command Line Interface
#
# Copyright 2023 Yahoo Japan Corporation.
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
# CREATE:   Thu Jul 27 2023
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
# Test for Tenant
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Create tenant
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Create tenant"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" tenant create "test_local_tenant" --display "test local tenant" --description "LOCAL TENANT for TEST" --users "[\"test\",\"test1\",\"test2\"]" --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Update tenant
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Update tenant"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" tenant update "test_local_tenant" --tenantid "test-local-tenant-id" --display "updated test local tenant" --description "LOCAL TENANT for UPDATE TEST" --users "[\"test\",\"test1\"]" --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : Get tenant list without expanding
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Get tenant list without expanding"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" tenant show --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : Get tenant list with expanding
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Get tenant list with expanding"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" tenant show --expand --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Get tenant with tenant name
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Get tenant with tenant name"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" tenant show "test_local_tenant" --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Delete tenant
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Delete tenant"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" tenant delete "test_local_tenant" --tenantid "test-local-tenant-id" --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

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
