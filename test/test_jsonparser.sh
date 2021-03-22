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

#---------------------------------------------------------------------
# Load Files( for this test only )
#---------------------------------------------------------------------
#
# Load JSON parser file
#
COMMON_JSONPARSER_FILE=${COMMONDIR}/jsonparser.sh
. "${COMMON_JSONPARSER_FILE}"

#=====================================================================
# Test for jsonparser
#=====================================================================
TEST_EXIT_CODE=0

# shellcheck disable=SC2034
K2HR3CLI_OPT_JSON=1

#---------------------------------------------------------------------
# (1) Normal : example version API(/)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : example version API(/)"
test_prn_title "${TEST_TITLE}"

#
# Test data
#
TEST_INPUT_JSON_STR='{"version":["v1"]}'

#
# Run
#
jsonparser_dump_string "${TEST_INPUT_JSON_STR}" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : example version API(/v1)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : example version API(/v1)"
test_prn_title "${TEST_TITLE}"

#
# Test data
#
TEST_INPUT_JSON_STR='{"version":{"/":["GET"],"/v1":["GET"]},"user token":{"/v1/user/tokens":["HEAD","GET","POST"]},"host":{"/v1/host":["GET","PUT","POST","DELETE"],"/v1/host/{port}":["PUT","POST","DELETE"],"/v1/host/FQDN":["DELETE"],"/v1/host/FQDN:{port}":["DELETE"],"/v1/host/IP":["DELETE"],"/v1/host/IP:{port}":["DELETE"]},"service":{"/v1/service":["PUT","POST"],"/v1/service/{service}":["GET","HEAD","PUT","POST","DELETE"]},"role":{"/v1/role":["PUT","POST"],"/v1/role/{role}":["HEAD","GET","PUT","POST","DELETE"],"/v1/role/token/{role}":["GET"]},"resource":{"/v1/resource":["PUT","POST"],"/v1/resource/{resource}":["HEAD","GET","DELETE"]},"policy":{"/v1/policy":["PUT","POST"],"/v1/policy/{policy}":["HEAD","GET","DELETE"]},"list":{"/v1/list":["HEAD","GET"],"/v1/list/{role, resource, policy}/{path}":["HEAD","GET"]},"acr":{"/v1/acr/{service}":["GET","PUT","POST","DELETE"]}}'

#
# Run
#
jsonparser_dump_string "${TEST_INPUT_JSON_STR}" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : example list API(/v1/list/service)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : example list API(/v1/list/service)"
test_prn_title "${TEST_TITLE}"

#
# Test data
#
TEST_INPUT_JSON_STR='{"result":true,"message":null,"children":[{"name":"service","children":[],"owner":true}]}'

#
# Run
#
jsonparser_dump_string "${TEST_INPUT_JSON_STR}" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : example search key in list API(/v1/list/service) + custom
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : example search key in list API(/v1/list/service)"
test_prn_title "${TEST_TITLE}"

#
# Test data
#
TEST_INPUT_JSON_STR='{"result":true,"message":null,"children":[{"name":"service","children":[],"owner":true,"custom1":1,"custom2":-1,"custom3":false,"custom4":null}]}'

#
# Run
#
jsonparser_parse_json_string "${TEST_INPUT_JSON_STR}"
if [ $? -ne 0 ]; then
	pecho "Failed to parse string." > "${SUB_TEST_PART_FILE}"
else
	jsonparser_dump_key_parsed_file '%' '"children"' "${JP_PAERSED_FILE}" > "${SUB_TEST_PART_FILE}"
	if [ $? -ne 0 ]; then
		pecho "Not found \"children\" key in json string" > "${SUB_TEST_PART_FILE}"
	else
		#
		# expect : 'type="%ARR%", value count=1'
		#
		pecho "type=\"${JSONPARSER_FIND_VAL_TYPE}\", value count=${JSONPARSER_FIND_VAL}" >> "${SUB_TEST_PART_FILE}"
	fi
	rm -f "${JP_PAERSED_FILE}"
fi

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Simulate Openstack neutron data(example)
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Simulate Openstack neutron data(example)"
test_prn_title "${TEST_TITLE}"

#
# Test data
#
TEST_INPUT_JSON_STR='{"security_groups": [{"id": "00000000-0000-0000-0000-000000000000", "name": "ssh-allow", "stateful": true, "tenant_id": "00000000000000000000000000000000", "description": "", "security_group_rules": [{"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "ingress", "protocol": "tcp", "port_range_min": 22, "port_range_max": 22, "remote_ip_prefix": "0.0.0.0/0", "remote_group_id": null, "description": "", "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv6", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}], "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 2, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "name": "default", "stateful": true, "tenant_id": "00000000000000000000000000000000", "description": "Default security group", "security_group_rules": [{"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "ingress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": "00000000-0000-0000-0000-000000000000", "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv6", "direction": "ingress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": "00000000-0000-0000-0000-000000000000", "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv6", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}], "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 1, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "name": "k2hdkc-slave-sec", "stateful": true, "tenant_id": "00000000000000000000000000000000", "description": "security group for k2hr3 slave node", "security_group_rules": [{"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "ingress", "protocol": "tcp", "port_range_min": 22, "port_range_max": 22, "remote_ip_prefix": "0.0.0.0/0", "remote_group_id": null, "description": "ssh port", "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv6", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "ingress", "protocol": "tcp", "port_range_min": 8031, "port_range_max": 8031, "remote_ip_prefix": "0.0.0.0/0", "remote_group_id": null, "description": "k2hdkc/chmpx slave node control port", "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}], "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 3, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "name": "mycluster--k2hdkc-slave-sec", "stateful": true, "tenant_id": "00000000000000000000000000000000", "description": "security group for k2hdkc mycluster slave node", "security_group_rules": [{"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "ingress", "protocol": "tcp", "port_range_min": 22, "port_range_max": 22, "remote_ip_prefix": "0.0.0.0/0", "remote_group_id": null, "description": "", "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv6", "direction": "egress", "protocol": null, "port_range_min": null, "port_range_max": null, "remote_ip_prefix": null, "remote_group_id": null, "description": null, "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}, {"id": "00000000-0000-0000-0000-000000000000", "tenant_id": "00000000000000000000000000000000", "security_group_id": "00000000-0000-0000-0000-000000000000", "ethertype": "IPv4", "direction": "ingress", "protocol": "tcp", "port_range_min": 8031, "port_range_max": 8031, "remote_ip_prefix": null, "remote_group_id": null, "description": "k2hdkc/chmpx slave node control port", "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 0, "project_id": "00000000000000000000000000000000"}], "tags": [], "created_at": "2021-01-01T00:00:00Z", "updated_at": "2021-01-01T00:00:00Z", "revision_number": 3, "project_id": "00000000000000000000000000000000"}]}'

#
# Run
#
jsonparser_dump_string "${TEST_INPUT_JSON_STR}" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Line feed code test
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Line feed code test"
test_prn_title "${TEST_TITLE}"

#
# Test data
#
TEST_INPUT_JSON_STR='{"field1":"1\n2\n3\n4"}'

#
# Run
#
jsonparser_dump_string "${TEST_INPUT_JSON_STR}" > "${SUB_TEST_PART_FILE}"

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
