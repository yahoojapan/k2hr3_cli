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
_LIST_COMMAND_SUB_SERVICE="service"
_LIST_COMMAND_SUB_ROLE="role"
_LIST_COMMAND_SUB_RESOURCE="resource"
_LIST_COMMAND_SUB_POLICY="policy"

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
_LIST_3RD_PARAM=""
if parse_noprefix_option "$@"; then
	if [ -n "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
		#
		# Always using lower case
		#
		_LIST_3RD_PARAM="${K2HR3CLI_OPTION_NOPREFIX}"
	fi
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}
fi

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
if [ -n "${K2HR3CLI_SUBCOMMAND}" ] && [ "${K2HR3CLI_SUBCOMMAND}" = "${_LIST_COMMAND_SUB_SERVICE}" ]; then
	#
	# List SERVICEs
	#
	_LIST_SERVICE_NAME="${_LIST_3RD_PARAM}"
	if [ -n "${_LIST_SERVICE_NAME}" ]; then
		#
		# First word is "/"
		#
		_LIST_SERVICE_NAME="/${_LIST_SERVICE_NAME}"
	fi

	#
	# Get Scoped Token
	#
	if ! complement_scoped_token; then
		exit 1
	fi
	prn_dbg "Get scoped token = \"${K2HR3CLI_SCOPED_TOKEN}\""

	#
	# Request
	#
	_LIST_URL_ARGS=$(requtil_urlarg_expand_param "")
	_LIST_URL_PATH="/v1/list/service${_LIST_SERVICE_NAME}${_LIST_URL_ARGS}"
	get_request "${_LIST_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
	_LIST_REQUEST_RESULT=$?

else
	#
	# List ROLEs/RESOURCEs/POLICIes
	#
	_LIST_YRN_PATH="${_LIST_3RD_PARAM}"
	if [ -n "${_LIST_YRN_PATH}" ]; then
		#
		# First word is "/"
		#
		_LIST_YRN_PATH="/${_LIST_YRN_PATH}"
	fi

	#
	# 4'th parameter is service name, if exists
	#
	_LIST_SERVICE_NAME=""
	if parse_noprefix_option "$@"; then
		if [ -n "${K2HR3CLI_OPTION_NOPREFIX}" ]; then
			#
			# Always using lower case
			#
			# [NOTE]
			# Lastest word is "/"
			#
			_LIST_SERVICE_NAME="${K2HR3CLI_OPTION_NOPREFIX}/"
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}
	fi

	#
	# Get Scoped Token
	#
	if ! complement_scoped_token; then
		exit 1
	fi
	prn_dbg "Get scoped token = \"${K2HR3CLI_SCOPED_TOKEN}\""

	if [ -z "${K2HR3CLI_SUBCOMMAND}" ]; then
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_LIST_COMMAND_SUB_SERVICE}, ${_LIST_COMMAND_SUB_ROLE}, ${_LIST_COMMAND_SUB_RESOURCE} and ${_LIST_COMMAND_SUB_POLICY}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1

	elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_LIST_COMMAND_SUB_ROLE}" ]; then
		#
		# List ROLEs
		#
		_LIST_URL_ARGS=$(requtil_urlarg_expand_param "")
		_LIST_URL_PATH="/v1/list/${_LIST_SERVICE_NAME}role${_LIST_YRN_PATH}${_LIST_URL_ARGS}"
		get_request "${_LIST_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_LIST_REQUEST_RESULT=$?

	elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_LIST_COMMAND_SUB_RESOURCE}" ]; then
		#
		# List RESOURCEs
		#
		_LIST_URL_ARGS=$(requtil_urlarg_expand_param "")
		_LIST_URL_PATH="/v1/list/${_LIST_SERVICE_NAME}resource${_LIST_YRN_PATH}${_LIST_URL_ARGS}"
		get_request "${_LIST_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_LIST_REQUEST_RESULT=$?

	elif [ "${K2HR3CLI_SUBCOMMAND}" = "${_LIST_COMMAND_SUB_POLICY}" ]; then
		#
		# List POLICIes
		#
		_LIST_URL_ARGS=$(requtil_urlarg_expand_param "")
		_LIST_URL_PATH="/v1/list/${_LIST_SERVICE_NAME}policy${_LIST_YRN_PATH}${_LIST_URL_ARGS}"
		get_request "${_LIST_URL_PATH}" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_LIST_REQUEST_RESULT=$?

	else
		prn_err "Unknown subcommand(\"${K2HR3CLI_SUBCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi
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
if ! requtil_check_result "${_LIST_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "200"; then
	rm -f "${JP_PAERSED_FILE}"
	exit 1
fi

#
# Check children value in json
#
if ! jsonparser_dump_key_parsed_file '%' '"children"' "${JP_PAERSED_FILE}"; then
	prn_err "Failed to display \"children\" element."
	rm -f "${JP_PAERSED_FILE}"
	exit 1
fi
rm -f "${JP_PAERSED_FILE}"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
