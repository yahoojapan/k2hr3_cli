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
# Test for Resoruce
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Create resource
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Create resource"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource create "test_resource" --type string --data "TEST_RESOURCE_DATA_STRING" --keys "{\"key1\":\"value1\",\"key2\":\"value2\"}" --alias "[\"yrn:yahoo:::test_tenant:resource:test_resource_sub\"]" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Create resource with datafile
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Create resource with datafile"
test_prn_title "${TEST_TITLE}"

#
# Make dummy datafile
#
pecho "DATA FILE FOR RESOURCE UNIT TEST"	>  "/tmp/.${TESTBASENAME}_$$.resource"
pecho "LINE 1"								>> "/tmp/.${TESTBASENAME}_$$.resource"

#
# Run
#
"${K2HR3CLIBIN}" resource create "test_resource" --type string --datafile "/tmp/.${TESTBASENAME}_$$.resource" --keys "{\"key1\":\"value1\",\"key2\":\"value2\"}" --alias "[\"yrn:yahoo:::test_tenant:resource:test_resource_sub\"]" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

rm -f "/tmp/.${TESTBASENAME}_$$.resource"

#---------------------------------------------------------------------
# (3) Normal : Update resource data
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Update resource data"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource create "test_resource" --type object --data "{\"data1\":\"value1\",\"data2\":\"value2\"}" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : Update resource data by file
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Update resource data by file"
test_prn_title "${TEST_TITLE}"

#
# Make dummy datafile
#
pecho "DATA FILE FOR RESOURCE UNIT TEST"	>  "/tmp/.${TESTBASENAME}_$$.resource"
pecho "LINE 1"							>> "/tmp/.${TESTBASENAME}_$$.resource"


#
# Run
#
"${K2HR3CLIBIN}" resource create "test_resource" --type string --datafile "/tmp/.${TESTBASENAME}_$$.resource" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

rm -f "/tmp/.${TESTBASENAME}_$$.resource"

#---------------------------------------------------------------------
# (5) Normal : Update resource keys
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Update resource keys"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource create "test_resource" --keys "{\"key3\":\"value3\",\"key4\":\"value4\"}" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Update resource alias
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Update resource alias"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource create "test_resource"  --alias "[\"yrn:yahoo:::test_tenant:resource:test_resource_second\"]" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (7) Normal : Get resource without expand/service
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(7) Normal : Get resource without expand/service"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource show "test_resource" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (8) Normal : Get resource with expand without service
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(8) Normal : Get resource with expand without service"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource show "test_resource" --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (9) Normal : Get resource without expand with service
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(9) Normal : Get resource without expand with service"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource show "test_resource" --service test_service --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (10) Normal : Get resource with expand/service
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(10) Normal : Get resource with expand/service"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource show "test_resource" --service test_service --expand --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (11) Normal : Delete resource(all)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(11) Normal : Delete resource(all)"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource delete "test_resource" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (12) Normal : Delete resource anytype
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(12) Normal : Delete resource anytype"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource delete "test_resource" --type anytype --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (13) Normal : Delete resource object
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(13) Normal : Delete resource object"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource delete "test_resource" --type object --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (14) Normal : Delete resource keys
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(14) Normal : Delete resource keys"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource delete "test_resource" --type keys --keys key1 --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
if ! test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (15) Normal : Delete resource aliases
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(15) Normal : Delete resource aliases"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" resource delete "test_resource" --type aliases --aliases "[\"yrn:yahoo:::test_tenant:resource:test_sub_resource\"]" --tenant test_tenant --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

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
