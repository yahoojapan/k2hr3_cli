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

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
_EXTDATA_UNZIP_TMP_FILE="/tmp/.${BINNAME}_$$_userdata.result"
_EXTDATA_ZIP_TMP_FILE="${_EXTDATA_UNZIP_TMP_FILE}.gz"

#--------------------------------------------------------------
# Parse arguments
#--------------------------------------------------------------
#
# Path parameter
#
parse_noprefix_option "$@"
if [ $? -ne 0 ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the extdata name, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the extdata name, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
_EXTDATA_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# Register Path parameter
#
parse_noprefix_option "$@"
if [ $? -ne 0 ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the register path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the register path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
_EXTDATA_REGISTER_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# User Agent parameter
#
parse_noprefix_option "$@"
if [ $? -ne 0 ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the user-agent, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the user-agent, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
_EXTDATA_USERAGENT="${K2HR3CLI_OPTION_NOPREFIX}"
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
#
# GET EXTDATA
#

#
# Check curlbody option
#
if [ "X${K2HR3CLI_OPT_CURLBODY}" = "X1" ]; then
	prn_warn "\"${K2HR3CLI_COMMON_OPT_CURLBODY_LONG}(${K2HR3CLI_COMMON_OPT_CURLBODY_SHORT})\" option is specified, but this command can not display curl body data which is binary data. Then this option is ignored."
	K2HR3CLI_OPT_CURLBODY=0
fi

#
# Escape Space in User Agnet
#
_EXTDATA_USERAGENT=$(pecho -n "${_EXTDATA_USERAGENT}" | sed 's/ /\\s/g')

#
# Request
#
_EXTDATA_URL_PATH="/v1/extdata/${_EXTDATA_PATH}/${_EXTDATA_REGISTER_PATH}"
get_request "${_EXTDATA_URL_PATH}" 1 "User-Agent:${_EXTDATA_USERAGENT}" "Accept-Encoding:gzip"
_EXTDATA_REQUEST_RESULT=$?

#
# Check result
#
requtil_check_result "${_EXTDATA_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${K2HR3CLI_REQUEST_RESULT_FILE}" "200" 1
if [ $? -ne 0 ]; then
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
	exit 1
fi

#
# Result
#
if [ "X${K2HR3CLI_OPT_OUTPUT}" = "X" ]; then
	#
	# Copy result to temporary file
	#
	cp "${K2HR3CLI_REQUEST_RESULT_FILE}" "${_EXTDATA_ZIP_TMP_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "The command succeeded, but failed to output the result to a temporary file. Please check the output file path, permissions, etc."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	gzip -f -d "${_EXTDATA_ZIP_TMP_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to unzip a temporary result file."
		rm -f "${_EXTDATA_ZIP_TMP_FILE}"
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	if [ ! -f "${_EXTDATA_UNZIP_TMP_FILE}" ]; then
		prn_err "Failed to unzip a temporary result file."
		rm -f "${_EXTDATA_ZIP_TMP_FILE}"
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	#
	# Print unzip contents
	#
	cat "${_EXTDATA_UNZIP_TMP_FILE}"

	rm -f "${_EXTDATA_UNZIP_TMP_FILE}"
	rm -f "${_EXTDATA_ZIP_TMP_FILE}"
else
	#
	# Copy result to output file
	#
	cp "${K2HR3CLI_REQUEST_RESULT_FILE}" "${K2HR3CLI_OPT_OUTPUT}"
	if [ $? -ne 0 ]; then
		prn_err "The command succeeded, but failed to output the result to a file. Please check the output file path, permissions, etc."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
fi
rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

#
# Display
#
prn_msg "${CGRN}Succeed${CDEF} : Get Userdata to ${K2HR3CLI_OPT_OUTPUT} file"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
