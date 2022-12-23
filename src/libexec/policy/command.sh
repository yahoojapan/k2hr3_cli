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
#
# SubCommand(2'nd option)
#
_POLICY_COMMAND_SUB_CREATE="create"
_POLICY_COMMAND_SUB_SHOW="show"
_POLICY_COMMAND_SUB_DELETE="delete"

#--------------------------------------------------------------
# Parse arguments
#--------------------------------------------------------------
#
# Sub Command
#
if ! parse_noprefix_option "$@"; then
	exit 1
fi
if [ -z "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
	K2HR3CLI_SUBCOMMAND=""
else
	#
	# Always using lower case
	#
	K2HR3CLI_SUBCOMMAND=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
#
# Get Scoped Token
#
if ! complement_scoped_token; then
	exit 1
fi
prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_POLICY_COMMAND_SUB_CREATE}, ${_POLICY_COMMAND_SUB_SHOW} or ${_POLICY_COMMAND_SUB_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_POLICY_COMMAND_SUB_CREATE}" ]; then
	#
	# POLICY CREATE
	#

	#
	# Get policy name(or path)
	#
	_POLICY_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the policy name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_POLICY_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_POLICY_URL_ARGS="?name=${_POLICY_PATH}"
	_POLICY_URL_ARGS=$(requtil_urlarg_effect_param "${_POLICY_URL_ARGS}" 1)
	_POLICY_URL_ARGS=$(requtil_urlarg_action_param "${_POLICY_URL_ARGS}")
	_POLICY_URL_ARGS=$(requtil_urlarg_resource_param "${_POLICY_URL_ARGS}" 1)
	_POLICY_URL_ARGS=$(requtil_urlarg_alias_param "${_POLICY_URL_ARGS}" 1)

	_POLICY_URL_PATH="/v1/policy${_POLICY_URL_ARGS}"
	put_request "${_POLICY_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_POLICY_REQUEST_RESULT=$?

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
	# Check result
	#
	if ! requtil_check_result "${_POLICY_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Create \"${_POLICY_PATH}\" Policy"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_POLICY_COMMAND_SUB_SHOW}" ]; then
	#
	# POLICY SHOW
	#

	#
	# Get policy name(or path)
	#
	_POLICY_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the policy name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_POLICY_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_POLICY_URL_ARGS=""
	_POLICY_URL_ARGS=$(requtil_urlarg_service_param "${_POLICY_URL_ARGS}")

	_POLICY_URL_PATH="/v1/policy/${_POLICY_PATH}${_POLICY_URL_ARGS}"
	get_request "${_POLICY_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_POLICY_REQUEST_RESULT=$?

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
	# Check result
	#
	if ! requtil_check_result "${_POLICY_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Display policy value in json
	#
	if ! jsonparser_dump_key_parsed_file '%' '"policy"' "${JP_PAERSED_FILE}"; then
		prn_err "Failed to get \"policy\" element in response."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_POLICY_COMMAND_SUB_DELETE}" ]; then
	#
	# POLICY DELETE
	#

	#
	# Get policy name(or path)
	#
	_POLICY_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the policy name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_POLICY_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_POLICY_URL_PATH="/v1/policy/${_POLICY_PATH}"
	delete_request "${_POLICY_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_POLICY_REQUEST_RESULT=$?

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
	# Check result
	#
	if ! requtil_check_result "${_POLICY_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Delete \"${_POLICY_PATH}\" Policy"

else
	prn_err "Unknown subcommand(\"${K2HR3CLI_SUBCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
