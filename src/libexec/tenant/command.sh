#
# K2HR3 Utilities - Command Line Interface
#
# Copyright 2023 Yahoo Japan Corporation.
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
# CREATE:   Thu Jul 27 2023
# REVISION:
#

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
#
# SubCommand(2'nd option)
#
_TENANT_COMMAND_SUB_CREATE="create"
_TENANT_COMMAND_SUB_UPDATE="update"
_TENANT_COMMAND_SUB_SHOW="show"
_TENANT_COMMAND_SUB_DELETE="delete"

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
# Get Unscoped Token
#
if ! complement_unscoped_token; then
	exit 1
fi
prn_dbg "${K2HR3CLI_UNSCOPED_TOKEN}"

if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_TENANT_COMMAND_SUB_CREATE}, ${_TENANT_COMMAND_SUB_UPDATE}, ${_TENANT_COMMAND_SUB_SHOW} or ${_TENANT_COMMAND_SUB_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_TENANT_COMMAND_SUB_CREATE}" ]; then
	#
	# TENANT CREATE
	#

	#
	# Get tenant name(or path)
	#
	_TENANT_NAME=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the tenant name, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_TENANT_NAME=${K2HR3CLI_OPTION_NOPREFIX}

	#
	# Request
	#
	_TENANT_URL_ARGS="?name=${_TENANT_NAME}"
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_display_param "${_TENANT_URL_ARGS}")
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_description_param "${_TENANT_URL_ARGS}")
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_users_param "${_TENANT_URL_ARGS}")

	_TENANT_URL_PATH="/v1/tenant${_TENANT_URL_ARGS}"
	put_request "${_TENANT_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_UNSCOPED_TOKEN}"
	_TENANT_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_TENANT_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Create \"${_TENANT_NAME}\" Tenant"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_TENANT_COMMAND_SUB_UPDATE}" ]; then
	#
	# TENANT UPDATE
	#

	#
	# Get tenant name(or path)
	#
	_TENANT_NAME=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the tenant name, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_TENANT_NAME=${K2HR3CLI_OPTION_NOPREFIX}

	#
	# Request
	#
	_TENANT_URL_ARGS=""
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_id_param "${_TENANT_URL_ARGS}")
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_display_param "${_TENANT_URL_ARGS}")
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_description_param "${_TENANT_URL_ARGS}")
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_users_param "${_TENANT_URL_ARGS}")

	_TENANT_URL_PATH="/v1/tenant/${_TENANT_NAME}${_TENANT_URL_ARGS}"
	put_request "${_TENANT_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_UNSCOPED_TOKEN}"
	_TENANT_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_TENANT_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Update \"${_TENANT_NAME}\" Tenant"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_TENANT_COMMAND_SUB_SHOW}" ]; then
	#
	# TENANT SHOW
	#

	#
	# Check tenant name
	#
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" got fatal error during parsing parameters, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	if [ -n "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		#
		# Specified tenant name
		#
		_TENANT_NAME=${K2HR3CLI_OPTION_NOPREFIX}
		_TENANT_URL_PATH="/v1/tenant/${_TENANT_NAME}"
		_RES_TENANT_KEY_NAME='"tenant"'
	else
		#
		# Not specified tenant name
		#
		_TENANT_URL_ARGS=""
		_TENANT_URL_ARGS=$(requtil_urlarg_expand_param "${_TENANT_URL_ARGS}")
		_TENANT_URL_PATH="/v1/tenant${_TENANT_URL_ARGS}"
		_RES_TENANT_KEY_NAME='"tenants"'
	fi

	#
	# Request
	#
	get_request "${_TENANT_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_UNSCOPED_TOKEN}"
	_TENANT_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_TENANT_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Display tenant value in json
	#
	if ! jsonparser_dump_key_parsed_file '%' "${_RES_TENANT_KEY_NAME}" "${JP_PAERSED_FILE}"; then
		prn_err "Failed to get ${_RES_TENANT_KEY_NAME} element in response."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_TENANT_COMMAND_SUB_DELETE}" ]; then
	#
	# TENANT DELETE
	#

	#
	# Get tenant name
	#
	_TENANT_NAME=""
	if ! parse_noprefix_option "$@"; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the tenant name, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_TENANT_NAME=${K2HR3CLI_OPTION_NOPREFIX}

	#
	# Request
	#
	_TENANT_URL_ARGS=""
	_TENANT_URL_ARGS=$(requtil_urlarg_tenant_id_param "${_TENANT_URL_ARGS}")

	_TENANT_URL_PATH="/v1/tenant/${_TENANT_NAME}${_TENANT_URL_ARGS}"
	delete_request "${_TENANT_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_UNSCOPED_TOKEN}"
	_TENANT_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_TENANT_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Delete \"${_TENANT_NAME}\" Tenant"

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
