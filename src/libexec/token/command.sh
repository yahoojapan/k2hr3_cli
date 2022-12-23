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
_TOKEN_COMMAND_SUB_CREATE="create"
_TOKEN_COMMAND_SUB_SHOW="show"
_TOKEN_COMMAND_SUB_CHECK="check"

#
# Command type(3'rd option)
#
_TOKEN_COMMAND_TYPE_UTOKEN_CRED="utoken_cred"
_TOKEN_COMMAND_TYPE_UTOKEN_OPTOKEN="utoken_optoken"
_TOKEN_COMMAND_TYPE_UTOKEN_OIDCTOKEN="utoken_oidctoken"
_TOKEN_COMMAND_TYPE_TOKEN_CRED="token_cred"
_TOKEN_COMMAND_TYPE_TOKEN_UTOKEN="token_utoken"
_TOKEN_COMMAND_TYPE_TOKEN_OPTOKEN="token_optoken"
_TOKEN_COMMAND_TYPE_TOKEN_OIDCTOKEN="token_oidctoken"

_TOKEN_COMMAND_TYPE_UTOKEN="utoken"
_TOKEN_COMMAND_TYPE_TOKEN="token"

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
	#
	# Always using lower case
	#
	K2HR3CLI_SUBCOMMAND=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# Type(3'rd command)
#
K2HR3CLI_COMMAND_TYPE=""
if [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" != "${_TOKEN_COMMAND_SUB_CHECK}" ]; then
	if ! parse_noprefix_option "$@"; then
		exit 1
	fi
	if [ -n "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		#
		# Always using lower case
		#
		K2HR3CLI_COMMAND_TYPE=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
	fi
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# Other options
#
if [ $# -gt 0 ]; then
	#
	# The TOKEN command does not require any options other than the Common option.
	#
	_TOKEN_WRONG_OPTS=$(cut_special_words "$*" | sed -e 's/%20/ /g' -e 's/%25/%/g')
	prn_err "Unknown options(\"${_TOKEN_WRONG_OPTS}\") for ${K2HR3CLI_MODE} command."
	exit 1
fi

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_TOKEN_COMMAND_SUB_CREATE} and ${_TOKEN_COMMAND_SUB_SHOW}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_TOKEN_COMMAND_SUB_CREATE}" ]; then
	#
	# TOKEN CREATE
	#
	if [ -z "${K2HR3CLI_COMMAND_TYPE}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the type(${_TOKEN_COMMAND_TYPE_UTOKEN_CRED}, ${_TOKEN_COMMAND_TYPE_UTOKEN_OPTOKEN}, ${_TOKEN_COMMAND_TYPE_UTOKEN_OIDCTOKEN}, ${_TOKEN_COMMAND_TYPE_TOKEN_CRED}, ${_TOKEN_COMMAND_TYPE_TOKEN_UTOKEN}, ${_TOKEN_COMMAND_TYPE_TOKEN_OPTOKEN} and ${_TOKEN_COMMAND_TYPE_TOKEN_OIDCTOKEN}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_UTOKEN_CRED}" ]; then
		#
		# Create Unscoped Token from Credential
		#
		K2HR3CLI_UNSCOPED_TOKEN=""

		#
		# Get Unscoped Token
		#
		if ! complement_unscoped_token "cred"; then
			exit 1
		fi
		prn_msg "${K2HR3CLI_UNSCOPED_TOKEN}"

		#
		# Save to configuration(it need)
		#
		if [ -n "${K2HR3CLI_USER}" ]; then
			if ! config_default_set_key "K2HR3CLI_USER" "${K2HR3CLI_USER}"; then
				exit 1
			fi

			if [ -n "${K2HR3CLI_OPT_SAVE_PASS}" ] && [ "${K2HR3CLI_OPT_SAVE_PASS}" = "1" ] && [ -n "${K2HR3CLI_PASS}" ]; then
				if ! config_default_set_key "K2HR3CLI_PASS" "${K2HR3CLI_PASS}"; then
					exit 1
				fi
			fi
		fi
		if ! config_default_set_key "K2HR3CLI_UNSCOPED_TOKEN" "${K2HR3CLI_UNSCOPED_TOKEN}"; then
			exit 1
		fi

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_UTOKEN_OPTOKEN}" ]; then
		#
		# Create Unscoped Token from OpenStack Token
		#
		K2HR3CLI_UNSCOPED_TOKEN=""

		#
		# Get Unscoped Token
		#
		if ! complement_unscoped_token "op"; then
			exit 1
		fi
		prn_msg "${K2HR3CLI_UNSCOPED_TOKEN}"

		#
		# Save to configuration(it need)
		#
		if ! config_default_set_key "K2HR3CLI_UNSCOPED_TOKEN" "${K2HR3CLI_UNSCOPED_TOKEN}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_OPENSTACK_TOKEN" "${K2HR3CLI_OPENSTACK_TOKEN}"; then
			exit 1
		fi

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_UTOKEN_OIDCTOKEN}" ]; then
		#
		# Create Unscoped Token from OIDC Token
		#
		K2HR3CLI_UNSCOPED_TOKEN=""

		#
		# Get Unscoped Token
		#
		if ! complement_unscoped_token "oidc"; then
			exit 1
		fi
		prn_msg "${K2HR3CLI_UNSCOPED_TOKEN}"

		#
		# Save to configuration(it need)
		#
		if ! config_default_set_key "K2HR3CLI_UNSCOPED_TOKEN" "${K2HR3CLI_UNSCOPED_TOKEN}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_OIDC_TOKEN" "${K2HR3CLI_OIDC_TOKEN}"; then
			exit 1
		fi

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_TOKEN_CRED}" ]; then
		#
		# Create Scoped Token from Credential
		#
		K2HR3CLI_SCOPED_TOKEN=""

		#
		# Get Scoped Token
		#
		if ! complement_scoped_token "cred"; then
			exit 1
		fi
		prn_msg "${K2HR3CLI_SCOPED_TOKEN}"

		#
		# Save to configuration(it need)
		#
		if [ -n "${K2HR3CLI_USER}" ]; then
			if ! config_default_set_key "K2HR3CLI_USER" "${K2HR3CLI_USER}"; then
				exit 1
			fi

			if [ -n "${K2HR3CLI_OPT_SAVE_PASS}" ] && [ "${K2HR3CLI_OPT_SAVE_PASS}" = "1" ] && [ -n "${K2HR3CLI_PASS}" ]; then
				if ! config_default_set_key "K2HR3CLI_PASS" "${K2HR3CLI_PASS}"; then
					exit 1
				fi
			fi
		fi

		if [ -n "${K2HR3CLI_UNSCOPED_TOKEN}" ]; then
			if ! config_default_set_key "K2HR3CLI_UNSCOPED_TOKEN" "${K2HR3CLI_UNSCOPED_TOKEN}"; then
				exit 1
			fi
		fi
		if ! config_default_set_key "K2HR3CLI_TENANT" "${K2HR3CLI_TENANT}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_SCOPED_TOKEN" "${K2HR3CLI_SCOPED_TOKEN}"; then
			exit 1
		fi

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_TOKEN_UTOKEN}" ]; then
		#
		# Create Scoped Token from Unscoped Token
		#
		K2HR3CLI_SCOPED_TOKEN=""

		#
		# Get Unscoped Token
		#
		if ! complement_unscoped_token "abort"; then
			exit 1
		fi

		#
		# Get Scoped Token
		#
		if ! complement_scoped_token; then
			exit 1
		fi
		prn_msg "${K2HR3CLI_SCOPED_TOKEN}"

		#
		# Save to configuration(it need)
		#
		if [ -n "${K2HR3CLI_USER}" ]; then
			if ! config_default_set_key "K2HR3CLI_USER" "${K2HR3CLI_USER}"; then
				exit 1
			fi

			if [ -n "${K2HR3CLI_OPT_SAVE_PASS}" ] && [ "${K2HR3CLI_OPT_SAVE_PASS}" = "1" ] && [ -n "${K2HR3CLI_PASS}" ]; then
				if ! config_default_set_key "K2HR3CLI_PASS" "${K2HR3CLI_PASS}"; then
					exit 1
				fi
			fi
		fi
		if [ -n "${K2HR3CLI_UNSCOPED_TOKEN}" ]; then
			if ! config_default_set_key "K2HR3CLI_UNSCOPED_TOKEN" "${K2HR3CLI_UNSCOPED_TOKEN}"; then
				exit 1
			fi
		fi
		if ! config_default_set_key "K2HR3CLI_TENANT" "${K2HR3CLI_TENANT}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_SCOPED_TOKEN" "${K2HR3CLI_SCOPED_TOKEN}"; then
			exit 1
		fi

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_TOKEN_OPTOKEN}" ]; then
		#
		# Create Scoped Token from OpenStack Token
		#
		K2HR3CLI_SCOPED_TOKEN=""

		#
		# Get Unscoped Token
		#
		if ! complement_unscoped_token "op"; then
			exit 1
		fi

		#
		# Get Scoped Token
		#
		if ! complement_scoped_token; then
			exit 1
		fi
		prn_msg "${K2HR3CLI_SCOPED_TOKEN}"

		#
		# Save to configuration(it need)
		#
		if [ -n "${K2HR3CLI_UNSCOPED_TOKEN}" ]; then
			if ! config_default_set_key "K2HR3CLI_UNSCOPED_TOKEN" "${K2HR3CLI_UNSCOPED_TOKEN}"; then
				exit 1
			fi
		fi
		if ! config_default_set_key "K2HR3CLI_TENANT" "${K2HR3CLI_TENANT}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_SCOPED_TOKEN" "${K2HR3CLI_SCOPED_TOKEN}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_OPENSTACK_TOKEN" "${K2HR3CLI_OPENSTACK_TOKEN}"; then
			exit 1
		fi

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_TOKEN_OIDCTOKEN}" ]; then
		#
		# Create Scoped Token from OIDC Token
		#
		K2HR3CLI_SCOPED_TOKEN=""

		#
		# Get Unscoped Token
		#
		if ! complement_unscoped_token "oidc"; then
			exit 1
		fi

		#
		# Get Scoped Token
		#
		if ! complement_scoped_token; then
			exit 1
		fi
		prn_msg "${K2HR3CLI_SCOPED_TOKEN}"

		#
		# Save to configuration(it need)
		#
		if [ -n "${K2HR3CLI_UNSCOPED_TOKEN}" ]; then
			if ! config_default_set_key "K2HR3CLI_UNSCOPED_TOKEN" "${K2HR3CLI_UNSCOPED_TOKEN}"; then
				exit 1
			fi
		fi
		if ! config_default_set_key "K2HR3CLI_TENANT" "${K2HR3CLI_TENANT}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_SCOPED_TOKEN" "${K2HR3CLI_SCOPED_TOKEN}"; then
			exit 1
		fi
		if ! config_default_set_key "K2HR3CLI_OIDC_TOKEN" "${K2HR3CLI_OIDC_TOKEN}"; then
			exit 1
		fi

	else
		prn_err "Unknown type(\"${K2HR3CLI_COMMAND_TYPE}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

	#
	# Save to configuration for K2HR3CLI_API_URI (it need)
	#
	if ! config_default_set_key "K2HR3CLI_API_URI" "${K2HR3CLI_API_URI}"; then
		exit 1
	fi

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_TOKEN_COMMAND_SUB_SHOW}" ]; then
	#
	# SHOW TENANT LIST
	#
	if [ -z "${K2HR3CLI_COMMAND_TYPE}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the type(${_TOKEN_COMMAND_TYPE_UTOKEN} and ${_TOKEN_COMMAND_TYPE_TOKEN}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_UTOKEN}" ]; then
		#
		# Get tenant list by Unscoped Token
		#

		#
		# Get Unscoped Token
		#
		if ! complement_unscoped_token; then
			exit 1
		fi

		#
		# Get request
		#
		get_request "/v1/user/tokens" 1 "x-auth-token:U=${K2HR3CLI_UNSCOPED_TOKEN}"
		_TOKEN_REQUEST_RESULT=$?

	elif [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_TOKEN}" ]; then
		#
		# Get tenant list by Scoped Token
		#

		#
		# Get Scoped Token
		#
		if ! complement_scoped_token; then
			exit 1
		fi

		#
		# Get request
		#
		get_request "/v1/user/tokens" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_TOKEN_REQUEST_RESULT=$?

	else
		prn_err "Unknown type(\"${K2HR3CLI_COMMAND_TYPE}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

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
	if ! requtil_check_result "${_TOKEN_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Check scoped value in json
	#
	if ! jsonparser_get_key_value '%"scoped"%' "${JP_PAERSED_FILE}"; then
		prn_err "Failed to get tenant list : \"scoped\" element is not existed in token api response."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	_TOKEN_TENANT_SHOW_TMP=${JSONPARSER_FIND_VAL}
	if [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_UTOKEN}" ]; then
		_TOKEN_TENANT_SHOW_SCOPE_TMP="false"
	else
		_TOKEN_TENANT_SHOW_SCOPE_TMP="true"
	fi
	if [ -z "${JSONPARSER_FIND_VAL_TYPE}" ] || { [ "${JSONPARSER_FIND_VAL_TYPE}" != "${JP_TYPE_TRUE}" ] && [ "${JSONPARSER_FIND_VAL_TYPE}" != "${JP_TYPE_FALSE}" ]; }; then
		prn_err "Failed to get tenant list : \"scoped\" element is not \"${_TOKEN_TENANT_SHOW_SCOPE_TMP}\"."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	if [ -z "${_TOKEN_TENANT_SHOW_TMP}" ] || [ "${_TOKEN_TENANT_SHOW_TMP}" != "${_TOKEN_TENANT_SHOW_SCOPE_TMP}" ]; then
		prn_err "Failed to get tenant list : \"scoped\" element is not \"${_TOKEN_TENANT_SHOW_SCOPE_TMP}\"."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Check user value in json
	#
	if [ "${K2HR3CLI_COMMAND_TYPE}" = "${_TOKEN_COMMAND_TYPE_TOKEN}" ]; then
		if ! jsonparser_get_key_value '%"user"%' "${JP_PAERSED_FILE}"; then
			prn_err "Failed to get tenant list : \"user\" element is not existed in token api response."
			rm -f "${JP_PAERSED_FILE}"
			exit 1
		fi

		# [NOTE]
		# ${K2HR3CLI_USER} may remain empty if obtained from ScopedToken. 
		# Check only when ${K2HR3CLI_USER}is not empty.
		#
		if [ -n "${K2HR3CLI_USER}" ]; then
			_TOKEN_TENANT_SHOW_TMP=$(to_upper "${JSONPARSER_FIND_STR_VAL}")
			_TOKEN_TENANT_SHOW_TMP2=$(to_upper "${K2HR3CLI_USER}")

			# [NOTE]
			# Since the condition becomes complicated, use "X"(temporary word).
			#
			if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_STR}" ] || [ "X${_TOKEN_TENANT_SHOW_TMP}" != "X${_TOKEN_TENANT_SHOW_TMP2}" ]; then
				prn_err "Failed to get tenant list : \"user\" element is not \"false\"."
				rm -f "${JP_PAERSED_FILE}"
				exit 1
			fi
		fi
	fi

	#
	# Display tenant list from json
	#
	if ! jsonparser_dump_key_parsed_file '%' '"tenants"' "${JP_PAERSED_FILE}"; then
		prn_err "Failed to get tenant list : \"tenants\" element is not existed in token api response."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_TOKEN_COMMAND_SUB_CHECK}" ]; then
	#
	# CHECK(HEAD) TOKEN
	#
	if [ -n "${K2HR3CLI_SCOPED_TOKEN}" ]; then
		_TOKEN_TENANT_TARGET_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"
		_TOKEN_TENANT_TARGET_IS_SCOPED=1
		prn_dbg "Check the Unscoped Token : \"${_TOKEN_TENANT_TARGET_TOKEN}\""
	else
		if [ -n "${K2HR3CLI_UNSCOPED_TOKEN}" ]; then
			_TOKEN_TENANT_TARGET_TOKEN="${K2HR3CLI_UNSCOPED_TOKEN}"
			_TOKEN_TENANT_TARGET_IS_SCOPED=0
			prn_dbg "Check the Scoped Token : \"${_TOKEN_TENANT_TARGET_TOKEN}\""
		else
			prn_err "There is no (Un)Scoped Token. Specify it by the option or configuration file or environment, and then re-execute this."
		fi
	fi

	#
	# Head request
	#
	head_request "/v1/user/tokens" 1 "x-auth-token:U=${_TOKEN_TENANT_TARGET_TOKEN}"
	_TOKEN_REQUEST_RESULT=$?

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
	if ! requtil_check_result "${_TOKEN_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# HTTP response code = 204
	#
	if [ "${_TOKEN_TENANT_TARGET_IS_SCOPED}" -eq 1 ]; then
		prn_msg "${CGRN}K2HR3 Scoped token is VALID${CDEF} : TOKEN=\"${_TOKEN_TENANT_TARGET_TOKEN}\""
	else
		prn_msg "${CGRN}K2HR3 Unscoped token is VALID${CDEF} : TOKEN=\"${_TOKEN_TENANT_TARGET_TOKEN}\""
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
