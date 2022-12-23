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
_ROLE_COMMAND_SUB_CREATE="create"
_ROLE_COMMAND_SUB_SHOW="show"
_ROLE_COMMAND_SUB_DELETE="delete"
_ROLE_COMMAND_SUB_HOST="host"
_ROLE_COMMAND_SUB_TOKEN="token"

#
# Other Command(3'rd option)
#
_ROLE_COMMAND_SUB2_ADD="add"
_ROLE_COMMAND_SUB2_DELETE="delete"
_ROLE_COMMAND_SUB2_CREATE="create"
_ROLE_COMMAND_SUB2_SHOW="show"
_ROLE_COMMAND_SUB2_CHECK="check"

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

#
# Other Command(3'rd command)
#
K2HR3CLI_OTHERCOMMAND=""
if [ -n "${K2HR3CLI_SUBCOMMAND}" ]; then
	if [ "${K2HR3CLI_SUBCOMMAND}" = "${_ROLE_COMMAND_SUB_HOST}" ] || [ "${K2HR3CLI_SUBCOMMAND}" = "${_ROLE_COMMAND_SUB_TOKEN}" ]; then
		if ! parse_noprefix_option "$@"; then
			exit 1
		fi
		if [ -n "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
			#
			# Always using lower case
			#
			K2HR3CLI_OTHERCOMMAND=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}
	fi
fi

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
#
# Get Scoped Token
#
if [ -z "${K2HR3CLI_SUBCOMMAND}" ] || { [ "${K2HR3CLI_SUBCOMMAND}" != "${_ROLE_COMMAND_SUB_TOKEN}" ] && [ "${K2HR3CLI_OTHERCOMMAND}" != "${_ROLE_COMMAND_SUB2_CHECK}" ]; }; then
	if ! complement_scoped_token; then
		exit 1
	fi
	prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"
fi

if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_ROLE_COMMAND_SUB_CREATE}, ${_ROLE_COMMAND_SUB_SHOW}, ${_ROLE_COMMAND_SUB_DELETE}, ${_ROLE_COMMAND_SUB_HOST} or ${_ROLE_COMMAND_SUB_TOKEN}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_ROLE_COMMAND_SUB_CREATE}" ]; then
	#
	# ROLE CREATE
	#

	#
	# Get role name(or path)
	#
	_ROLE_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_ROLE_NAME_TMP=$(k2hr3cli_urlencode "${_ROLE_PATH}")
	_ROLE_URL_ARGS="?name=${_ROLE_NAME_TMP}"
	_ROLE_URL_ARGS=$(requtil_urlarg_policies_param "${_ROLE_URL_ARGS}" 1)
	_ROLE_URL_ARGS=$(requtil_urlarg_alias_param "${_ROLE_URL_ARGS}" 1)

	_ROLE_URL_PATH="/v1/role${_ROLE_URL_ARGS}"
	put_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_ROLE_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Create \"${_ROLE_PATH}\" Role"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_ROLE_COMMAND_SUB_SHOW}" ]; then
	#
	# ROLE SHOW
	#

	#
	# Get role name(or path)
	#
	_ROLE_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_ROLE_URL_ARGS=""
	_ROLE_URL_ARGS=$(requtil_urlarg_expand_param "${_ROLE_URL_ARGS}")

	_ROLE_URL_PATH="/v1/role/${_ROLE_PATH}${_ROLE_URL_ARGS}"
	get_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_ROLE_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Display role value in json
	#
	if ! jsonparser_dump_key_parsed_file '%' '"role"' "${JP_PAERSED_FILE}"; then
		prn_err "Failed to get \"role\" element in response."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_ROLE_COMMAND_SUB_DELETE}" ]; then
	#
	# ROLE DELETE
	#

	#
	# Get role name(or path)
	#
	_ROLE_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_ROLE_URL_PATH="/v1/role/${_ROLE_PATH}"
	delete_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_ROLE_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Delete \"${_ROLE_PATH}\" Role"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_ROLE_COMMAND_SUB_HOST}" ]; then
	#
	# HOST(role member)
	#
	if [ -z "${K2HR3CLI_OTHERCOMMAND}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must also specify the parameter(${_ROLE_COMMAND_SUB2_ADD} or ${_ROLE_COMMAND_SUB2_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ROLE_COMMAND_SUB2_ADD}" ]; then
		#
		# HOST ADD
		#

		#
		# Get role name(or path)
		#
		_ROLE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ROLE_URL_ARGS=""
		_ROLE_URL_ARGS=$(requtil_urlarg_host_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_port_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_cuk_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_extra_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_tag_param "${_ROLE_URL_ARGS}")

		_ROLE_URL_PATH="/v1/role/${_ROLE_PATH}${_ROLE_URL_ARGS}"
		put_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_ROLE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Add \"${K2HR3CLI_OPT_HOST}\" to \"${_ROLE_PATH}\" member"

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ROLE_COMMAND_SUB2_DELETE}" ]; then
		#
		# HOST DELETE
		#

		#
		# Get role name(or path)
		#
		_ROLE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ROLE_URL_ARGS=""
		_ROLE_URL_ARGS=$(requtil_urlarg_host_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_port_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_cuk_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_extra_param "${_ROLE_URL_ARGS}")
		_ROLE_URL_ARGS=$(requtil_urlarg_tag_param "${_ROLE_URL_ARGS}")

		_ROLE_URL_PATH="/v1/role/${_ROLE_PATH}${_ROLE_URL_ARGS}"
		delete_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_ROLE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Delete \"${K2HR3CLI_OPT_HOST}\" from \"${_ROLE_PATH}\" member"

	else
		prn_err "Unknown parameter(\"${K2HR3CLI_OTHERCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_ROLE_COMMAND_SUB_TOKEN}" ]; then
	#
	# TOKEN(role token)
	#
	if [ -z "${K2HR3CLI_OTHERCOMMAND}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must also specify the parameter(${_ROLE_COMMAND_SUB2_ADD}, ${_ROLE_COMMAND_SUB2_CREATE}, ${_ROLE_COMMAND_SUB2_DELETE}, ${_ROLE_COMMAND_SUB2_SHOW} or ${_ROLE_COMMAND_SUB2_CHECK}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ROLE_COMMAND_SUB2_CREATE}" ]; then
		#
		# TOKEN CREATE
		#
		if ! complement_scoped_token; then
			exit 1
		fi
		prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

		#
		# Get role name(or path)
		#
		_ROLE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ROLE_URL_ARGS=""
		_ROLE_URL_ARGS=$(requtil_urlarg_expire_param "${_ROLE_URL_ARGS}")

		_ROLE_URL_PATH="/v1/role/token/${_ROLE_PATH}${_ROLE_URL_ARGS}"
		get_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_ROLE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi

		#
		# Check token value in json
		#
		if ! jsonparser_get_key_value '%"token"%' "${JP_PAERSED_FILE}"; then
			prn_err "Failed to get \"token\" element in response."
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		_ROLE_TOKEN="${JSONPARSER_FIND_STR_VAL}"

		#
		# Check registerpath value in json
		#
		if ! jsonparser_get_key_value '%"registerpath"%' "${JP_PAERSED_FILE}"; then
			prn_err "Failed to get \"registerpath\" element in response."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			exit 1
		fi
		_ROLE_REGISTERPATH="${JSONPARSER_FIND_STR_VAL}"

		rm -f "${JP_PAERSED_FILE}"

		#
		# Make result json string
		#
		_ROLE_TOKEN_RESULT="{\"token\":\"${_ROLE_TOKEN}\",\"registerpath\":\"${_ROLE_REGISTERPATH}\"}"

		#
		# Display
		#
		if ! jsonparser_dump_string "${_ROLE_TOKEN_RESULT}"; then
			prn_err "Failed to display role token information."
			exit 1
		fi

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ROLE_COMMAND_SUB2_DELETE}" ]; then
		#
		# TOKEN DELETE
		#
		if ! complement_scoped_token; then
			exit 1
		fi
		prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

		#
		# Get first parameter
		#
		_ROLE_TOKEN=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify role token, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ROLE_TOKEN="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ROLE_URL_PATH="/v1/role/token/${_ROLE_TOKEN}"
		delete_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_ROLE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Delete Role Token : \"${_ROLE_TOKEN}\""

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ROLE_COMMAND_SUB2_SHOW}" ]; then
		#
		# TOKEN SHOW
		#
		if ! complement_scoped_token; then
			exit 1
		fi
		prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

		#
		# Get role name(or path)
		#
		_ROLE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ROLE_URL_ARGS=""
		_ROLE_URL_ARGS=$(requtil_urlarg_expand_param "${_ROLE_URL_ARGS}")

		_ROLE_URL_PATH="/v1/role/token/list/${_ROLE_PATH}${_ROLE_URL_ARGS}"
		get_request "${_ROLE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_ROLE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi

		#
		# Display tokens value in json
		#
		if ! jsonparser_dump_key_parsed_file '%' '"tokens"' "${JP_PAERSED_FILE}"; then
			prn_err "Failed to get \"tokens\" element in response."
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ROLE_COMMAND_SUB2_CHECK}" ]; then
		#
		# TOKEN CEHCK
		#

		#
		# Get role name(or path)
		#
		_ROLE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the role name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ROLE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# Get role token
		#
		_ROLE_TOKEN=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the role token, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ROLE_TOKEN="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ROLE_URL_PATH="/v1/role/${_ROLE_PATH}"
		head_request "${_ROLE_URL_PATH}" 1 "x-auth-token:R=${_ROLE_TOKEN}"
		_ROLE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ROLE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Role Token \"${_ROLE_TOKEN}\" for \"${_ROLE_PATH}\" Role"

	else
		prn_err "Unknown parameter(\"${K2HR3CLI_OTHERCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

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
