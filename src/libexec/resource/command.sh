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
_RESOURCE_COMMAND_SUB_CREATE="create"
_RESOURCE_COMMAND_SUB_SHOW="show"
_RESOURCE_COMMAND_SUB_DELETE="delete"

#--------------------------------------------------------------
# Parse arguments
#--------------------------------------------------------------
#
# Sub Command
#
parse_noprefix_option "$@"
if [ $? -ne 0 ]; then
	exit 1
fi
if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
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
complement_scoped_token
if [ $? -ne 0 ]; then
	exit 1
fi
prn_dbg "${K2HR3CLI_SCOPED_TOKEN}"

if [ "X${K2HR3CLI_SUBCOMMAND}" = "X${_RESOURCE_COMMAND_SUB_CREATE}" ]; then
	#
	# RESOURCE CREATE/UPDATE
	#

	#
	# Get resource name(or path)
	#
	_RESOURCE_PATH=""
	parse_noprefix_option "$@"
	if [ $? -ne 0 ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the resource name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_RESOURCE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	if [ "X${K2HR3CLI_OPT_DATAFILE}" = "X" ]; then
		_RESOURCE_URL_ARGS="?name=${_RESOURCE_PATH}"
		_RESOURCE_URL_ARGS=$(requtil_urlarg_type_param "${_RESOURCE_URL_ARGS}" 1)
		_RESOURCE_URL_ARGS=$(requtil_urlarg_data_param "${_RESOURCE_URL_ARGS}" 1)
		_RESOURCE_URL_ARGS=$(requtil_urlarg_keys_param "${_RESOURCE_URL_ARGS}" 1)
		_RESOURCE_URL_ARGS=$(requtil_urlarg_alias_param "${_RESOURCE_URL_ARGS}" 1)

		_RESOURCE_URL_PATH="/v1/resource${_RESOURCE_URL_ARGS}"
		put_request "${_RESOURCE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_RESOURCE_REQUEST_RESULT=$?

	else
		#
		# Make json file
		#
		# ex)
		#	{
		#		"resource": {
		#			"name": <resource name>,
		#			"type": "string",
		#			"data": <escaped resource data from file>,
		#			"keys": {
		#				foo: bar,
		#				...
		#			},
		#			"alias": [
		#				<resource yrn full path>,
		#				...
		#			]
		#		}
		#	}
		#
		_RESOURCE_POST_JSON_FILE="/tmp/.${BINNAME}_$$.resouce"
		_RESOURCE_DATAFILE_ESC=$(sed -e ':loop; N; $!b loop; s/\n/\\n/g' -e 's/"/\\"/g' "${K2HR3CLI_OPT_DATAFILE}")
		{
			pecho -n "{"
			pecho -n 	"\"resource\":{"
			pecho -n 		"\"name\":\"${_RESOURCE_PATH}\""
			pecho -n 		",\"type\":\"string\""
			pecho -n 		",\"data\":\"${_RESOURCE_DATAFILE_ESC}\""
			if [ "X${K2HR3CLI_OPT_KEYS}" != "X" ]; then
				pecho -n	",\"keys\":${K2HR3CLI_OPT_KEYS}"
			fi
			if [ "X${K2HR3CLI_OPT_ALIAS}" != "X" ]; then
				pecho -n "${K2HR3CLI_OPT_ALIAS}" | grep -q '['
				if [ $? -eq 0 ]; then
					pecho -n ",\"alias\":${K2HR3CLI_OPT_ALIAS}"
				else
					pecho -n ",\"alias\":\"${K2HR3CLI_OPT_ALIAS}\""
				fi
			fi
			pecho -n 	"}"
			pecho -n "}"
		} > "${_RESOURCE_POST_JSON_FILE}"

		_RESOURCE_URL_PATH="/v1/resource"
		post_file_request "${_RESOURCE_URL_PATH}" "${_RESOURCE_POST_JSON_FILE}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_RESOURCE_REQUEST_RESULT=$?

		rm -f "${_RESOURCE_POST_JSON_FILE}"
	fi

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_RESOURCE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"
	if [ $? -ne 0 ]; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Create/Update \"${_RESOURCE_PATH}\" Resource"

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${_RESOURCE_COMMAND_SUB_SHOW}" ]; then
	#
	# RESOURCE SHOW
	#

	#
	# Get resource name(or path)
	#
	_RESOURCE_PATH=""
	parse_noprefix_option "$@"
	if [ $? -ne 0 ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the resource name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_RESOURCE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_RESOURCE_URL_ARGS=""
	_RESOURCE_URL_ARGS=$(requtil_urlarg_service_param "${_RESOURCE_URL_ARGS}")
	_RESOURCE_URL_ARGS=$(requtil_urlarg_expand_param "${_RESOURCE_URL_ARGS}")

	_RESOURCE_URL_PATH="/v1/resource/${_RESOURCE_PATH}${_RESOURCE_URL_ARGS}"
	get_request "${_RESOURCE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_RESOURCE_REQUEST_RESULT=$?

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_RESOURCE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"
	if [ $? -ne 0 ]; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi

	#
	# Display resource value in json
	#
	jsonparser_dump_key_parsed_file '%' '"resource"' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to get \"resource\" element in response."
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${_RESOURCE_COMMAND_SUB_DELETE}" ]; then
	#
	# RESOURCE DELETE
	#

	#
	# Get resource name(or path)
	#
	_RESOURCE_PATH=""
	parse_noprefix_option "$@"
	if [ $? -ne 0 ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must specify the resource name or yrn path, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
	_RESOURCE_PATH="${K2HR3CLI_OPTION_NOPREFIX}"

	#
	# Request
	#
	_RESOURCE_URL_ARGS=""
	_RESOURCE_URL_ARGS=$(requtil_urlarg_type_param "${_RESOURCE_URL_ARGS}" 1)
	_RESOURCE_URL_ARGS=$(requtil_urlarg_keynames_param "${_RESOURCE_URL_ARGS}")
	_RESOURCE_URL_ARGS=$(requtil_urlarg_aliases_param "${_RESOURCE_URL_ARGS}")

	_RESOURCE_URL_PATH="/v1/resource/${_RESOURCE_PATH}${_RESOURCE_URL_ARGS}"
	delete_request "${_RESOURCE_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_RESOURCE_REQUEST_RESULT=$?

	#
	# Parse response body
	#
	jsonparser_parse_json_file "${K2HR3CLI_REQUEST_RESULT_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to parse result."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		exit 1
	fi
	rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#
	# Check result
	#
	requtil_check_result "${_RESOURCE_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "204" 1
	if [ $? -ne 0 ]; then
		rm -f "${JP_PAERSED_FILE}"
		exit 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Print message
	#
	prn_msg "${CGRN}Succeed${CDEF} : Delete \"${_RESOURCE_PATH}\" Resource"

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_RESOURCE_COMMAND_SUB_CREATE}, ${_RESOURCE_COMMAND_SUB_SHOW} or ${_RESOURCE_COMMAND_SUB_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
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
