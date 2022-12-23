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
TESTMAINBIN=$(basename "$0")
TESTMAINBASENAME=$(echo "${TESTMAINBIN}" | sed 's/[.]sh$//')

TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${TESTDIR}" || exit 1; pwd)
SRCDIR=$(cd "${TESTDIR}"/../src || exit 1; pwd)
# shellcheck disable=SC2034
LIBEXECDIR=$(cd "${SRCDIR}"/libexec || exit 1; pwd)

TEST_ALL_LOGFILE="${TESTDIR}/${TESTMAINBASENAME}.log"
TEST_EXTCODE_FILE="/tmp/.${TESTMAINBASENAME}.exitcode"
TEST_SUMMARY_FILE="${TESTDIR}/${TESTMAINBASENAME}.summary.log"

#
# Sub Test files
#
# The test file is a file with the "test_" prefix and the ".sh" suffix.
#
TEST_FILES=""
for _TEST_FILE_TMP in "${TESTDIR}"/*; do
	_TEST_FILE_TMP=$(echo "${_TEST_FILE_TMP}" | sed "s#^${TESTDIR}/##g")
	case ${_TEST_FILE_TMP} in
		"${TESTMAINBIN}")
			;;
		test_*.sh)
			if [ -z "${TEST_FILES}" ]; then
				TEST_FILES=${_TEST_FILE_TMP}
			else
				TEST_FILES="${TEST_FILES} ${_TEST_FILE_TMP}"
			fi
			;;
		*)
			;;
	esac
done

#
# Load utility file for test
#
# [NOTE]
# All unit test scripts need to read the following files.
# Please use the log file, master log file, and function specified
# in the following files.
#
UTIL_TESTFILE="util_test.sh"
if [ -f "${TESTDIR}/${UTIL_TESTFILE}" ]; then
	. "${TESTDIR}/${UTIL_TESTFILE}"
fi

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------
func_usage()
{
	echo ""
	echo "Usage: ${TESTMAINBIN} [option...]"
	echo "	     --update(-u)   update the test result comparison file with the current test result."
	echo "	     --help(-h)     print help."
	echo ""
}

#---------------------------------------------------------------------
# Test all
#---------------------------------------------------------------------
#
# Header
#
echo ""
echo "K2HR3 CLI TEST ($(date -R))" | tee "${TEST_ALL_LOGFILE}"
echo "" | tee -a "${TEST_ALL_LOGFILE}"

#
# Summary file
#
echo "${CREV}[Summary]${CDEF} K2HR3 CLI TEST" > "${TEST_SUMMARY_FILE}"
echo "" >> "${TEST_SUMMARY_FILE}"

#
# Test all
#
ALL_TEST_RESULT=0

for SUBTESTBIN in ${TEST_FILES}; do
	#
	# Title
	#
	SUBTEST_TITLE=$(echo "${SUBTESTBIN}" | sed -e 's/^test_//g' -e 's/[.]sh$//g' | tr '[:lower:]' '[:upper:]')

	#
	# Clear exit code file
	#
	rm -f "${TEST_EXTCODE_FILE}"

	#
	# Run test
	#
	echo "${CREV}[${SUBTEST_TITLE}]${CDEF}:" | tee -a "${TEST_ALL_LOGFILE}"
	("${TESTDIR}/${SUBTESTBIN}" "${SUB_TEST_UPDATE_OPT}"; echo $? > "${TEST_EXTCODE_FILE}") | stdbuf -oL -eL sed -e 's/^/     /' | tee -a "${TEST_ALL_LOGFILE}"

	#
	# Result
	#
	if [ -f "${TEST_EXTCODE_FILE}" ]; then
		SUBTEST_RESULT=$(cat "${TEST_EXTCODE_FILE}")
		if ! compare_part_string "${SUBTEST_RESULT}" >/dev/null 2>&1; then
			echo "     ${CYEL}(error) ${TESTMAINBIN} : result code for ${SUBTEST_TITLE} is wrong(${SUBTEST_RESULT}).${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
			SUBTEST_RESULT=1
		fi
		rm -f "${TEST_EXTCODE_FILE}"
	else
		echo "     ${CYEL}(error) ${TESTMAINBIN} : result code file for ${SUBTEST_TITLE} is not existed.${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
		SUBTEST_RESULT=1
	fi

	if [ "${SUBTEST_RESULT}" -eq 0 ]; then
		echo "  => ${CGRN}Succeed${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
	else
		ALL_TEST_RESULT=1
		echo "  => ${CRED}Failure${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
	fi
	echo "" | tee -a "${TEST_ALL_LOGFILE}"

	#
	# Add Summary
	#
	if [ "${SUBTEST_RESULT}" -eq 0 ]; then
		echo "  ${CGRN}PASS${CDEF} : ${SUBTEST_TITLE}" >> "${TEST_SUMMARY_FILE}"
	else
		echo "  ${CRED}FAIL${CDEF} : ${SUBTEST_TITLE}" >> "${TEST_SUMMARY_FILE}"
	fi
done

#
# Print Summary
#
if [ -f "${TEST_SUMMARY_FILE}" ]; then
	tee -a "${TEST_ALL_LOGFILE}" < "${TEST_SUMMARY_FILE}"
	rm -f "${TEST_SUMMARY_FILE}"
fi

#
# Result(Footer)
#
echo "" | tee -a "${TEST_ALL_LOGFILE}"
if [ "${ALL_TEST_RESULT}" -eq 0 ]; then
	echo "All Test ${CGRN}PASSED${CDEF} ($(date -R))" | tee -a "${TEST_ALL_LOGFILE}"
else
	echo "All Test ${CRED}FAILED${CDEF} ($(date -R))" | tee -a "${TEST_ALL_LOGFILE}"
fi
echo ""

exit "${ALL_TEST_RESULT}"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
