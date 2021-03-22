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
# Test for Service
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Create service without verify
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Create service with object"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service create "test_service" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Create service with verify object
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Create service with verify object"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service create "test_service" --verify "[{\"name\":\"test_service_resouce_string\",\"type\":\"string\",\"data\":null}]" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : Create service with verify url
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Create service with verify url"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service create "test_service" --verify "https://localhost/" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : Create service with verify false
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Create service with verify false"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service create "test_service" --verify false --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Show service
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Show service"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service show "test_service" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Delete service
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Delete service"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service delete "test_service" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (7) Normal : Add service tenant
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(7) Normal : Add service tenant"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service tenant add "test_service" "test_service_member" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (8) Normal : Check service tenant
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(8) Normal : Check service tenant"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service tenant check "test_service" "test_service_member" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (9) Normal : Delete service tenant(owner operation)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(9) Normal : Delete service tenant(owner operation)"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service tenant delete "test_service" "test_service_member" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (10) Normal : Delete service tenant with clear(owner operation)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(10) Normal : Delete service tenant with clear(owner operation)"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service tenant delete "test_service" "test_service_member" --clear_tenant --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (11) Normal : Update service verify url
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(11) Normal : Update service verify url"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service verify update "test_service" "http://localhost/" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (12) Normal : Update service verify object
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(12) Normal : Update service verify object"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service verify update "test_service" "[{\"name\":\"test_service_resouce_string\",\"type\":\"string\",\"data\":null}]" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (13) Normal : Delete tenant member service
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(13) Normal : Delete tenant member service"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" service member clear "test_service" "test_service_member" --tenant test_service_member --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

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
