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
# Parse arguments
#--------------------------------------------------------------
#
# Sub-command
#
if ! parse_noprefix_option "$@"; then
	exit 1
fi
if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
	K2HR3CLI_SUBCOMMAND=""
else
	K2HR3CLI_SUBCOMMAND=${K2HR3CLI_OPTION_NOPREFIX}
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# Other options
#
if [ $# -gt 0 ]; then
	#
	# The VERSION command does not require any options other than the Common option.
	#
	_VERSION_WRONG_OPTS=$(cut_special_words "$*" | sed -e 's/%20/ /g' -e 's/%25/%/g')
	prn_err "Unknown options(\"${_VERSION_WRONG_OPTS}\") for ${K2HR3CLI_MODE} command."
	exit 1
fi

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
	#
	# VERSION API - GET(/)
	#
	get_request "/" 1 ""
	_VERSION_REQUEST_RESULT=$?

	#
	# Parse response body
	#
	if ! jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check Result
	#
	if ! requtil_check_result "${_VERSION_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Success
	#
	if ! jsonparser_dump_parsed_file "${JP_PAERSED_FILE}"; then
		prn_err "Failed to display result."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

else
	#
	# VERSION API - GET(/<version number>)
	#
	get_request "/${K2HR3CLI_SUBCOMMAND}" 1 ""
	_VERSION_REQUEST_RESULT=$?

	#
	# Parse response body
	#
	if ! jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check Result
	#
	if ! requtil_check_result "${_VERSION_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Success
	#
	if ! jsonparser_dump_parsed_file "${JP_PAERSED_FILE}"; then
		prn_err "Failed to display result."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"
fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
