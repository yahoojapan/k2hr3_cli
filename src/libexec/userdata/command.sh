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

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
_USERDATA_ZIP_MAX_FILESIZE=$((256 * 1024 * 1024))
_USERDATA_UNZIP_MAX_FILESIZE=$((512 * 1024 * 1024))

#--------------------------------------------------------------
# Parse arguments
#--------------------------------------------------------------
#
# Path parameter
#
if ! parse_noprefix_option "$@"; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi
_USERDATA_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
#
# GET USERDATA
#

#
# Check curlbody option
#
if [ -n "${K2HR3CLI_OPT_CURLBODY}" ] && [ "${K2HR3CLI_OPT_CURLBODY}" = "1" ]; then
	prn_warn "\"${K2HR3CLI_COMMON_OPT_CURLBODY_LONG}(${K2HR3CLI_COMMON_OPT_CURLBODY_SHORT})\" option is specified, but this command can not display curl body data which is binary data. Then this option is ignored."
	K2HR3CLI_OPT_CURLBODY=0
fi

#
# Request
#
_USERDATA_URL_PATH="/v1/userdata/${_USERDATA_PATH}"
get_request "${_USERDATA_URL_PATH}" 1 "User-Agent:Cloud-Init\\s0.7.9" "Accept-Encoding:gzip"
_USERDATA_REQUEST_RESULT=$?

#
# Check result
#
if [ ! -f "${K2HR3CLI_REQUEST_RESULT_FILE}" ] || [ -L "${K2HR3CLI_REQUEST_RESULT_FILE}" ]; then
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
	return 1
fi
if ! requtil_check_result "${_USERDATA_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${K2HR3CLI_REQUEST_RESULT_FILE}" "200" 1; then
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
	exit 1
fi

#
# Result
#
if [ -z "${K2HR3CLI_OPT_OUTPUT}" ]; then
	#
	# Copy result to temporary file
	#
	_RESULT_GZIP_FILESIZE=$(wc -c < "${K2HR3CLI_REQUEST_RESULT_FILE}" | tr -d '[:space:]')
	if [ -z "${_RESULT_GZIP_FILESIZE}" ] || [ "${_RESULT_GZIP_FILESIZE}" -gt "${_USERDATA_ZIP_MAX_FILESIZE}" ]; then
		prn_err 'Gzip response size exceeds limit(%s bytes)\n' "${_USERDATA_ZIP_MAX_FILESIZE}" >&2
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi

	_USERDATA_UNZIP_TMP_FILE=$(mktemp "/tmp/.${BINNAME}_$$_XXXXXXXX_userdata.result") || return 1
	_USERDATA_ZIP_TMP_FILE="${_USERDATA_UNZIP_TMP_FILE}.gz"
	_USERDATA_READ_LIMIT=$((_USERDATA_UNZIP_MAX_FILESIZE + 1))

	if ! cp "${K2HR3CLI_REQUEST_RESULT_FILE}" "${_USERDATA_ZIP_TMP_FILE}"; then
		prn_err "The command succeeded, but failed to output the result to a temporary file. Please check the output file path, permissions, etc."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	if ! gzip -dc "${_USERDATA_ZIP_TMP_FILE}" 2>/dev/null | head -c "${_USERDATA_READ_LIMIT}" > "${_USERDATA_UNZIP_TMP_FILE}" 2>/dev/null; then
		prn_err "Failed to unzip a temporary result file."
		rm -f "${_USERDATA_ZIP_TMP_FILE}"
		rm -f "${_USERDATA_UNZIP_TMP_FILE}"
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	if [ ! -f "${_USERDATA_UNZIP_TMP_FILE}" ] || [ -L "${_USERDATA_UNZIP_TMP_FILE}" ]; then
		prn_err "Failed to unzip a temporary result file."
		rm -f "${_USERDATA_ZIP_TMP_FILE}"
		rm -f "${_USERDATA_UNZIP_TMP_FILE}"
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	_USERDATA_UNZIP_TMP_FILESIZE=$(wc -c < "${_USERDATA_UNZIP_TMP_FILE}" | tr -d '[:space:]')
	if [ -z "${_USERDATA_UNZIP_TMP_FILESIZE}" ] || [ "${_USERDATA_UNZIP_TMP_FILESIZE}" -gt "${_USERDATA_UNZIP_MAX_FILESIZE}" ]; then
		prn_err "Unzip temporary file size is over limit."
		rm -f "${_USERDATA_ZIP_TMP_FILE}"
		rm -f "${_USERDATA_UNZIP_TMP_FILE}"
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi

	#
	# Print unzip contents
	#
	cat "${_USERDATA_UNZIP_TMP_FILE}"

	rm -f "${_USERDATA_UNZIP_TMP_FILE}"
	rm -f "${_USERDATA_ZIP_TMP_FILE}"
else
	#
	# Copy result to output file
	#
	if ! cp "${K2HR3CLI_REQUEST_RESULT_FILE}" "${K2HR3CLI_OPT_OUTPUT}"; then
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
