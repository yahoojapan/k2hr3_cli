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
# Test for Token
#=====================================================================
TEST_EXIT_CODE=0

#---------------------------------------------------------------------
# (1) Normal : Create Unscoped Token from credential
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Create Unscoped Token from credential"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token create utoken_cred --user test --passphrase password "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Create Unscoped Token from openstack token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Create Unscoped Token from openstack token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token create utoken_optoken --openstacktoken TEST_OPENSTACK_TOKEN_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : Create Unscoped Token from OIDC token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Create Unscoped Token from OIDC token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token create utoken_oidctoken --openidconnecttoken TEST_OIDC_TOKEN_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : Create Scoped Token from credential
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Create Scoped Token from credential"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token create token_cred --user test --passphrase password --tenant test "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Create Scoped Token from unscoped token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Create Scoped Token from unscoped token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token create token_utoken --tenant test --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Create Scoped Token from openstack token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Create Scoped Token from openstack token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token create token_optoken --tenant test --openstacktoken TEST_OPENSTACK_TOKEN_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (7) Normal : Create Scoped Token from OIDC token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(7) Normal : Create Scoped Token from OIDC token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token create token_oidctoken --tenant test --openidconnecttoken TEST_OIDC_TOKEN_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (8) Normal : Show tenant list from unscoped token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(8) Normal : Show tenant list from unscoped token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token show utoken --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (9) Normal : Show tenant list from scoped token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(9) Normal : Show tenant list from scoped token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token show token --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (10) Normal : Check user unscoped token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(10) Normal : Check user unscoped token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token check --unscopedtoken TEST_TOKEN_UNSCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (11) Normal : Check user scoped token
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(11) Normal : Check user scoped token"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" token check --scopedtoken TEST_TOKEN_SCOPED_DUMMY "$@" > "${SUB_TEST_PART_FILE}"

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
