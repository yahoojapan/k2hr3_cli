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
# Test for List
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Get list for service without service name
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Get list for service without service name"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Get list for service with service name
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Get list for service with service name"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list service test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : Get list resource : no-resource/no-service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Get list resource : no-resource/no-service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource "" "" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : Get list resource : no-resource/no-service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Get list resource : no-resource/no-service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource "" "" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Get list resource : resource/no-service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Get list resource : resource/no-service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource test_resource "" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Get list resource : resource/no-service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Get list resource : resource/no-service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource test_resource "" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (7) Normal : Get list resource : no-resource/service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(7) Normal : Get list resource : no-resource/service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource "" test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (8) Normal : Get list resource : no-resource/service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(8) Normal : Get list resource : no-resource/service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource "" test_service --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (9) Normal : Get list resource : resource/service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(9) Normal : Get list resource : resource/service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource test_resource test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (10) Normal : Get list resource : resource/service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(10) Normal : Get list resource : resource/service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list resource test_resource test_service --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (11) Normal : Get list policy : no-policy/no-service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(11) Normal : Get list policy : no-policy/no-service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy "" "" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (12) Normal : Get list policy : no-policy/no-service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(12) Normal : Get list policy : no-policy/no-service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy "" "" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (13) Normal : Get list policy : policy/no-service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(13) Normal : Get list policy : policy/no-service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy test_policy "" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (14) Normal : Get list policy : policy/no-service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(14) Normal : Get list policy : policy/no-service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy test_policy "" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (15) Normal : Get list policy : no-policy/service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(15) Normal : Get list policy : no-policy/service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy "" test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (16) Normal : Get list policy : no-policy/service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(16) Normal : Get list policy : no-policy/service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy "" test_service --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (17) Normal : Get list policy : policy/service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(17) Normal : Get list policy : policy/service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy test_policy test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (18) Normal : Get list policy : policy/service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(18) Normal : Get list policy : policy/service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list policy test_policy test_service --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (19) Normal : Get list role : no-role/no-service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(19) Normal : Get list role : no-role/no-service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role "" "" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (20) Normal : Get list role : no-role/no-service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(20) Normal : Get list role : no-role/no-service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role "" "" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (21) Normal : Get list role : role/no-service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(21) Normal : Get list role : role/no-service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role test_role "" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (22) Normal : Get list role : role/no-service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(22) Normal : Get list role : role/no-service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role test_role "" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (23) Normal : Get list role : no-role/service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(23) Normal : Get list role : no-role/service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role "" test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (24) Normal : Get list role : no-role/service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(24) Normal : Get list role : no-role/service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role "" test_service --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (25) Normal : Get list role : role/service/no-expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(25) Normal : Get list role : role/service/no-expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role test_role test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (26) Normal : Get list role : role/service/expand
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(26) Normal : Get list role : role/service/expand"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" list role test_role test_service --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

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
