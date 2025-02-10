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

#
# [NOTE]
# This file is intended to be loaded into each script that implements
# unit tests.
#
# By loading this file, you can unify the necessary variable settings,
# logs, and message output.
# The whole test works with these outputs expected, so be sure to use
# the message and log output functions defined in this file.
# The following variables are defined by this file, so please use
# these variables on the unit test side.
#
# Environments
#	K2HR3CLI_LIBEXEC_DIR	: libexec diretory path for test
#	K2HR3CLI_REQUEST_FILE	: replace request.sh file for test
#
# Variables:
#	SUB_TEST_UPDATE_OPT		: update option for sub test
#	SUB_TEST_SNAPSHOTS_DIR	: snapshot files directory
#	SUB_TEST_LOGFILE		: unit test log file
#	SUB_TEST_SNAPSHOT_FILE	: unit test snapshot log file
#	SUB_TEST_PART_FILE		: a temporary file used in the comparison process
#	SUB_TEST_DIFF_FILE		: a temporary file used in the comparison result
#
# Functions:
#	test_prn_msg			: output message for log and stdout
#	test_prn_msg_stdout		: output message for only stdout
#	test_prn_msg_log		: output message for only log
#	test_prn_title			: output title for log and stdout
#	test_prn_file			: output file contents for log and stdout
#	test_prn_file_stdout	: output file contents for only stdout
#	test_prn_file_log		: output file contents for only log
#	test_compare_part_log	: compare part test log
#

#---------------------------------------------------------------------
# Variables
#---------------------------------------------------------------------
UTILTESTNAME=$(basename "$0")
UTILTESTBASENAME=$(echo "${UTILTESTNAME}" | sed 's/[.]sh$//')

#
# Flag for this file
#
if [ -z "${LOADED_UTIL_TEST}" ]; then
	LOADED_UTIL_TEST=1
else
	#
	# Already load this file
	#
	exit 0
fi

#
# Common variables
#
TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${TESTDIR}" || exit 1; pwd)
SRCDIR=$(cd "${TESTDIR}/../src" || exit 1; pwd)
LIBEXECDIR=$(cd "${SRCDIR}/libexec" || exit 1; pwd)
# shellcheck disable=SC2034
K2HR3CLIBIN=${SRCDIR}/k2hr3

#
# Set Environments for test
#
export K2HR3CLI_LIBEXEC_DIR="${LIBEXECDIR}"
if [ -z "${K2HR3CLI_REQUEST_FILE}" ]; then
	export K2HR3CLI_REQUEST_FILE="${TESTDIR}/util_request.sh"
fi
if [ -t 1 ]; then
	export K2HR3CLI_FORCE_COLOR=1
fi

#
# Global log file
#
SUB_TEST_SNAPSHOTS_DIR="${TESTDIR}/snapshots"
SUB_TEST_LOGFILE="${TESTDIR}/${TESTBASENAME}.log"
SUB_TEST_SNAPSHOT_FILE="${SUB_TEST_SNAPSHOTS_DIR}/${TESTBASENAME}.snapshot"
SUB_TEST_PART_FILE="/tmp/.${UTILTESTBASENAME}-$$.part"
SUB_TEST_DIFF_FILE="/tmp/.${UTILTESTBASENAME}-$$.diff"

#
# Temporary log files
#
_SUB_TEST_TEMP_MASTER_FILE="/tmp/.${UTILTESTBASENAME}-$$.snapshot.tmp"
_SUB_TEST_TEMP_PART_FILE="/tmp/.${UTILTESTBASENAME}-$$.part.tmp"

#
# Title prefix for log file
#
_UTIL_SUBTEST_TITLE_PREFIX="TEST CASE : "
_UTIL_SUBTEST_UPDATE_PREFIX="UPDATE : "

#---------------------------------------------------------------------
# Load Common Files
#---------------------------------------------------------------------
#
# Common files for this test(this test only)
#
COMMON_DIRNAME="common"
COMMONDIR=${LIBEXECDIR}/${COMMON_DIRNAME}
COMMON_MESSAGE_FILE=${COMMONDIR}/message.sh
COMMON_STRINGS_FILE=${COMMONDIR}/strings.sh
COMMON_DEPENDS_FILE=${COMMONDIR}/depends.sh

#
# Messageing functions
#
if [ -f "${COMMON_MESSAGE_FILE}" ]; then
	. "${COMMON_MESSAGE_FILE}"
fi

#
# Load strings utility functions
#
if [ -f "${COMMON_STRINGS_FILE}" ]; then
	. "${COMMON_STRINGS_FILE}"
else
	prn_err "Could not find ${COMMON_STRINGS_FILE} common file."
	exit 1
fi

#
# Check dependent external programs
#
if [ -f "${COMMON_DEPENDS_FILE}" ]; then
	. "${COMMON_DEPENDS_FILE}"
else
	prn_err "Could not find ${COMMON_DEPENDS_FILE} common file."
	exit 1
fi

#---------------------------------------------------------------------
# Check update parameter
#---------------------------------------------------------------------
# shellcheck disable=SC2034
SUB_TEST_UPDATE_OPT=""

#
# Check K2HR3_RUN_MAIN_PROCESS environment
#
# [NOTE]
# If the boot process is k2hr3, the options will not be parsed.
#
_UNIT_UPDATE_LOG=0
if [ -z "${K2HR3_RUN_MAIN_PROCESS}" ] || [ "${K2HR3_RUN_MAIN_PROCESS}" != "1" ]; then
	_UTIL_TMP_OPT_COUNT=$#
	_UTIL_TMP_OPT_POS=1
	while [ "${_UTIL_TMP_OPT_COUNT}" -gt 0 ]; do
		_UTIL_TMP_OPT_VALUE=$(eval pecho -n '$'${_UTIL_TMP_OPT_POS})

		if echo "${_UTIL_TMP_OPT_VALUE}" | grep -q -i -e "^-u$" -e "^--update$"; then
			if [ "${_UNIT_UPDATE_LOG}" -ne 0 ]; then
				echo "${CRED}[ERROR] Already set ${_UTIL_TMP_OPT_VALUE} option.${CDEF}"
				exit 1
			fi
			_UNIT_UPDATE_LOG=1
			# shellcheck disable=SC2034
			SUB_TEST_UPDATE_OPT="--update"
		elif [ -n "${_UTIL_TMP_OPT_VALUE}" ]; then
			echo "${CRED}[ERROR] Unknown option : ${_UTIL_TMP_OPT_VALUE}${CDEF}"
			exit 1
		fi

		_UTIL_TMP_OPT_COUNT=$((_UTIL_TMP_OPT_COUNT - 1))
	done

	#
	# Set common options for test to $@
	#
	set -- "--config" "${COMMONDIR}/k2hr3.config" "--apiuri" "http://localhost"
fi

#
# Filter variables
#
TEST_ES_FILTER_OPT="s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"

#---------------------------------------------------------------------
# Clean up temporary files
#---------------------------------------------------------------------
rm -f "${SUB_TEST_LOGFILE}"
rm -f "${SUB_TEST_PART_FILE}"
rm -f "${SUB_TEST_DIFF_FILE}"
rm -f "${_SUB_TEST_TEMP_MASTER_FILE}"
rm -f "${_SUB_TEST_TEMP_PART_FILE}"

#---------------------------------------------------------------------
# Utilitiy functions
#---------------------------------------------------------------------
#
# Update snapshot
#
# $?	: result
#
test_update_snapshot()
{
	if [ "${_UNIT_UPDATE_LOG}" -eq 1 ]; then
		test_prn_msg_mode 1 0 "${_UTIL_SUBTEST_UPDATE_PREFIX}${CBLD}${SUB_TEST_SNAPSHOT_FILE}${CDEF}"

		if [ "${TEST_EXIT_CODE}" -ne 0 ]; then
			test_prn_msg_stdout "    ${CYEL}[WARNING] The test has failed, but I will update the file of comparison.${CDEF}"
		fi
		if [ -f "${SUB_TEST_LOGFILE}" ]; then
			if ! cp -p "${SUB_TEST_LOGFILE}" "${SUB_TEST_SNAPSHOT_FILE}"; then
				test_prn_msg_stdout "-> ${CRED}Failed${CDEF} (Failed to update the master log file)"
				test_prn_msg ""
				return 1
			else
				test_prn_msg_stdout "-> ${CGRN}Success${CDEF}"
				test_prn_msg ""
			fi
		else
			test_prn_msg_stdout "-> ${CRED}Failed${CDEF} (There is no log file of this test result)"
			test_prn_msg ""
			return 1
		fi
	fi
}

#
# Print log message in sub test
#
# $1	: output stdout(1)
# $2	: output log file(1)
# $3	: message
#
# [NOTE]
# Tee is not used for output to the log file to eliminate escape
# sequences. The escape sequence is output to standard output as it
# is.
#
test_prn_msg_mode()
{
	_UTIL_TEST_PRN_LOG_MODE_STDOUT="$1"
	_UTIL_TEST_PRN_LOG_MODE_LOG="$2"
	shift 2
	if [ -n "${_UTIL_TEST_PRN_LOG_MODE_STDOUT}" ] && [ "${_UTIL_TEST_PRN_LOG_MODE_STDOUT}" = "1" ]; then
		echo "$@"
	fi
	if [ -n "${_UTIL_TEST_PRN_LOG_MODE_LOG}" ] && [ "${_UTIL_TEST_PRN_LOG_MODE_LOG}" = "1" ]; then
		echo "$1" | sed -r "${TEST_ES_FILTER_OPT}" >> "${SUB_TEST_LOGFILE}"
	fi
}

#
# Print log message in sub test
#
# $1	: message
#
test_prn_msg_stdout()
{
	test_prn_msg_mode 1 0 "$@"
}

#
# Print log message in sub test
#
# $1	: message
#
test_prn_msg_log()
{
	test_prn_msg_mode 0 1 "$@"
}

#
# Print log message in sub test
#
# $1	: message
#
test_prn_msg()
{
	test_prn_msg_mode 1 1 "$@"
}

#
# Print Title message in sub test
#
# $1	: message
#
# [NOTE]
# Use this function to output the title of the message.
# The title is output with a prefix. This prefix is recognized
# by the comparison function as a log delimiter.
#
test_prn_title()
{
	test_prn_msg_mode 1 1 "${_UTIL_SUBTEST_TITLE_PREFIX}${CBLD}${*}${CDEF}"
}

#
# Print file in sub test
#
# $1	: output stdout(1)
# $2	: output log file(1)
# $3	: file path
#
test_prn_file_mode()
{
	if [ -z "$3" ]; then
		return 1
	fi
	if [ ! -f "$3" ]; then
		return 1
	fi

	if [ -n "$1" ] && [ "$1" = "1" ]; then
		cat "$3"
	fi
	if [ -n "$2" ] && [ "$2" = "1" ]; then
		sed -r "${TEST_ES_FILTER_OPT}" < "$3" >> "${SUB_TEST_LOGFILE}"
	fi
	return 0
}

#
# Print file in sub test
#
# $1	: file path
#
test_prn_file_stdout()
{
	test_prn_file_mode 1 0 "$1"
}

#
# Print file in sub test
#
# $1	: file path
#
test_prn_file_log()
{
	test_prn_file_mode 0 1 "$1"
}

#
# Print file in sub test
#
# $1	: file path
#
test_prn_file()
{
	test_prn_file_mode 1 1 "$1"
}

#
# Make temporary file from snapshot log file
#
# $1	: title(without _UTIL_SUBTEST_TITLE_PREFIX)
# $2	: snapshot log file
# $3	: temporary snapshot part log file(output)
# $?	: result
#
parse_part_log_from_snapshot()
{
	if [ $# -lt 3 ]; then
		return 1
	fi
	_UTIL_PARSE_START_TITLE=$(pecho -n "$1" | sed -r "${TEST_ES_FILTER_OPT}")

	if [ ! -f "$2" ]; then
		return 1
	fi
	_UTIL_PARSE_MASTER_FILE=$2
	_UTIL_PARSE_TEMP_PART_FILE=$3

	#
	# Search target title line
	#
	_UTIL_PARSE_MASTER_START_POS=$(grep -n "^${_UTIL_SUBTEST_TITLE_PREFIX}${_UTIL_PARSE_START_TITLE}" "${_UTIL_PARSE_MASTER_FILE}" | sed 's/:/ /g' | awk '{print $1}' | head -1)
	if [ -z "${_UTIL_PARSE_MASTER_START_POS}" ]; then
		cat /dev/null > "${_UTIL_PARSE_TEMP_PART_FILE}"
	fi
	if ! _UTIL_PARSE_MASTER_START_POS=$((_UTIL_PARSE_MASTER_START_POS + 1)); then
		cat /dev/null > "${_UTIL_PARSE_TEMP_PART_FILE}"
	fi

	#
	# Search next title line and end line
	#
	_UTIL_PARSE_MASTER_TITLE_POS=$(grep -n "^${_UTIL_SUBTEST_TITLE_PREFIX}" "${_UTIL_PARSE_MASTER_FILE}" | sed 's/:/ /g' | awk '{print $1}')
	_UTIL_PARSE_MASTER_END_POS=-1
	for _UTIL_PARSE_POS in ${_UTIL_PARSE_MASTER_TITLE_POS}; do
		if [ -z "${_UTIL_PARSE_POS}" ]; then
			continue
		fi
		if ! is_positive_number "${_UTIL_PARSE_POS}" >/dev/null 2>&1; then
			continue
		fi
		if [ "${_UTIL_PARSE_POS}" -ge "${_UTIL_PARSE_MASTER_START_POS}" ]; then
			#
			# Found next title line
			#
			_UTIL_PARSE_MASTER_END_POS=${_UTIL_PARSE_POS}
			break
		fi
	done
	if [ "${_UTIL_PARSE_MASTER_END_POS}" -lt 0 ]; then
		#
		# Not found -> to end of file
		#
		_UTIL_PARSE_MASTER_END_POS=$(wc -l "${_UTIL_PARSE_MASTER_FILE}" | awk '{print $1}')
		_UTIL_PARSE_MASTER_END_POS=$((_UTIL_PARSE_MASTER_END_POS + 1))
	fi

	#
	# Output part file
	#
	_UTIL_PARSE_MASTER_HEAD_PARAM=$((_UTIL_PARSE_MASTER_END_POS - 1))
	_UTIL_PARSE_MASTER_TAIL_PARAM=$((_UTIL_PARSE_MASTER_END_POS - _UTIL_PARSE_MASTER_START_POS))
	if [ "${_UTIL_PARSE_MASTER_TAIL_PARAM}" -gt 0 ]; then
		head -"${_UTIL_PARSE_MASTER_HEAD_PARAM}" "${_UTIL_PARSE_MASTER_FILE}" | tail -"${_UTIL_PARSE_MASTER_TAIL_PARAM}" > "${_UTIL_PARSE_TEMP_PART_FILE}"
	else
		cat /dev/null > "${_UTIL_PARSE_TEMP_PART_FILE}"
	fi
	return 0
}

#
# Compare part of test log
#
# $@							: title(without _UTIL_SUBTEST_TITLE_PREFIX)
#
# Input Variables
#	SUB_TEST_SNAPSHOT_FILE		: snapshot log file for comparison
#	SUB_TEST_PART_FILE			: Test result log file of the part to be compared
#								  (expect execution result without title)
# Output Variables
#	SUB_TEST_DIFF_FILE			: outputs the diff result when a difference is detected.
#
test_compare_part_log()
{
	cat /dev/null > "${SUB_TEST_DIFF_FILE}"

	if [ $# -lt 1 ]; then
		return 1
	fi
	_UTIL_COMP_PART_START_TITLE="$*"

	#
	# Cut only space line from part file and cur escape sequence
	#
	grep -v '^\s*$' "${SUB_TEST_PART_FILE}" | sed -r "${TEST_ES_FILTER_OPT}" > "${_SUB_TEST_TEMP_PART_FILE}"

	#
	# Cut out only the relevant section from the snapshot log file.
	#
	_SUB_TEST_TEMP2_MASTER_FILE="${_SUB_TEST_TEMP_MASTER_FILE}2"
	parse_part_log_from_snapshot "${_UTIL_COMP_PART_START_TITLE}" "${SUB_TEST_SNAPSHOT_FILE}" "${_SUB_TEST_TEMP2_MASTER_FILE}"
	if [ ! -f "${_SUB_TEST_TEMP2_MASTER_FILE}" ]; then
		cat /dev/null > "${_SUB_TEST_TEMP2_MASTER_FILE}"
	fi
	grep -v '^\s*$' "${_SUB_TEST_TEMP2_MASTER_FILE}" > "${_SUB_TEST_TEMP_MASTER_FILE}"
	rm -f "${_SUB_TEST_TEMP2_MASTER_FILE}"

	#
	# Compare
	#
	diff -U 1 "${_SUB_TEST_TEMP_MASTER_FILE}" "${_SUB_TEST_TEMP_PART_FILE}" | grep -v '^--- ' | grep -v '^+++ ' | sed -e "s/\(^-.*$\)/${CRED}\1${CDEF}/g" -e "s/\(^+.*$\)/${CGRN}\1${CDEF}/g" > "${SUB_TEST_DIFF_FILE}"
	rm -f "${_SUB_TEST_TEMP_MASTER_FILE}" "${_SUB_TEST_TEMP_PART_FILE}"

	_UTIL_COMP_DIFF_COUNT=$(wc -l "${SUB_TEST_DIFF_FILE}" | awk '{print $1}')
	if [ "${_UTIL_COMP_DIFF_COUNT}" -ne 0 ]; then
		return 1
	fi

	cat /dev/null > "${SUB_TEST_DIFF_FILE}"
	return 0
}

#
# Compare part of test log
#
# $1							: test result code
# $2							: test result output file
# $3							: title(without _UTIL_SUBTEST_TITLE_PREFIX)
# $?							: result
#
# Input Variables
#	SUB_TEST_SNAPSHOT_FILE		: snapshot log file for comparison
#	SUB_TEST_PART_FILE			: Test result log file of the part to be compared
#								  (expect execution result without title)
#	SUB_TEST_DIFF_FILE			: outputs the diff result when a difference is detected.
#
test_processing_result()
{
	if [ $# -lt 3 ]; then
		prn_err "(test_processing_result) Paramters are wrong."
		return 1
	fi
	if [ -z "$1" ]; then
		prn_err "(test_processing_result) First paramter is wrong."
		return 1
	fi
	if [ -z "$2" ]; then
		prn_err "(test_processing_result) Second paramter is wrong."
		return 1
	elif [ ! -f "$2" ]; then
		prn_err "(test_processing_result) The result log file is not existed."
		return 1
	fi
	if [ -z "$3" ]; then
		prn_err "(test_processing_result) Third paramter is wrong."
		return 1
	fi
	_TEST_PROC_RESULT="$1"
	_TEST_PROC_OUTPUT_FILE="$2"
	_TEST_PROC_TITLE="$3"
	_TEST_PROC_RESULT=0

	if [ "${_TEST_PROC_RESULT}" -ne 0 ]; then
		_TEST_PROC_RESULT=1
		test_prn_msg_stdout ""
		test_prn_msg_stdout "-> ${CRED}Failed${CDEF} (command failed)"
	else
		#
		# Put result to log file
		#
		test_prn_file_log "${_TEST_PROC_OUTPUT_FILE}"

		#
		# Check result
		#
		if ! test_compare_part_log "${_TEST_PROC_TITLE}"; then
			TEST_EXIT_CODE=1
			test_prn_msg_stdout ""
			test_prn_file_stdout "${SUB_TEST_DIFF_FILE}"
			test_prn_msg_stdout ""
			test_prn_msg_stdout "-> ${CRED}Failed${CDEF}"
		else
			test_prn_msg_stdout "-> ${CGRN}Success${CDEF}"
		fi
		test_prn_msg ""
	fi

	#
	# Cleanup
	#
	rm -f "${SUB_TEST_DIFF_FILE}"
	rm -f "${_TEST_PROC_OUTPUT_FILE}"

	return "${_TEST_PROC_RESULT}"
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
