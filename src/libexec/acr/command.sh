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
#
# SubCommand(2'nd option)
#
_ACR_COMMAND_SUB_ADD="add"
_ACR_COMMAND_SUB_SHOW="show"
_ACR_COMMAND_SUB_DELETE="delete"

#
# Other Command(3'rd option)
#
_ACR_COMMAND_SUB2_TENANT="tenant"
_ACR_COMMAND_SUB2_RESOURCE="resource"

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
	if [ -n "${_ACR_COMMAND_SUB_SHOW}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_ACR_COMMAND_SUB_SHOW}" ]; then
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
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_ACR_COMMAND_SUB_ADD}, ${_ACR_COMMAND_SUB_SHOW} or ${_ACR_COMMAND_SUB_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1

elif [ -n "${_ACR_COMMAND_SUB_ADD}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_ACR_COMMAND_SUB_ADD}" ]; then
	#
	# ACR ADD
	#

	#
	# Get service name(or path)
	#
	_ACR_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_ACR_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_ACR_URL_PATH="/v1/acr/${_ACR_PATH}"
	put_request "${_ACR_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_ACR_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_ACR_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Add Tenant(Scoped Token) to \"${_ACR_PATH}\" Service member"

elif [ -n "${_ACR_COMMAND_SUB_SHOW}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_ACR_COMMAND_SUB_SHOW}" ]; then
	#
	# ACR SHOW
	#
	if [ -z "${K2HR3CLI_OTHERCOMMAND}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the parameter(${_ACR_COMMAND_SUB2_TENANT} or ${_ACR_COMMAND_SUB2_RESOURCE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ -n "${_ACR_COMMAND_SUB2_TENANT}" ] && [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ACR_COMMAND_SUB2_TENANT}" ]; then
		#
		# SHOW TENANT
		#

		#
		# Get service name(or path)
		#
		_ACR_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ACR_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ACR_URL_PATH="/v1/acr/${_ACR_PATH}"
		get_request "${_ACR_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_ACR_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ACR_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi

		#
		# Display role value in json
		#
		if ! jsonparser_dump_key_parsed_file '%' '"tokeninfo"' "${JP_PAERSED_FILE}"; then
			prn_err "Failed to get \"tokeninfo\" element in response."
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

	elif [ -n "${_ACR_COMMAND_SUB2_RESOURCE}" ] && [ "${K2HR3CLI_OTHERCOMMAND}" = "${_ACR_COMMAND_SUB2_RESOURCE}" ]; then
		#
		# SHOW RESOURCE
		#

		#
		# Get service name(or path)
		#
		_ACR_PATH=""
		if ! parse_noprefix_option "$@"; then
			prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_OTHERCOMMAND}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
			exit 1
		fi
		_ACR_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

		#
		# Request
		#
		_ACR_URL_ARGS=""
		_ACR_URL_ARGS=$(requtil_urlarg_acr_cip_param "${_ACR_URL_ARGS}")
		_ACR_URL_ARGS=$(requtil_urlarg_acr_cport_param "${_ACR_URL_ARGS}")
		_ACR_URL_ARGS=$(requtil_urlarg_acr_crole_param "${_ACR_URL_ARGS}")
		_ACR_URL_ARGS=$(requtil_urlarg_acr_ccuk_param "${_ACR_URL_ARGS}")
		_ACR_URL_ARGS=$(requtil_urlarg_acr_sport_param "${_ACR_URL_ARGS}")
		_ACR_URL_ARGS=$(requtil_urlarg_acr_srole_param "${_ACR_URL_ARGS}")
		_ACR_URL_ARGS=$(requtil_urlarg_acr_scuk_param "${_ACR_URL_ARGS}")

		_ACR_URL_PATH="/v1/acr/${_ACR_PATH}${_ACR_URL_ARGS}"
		get_request "${_ACR_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_ACR_REQUEST_RESULT=$?

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
		if ! requtil_check_result "${_ACR_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi

		#
		# Display role value in json
		#
		if ! jsonparser_dump_key_parsed_file '%' '"response"' "${JP_PAERSED_FILE}"; then
			prn_err "Failed to get \"response\" element in response."
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi
		rm -f "${JP_PAERSED_FILE}"

	else
		prn_err "Unknown parameter(\"${K2HR3CLI_OTHERCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ -n "${_ACR_COMMAND_SUB_DELETE}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_ACR_COMMAND_SUB_DELETE}" ]; then
	#
	# ACR DELETE
	#

	#
	# Get service name(or path)
	#
	_ACR_PATH=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the service name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_ACR_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_ACR_URL_PATH="/v1/acr/${_ACR_PATH}"
	delete_request "${_ACR_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_ACR_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_ACR_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Delete Tenant(Scoped Token) from \"${_ACR_PATH}\" Service member"

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
