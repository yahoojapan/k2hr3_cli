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
_SERVICE_COMMAND_SUB_CREATE="create"
_SERVICE_COMMAND_SUB_SHOW="show"
_SERVICE_COMMAND_SUB_DELETE="delete"
_SERVICE_COMMAND_SUB_TENANT="tenant"
_SERVICE_COMMAND_SUB_VERIFY="verify"
_SERVICE_COMMAND_SUB_MEMBER="member"

#
# Other Command(3'rd option)
#
_SERVICE_COMMAND_SUB2_ADD="add"
_SERVICE_COMMAND_SUB2_DELETE="delete"
_SERVICE_COMMAND_SUB2_CHECK="check"
_SERVICE_COMMAND_SUB2_UPDATE="update"
_SERVICE_COMMAND_SUB2_CLEAR="clear"

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
	if [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_TENANT}" ] || [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_VERIFY}" ] || [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_MEMBER}" ]; then
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
if ! complement_scoped_token; then
	exit 1
fi
prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_SERVICE_COMMAND_SUB_CREATE}, ${_SERVICE_COMMAND_SUB_SHOW}, ${_SERVICE_COMMAND_SUB_DELETE}, ${_SERVICE_COMMAND_SUB_TENANT} or ${_SERVICE_COMMAND_SUB_VERIFY}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_CREATE}" ]; then
	#
	# SERVICE CREATE
	#

	#
	# Get service name(or path)
	#
	_SERVICE_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_SERVICE_URL_ARGS="?name=${_SERVICE_PATH}"
	_SERVICE_URL_ARGS=$(requtil_urlarg_verify_param "${_SERVICE_URL_ARGS}")

	_SERVICE_URL_PATH="/v1/service${_SERVICE_URL_ARGS}"
	put_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_SERVICE_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Create \"${_SERVICE_PATH}\" Service"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_SHOW}" ]; then
	#
	# SERVICE SHOW
	#

	#
	# Get service name(or path)
	#
	_SERVICE_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}"
	get_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_SERVICE_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Display service value in json
	#
	if ! jsonparser_dump_key_parsed_file '%' '"service"' "${JP_PAERSED_FILE}"; then
		prn_err "Failed to get \"service\" element in response."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_DELETE}" ]; then
	#
	# SERVICE DELETE
	#

	#
	# Get service name(or path)
	#
	_SERVICE_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}"
	delete_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_SERVICE_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Delete \"${_SERVICE_PATH}\" Service"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_TENANT}" ]; then
	#
	# TENANT
	#
	if [ -z "${K2HR3CLI_OTHERCOMMAND}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must also specify the parameter(${_SERVICE_COMMAND_SUB2_ADD}, ${_SERVICE_COMMAND_SUB2_CHECK} or ${_SERVICE_COMMAND_SUB2_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_SERVICE_COMMAND_SUB2_ADD}" ]; then
		#
		# TENANT ADD
		#

		#
		# Get service name(or path)
		#
		_SERVICE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# Get tenant
		#
		_SERVICE_TENANT=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the tenant, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_TENANT="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_SERVICE_TENANT_ESCAPED=$(k2hr3cli_urlencode "${_SERVICE_TENANT}")
		_SERVICE_URL_ARGS="?tenant=${_SERVICE_TENANT_ESCAPED}"
		_SERVICE_URL_ARGS=$(requtil_urlarg_clear_tenant_param "${_SERVICE_URL_ARGS}")

		_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}${_SERVICE_URL_ARGS}"
		put_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_SERVICE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Add \"${_SERVICE_TENANT}\" tenant to \"${_SERVICE_PATH}\" Service"

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_SERVICE_COMMAND_SUB2_CHECK}" ]; then
		#
		# TENANT CHECK
		#

		#
		# Get service name(or path)
		#
		_SERVICE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# Get tenant
		#
		_SERVICE_TENANT=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the tenant, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_TENANT="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_SERVICE_URL_ARGS="?tenant=${_SERVICE_TENANT}"

		_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}${_SERVICE_URL_ARGS}"
		head_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_SERVICE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : \"${_SERVICE_TENANT}\" is \"${_SERVICE_PATH}\" Service member"

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_SERVICE_COMMAND_SUB2_DELETE}" ]; then
		#
		# TENANT DELETE
		#

		#
		# Get service name(or path)
		#
		_SERVICE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# Get tenant
		#
		_SERVICE_TENANT=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the tenant, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_TENANT="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# (1) Request (Get all service data)
		#
		_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}"
		get_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_SERVICE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi

		#
		# Get member tenant list(array)
		#
		if ! jsonparser_get_key_value '%"service"%"tenant"%' "${JP_PAERSED_FILE}"; then
			prn_err "Failed to get \"service\"->\"tenant\" element in response."
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		prn_dbg "service->tenant information(${JSONPARSER_FIND_VAL})"

		#
		# Make new tenant list without target tenant
		#
		_SERVICE_REST_MEMBERS_ARR="["
		_SERVICE_REST_MEMBERS_ISSET=0
		_SERVICE_TENANT_MEMBER_POS=${JSONPARSER_FIND_KEY_VAL}
		for _SERVICE_MEMBERS_ARR_POS in ${_SERVICE_TENANT_MEMBER_POS}; do
			_SERVICE_MEMBERS_ARR_POS_RAW=$(pecho -n "${_SERVICE_MEMBERS_ARR_POS}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')

			if jsonparser_get_key_value '%"service"%"tenant"%' "${_SERVICE_MEMBERS_ARR_POS_RAW}" "${JP_PAERSED_FILE}"; then
				if [ -n "${JSONPARSER_FIND_VAL_TYPE}" ] && [ -n "${JP_TYPE_STR}" ] && [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_STR}" ]; then
					if pecho -n "${JSONPARSER_FIND_VAL}" | grep -q "${_SERVICE_TENANT}$"; then
						#
						# Found target tenant name
						#
						continue
					fi

					if [ "${_SERVICE_REST_MEMBERS_ISSET}" -ne 0 ]; then
						_SERVICE_REST_MEMBERS_ARR="${_SERVICE_REST_MEMBERS_ARR},${JSONPARSER_FIND_VAL}"
					else
						_SERVICE_REST_MEMBERS_ARR="${_SERVICE_REST_MEMBERS_ARR}${JSONPARSER_FIND_VAL}"
						_SERVICE_REST_MEMBERS_ISSET=1
					fi
				fi
			fi
		done
		_SERVICE_REST_MEMBERS_ARR="${_SERVICE_REST_MEMBERS_ARR}]"
		prn_dbg "service tenant member without target tenant(${_SERVICE_REST_MEMBERS_ARR})"

		rm -f "${JP_PAERSED_FILE}"

		#
		# Set tenant url arguments
		#
		if [ "${_SERVICE_REST_MEMBERS_ISSET}" -eq 0 ]; then
			#
			# Clear all tenant member
			#
			_SERVICE_URL_ARGS="?clear_tenant=true"
		else
			#
			# Update tenant member
			#
			_SERVICE_REST_MEMBERS_ESCAPED=$(k2hr3cli_urlencode "${_SERVICE_REST_MEMBERS_ARR}")
			_SERVICE_URL_ARGS="?tenant=${_SERVICE_REST_MEMBERS_ESCAPED}&clear_tenant=true"
		fi

		_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}${_SERVICE_URL_ARGS}"
		put_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_SERVICE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Delete \"${_SERVICE_TENANT}\" from \"${_SERVICE_PATH}\" Service"

	else
		prn_err "Unknown parameter(\"${K2HR3CLI_OTHERCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_VERIFY}" ]; then
	#
	# VERIFY
	#
	if [ -z "${K2HR3CLI_OTHERCOMMAND}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must also specify the parameter(${_SERVICE_COMMAND_SUB2_UPDATE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_SERVICE_COMMAND_SUB2_UPDATE}" ]; then
		#
		# VERIFY UPDATE
		#

		#
		# Get service name(or path)
		#
		_SERVICE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# Get verify url
		#
		_SERVICE_VERIFY=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the verify url, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_VERIFY="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_SERVICE_VERIFY_ESCAPED=$(k2hr3cli_urlencode "${_SERVICE_VERIFY}")
		_SERVICE_URL_ARGS="?verify=${_SERVICE_VERIFY_ESCAPED}"

		_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}${_SERVICE_URL_ARGS}"
		put_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_SERVICE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Update \"${_SERVICE_VERIFY}\" verify url in \"${_SERVICE_PATH}\" Service"

	else
		prn_err "Unknown parameter(\"${K2HR3CLI_OTHERCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_SERVICE_COMMAND_SUB_MEMBER}" ]; then
	#
	# MEMBER
	#
	if [ -z "${K2HR3CLI_OTHERCOMMAND}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must also specify the parameter(${_SERVICE_COMMAND_SUB2_CLEAR}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_OTHERCOMMAND}" = "${_SERVICE_COMMAND_SUB2_CLEAR}" ]; then
		#
		# CLEAR MEMBER'S SERVICE
		#
		_SERVICE_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		# [TODO]
		# It should be confirmed whether the specified tenant(member) is included
		# in the scoped tenant of this Scoped Token.
		#

		#
		# Get member tenant
		#
		_SERVICE_TENANT=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the tenant, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_SERVICE_TENANT="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_SERVICE_URL_ARGS="?tenant=${_SERVICE_TENANT}"

		_SERVICE_URL_PATH="/v1/service/${_SERVICE_PATH}${_SERVICE_URL_ARGS}"
		delete_request "${_SERVICE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_SERVICE_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_SERVICE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

		#
		# Print message
		#
		prn_msg "${CGRN}Succeed${CDEF} : Clear \"${_SERVICE_TENANT}\" member Service(${_SERVICE_PATH})"

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
