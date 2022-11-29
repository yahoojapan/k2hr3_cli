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
# Set variables for request result
#
#	K2HR3CLI_REQUEST_RESULT_FILE	: file of result content by request
#
K2HR3CLI_REQUEST_RESULT_FILE="/tmp/.${BINNAME}_$$_curl.result"

#
# Special Environment
#
# [NOTE]
# When testing a plugin, you may want to put another function before
# the "create_dummy_response" function.
# When testing a plugin, prepare the file specified by "K2HR3CLI_REQUEST_FILE"
# dedicated to the plugin.
# Please load this "util_request.sh" in the file specified by
# the file which is specified "K2HR3CLI_REQUEST_FILE".
# And, set the function to be inserted in the "TEST_CREATE_DUMMY_RESPONSE_FUNC"
# variable.
# This will call the function specified by "TEST_CREATE_DUMMY_RESPONSE_FUNC"
# before calling the "create_dummy_response" function.
# The function specified by "TEST_CREATE_DUMMY_RESPONSE_FUNC" should call the
# "create_dummy_response" function internally.
#
if [ -z "${TEST_CREATE_DUMMY_RESPONSE_FUNC}" ]; then
	export TEST_CREATE_DUMMY_RESPONSE_FUNC="create_dummy_response"
fi

#
# Zip comparessed file
#
# [NOTE]
# A temporary file for creating dummy data for an API that returns
# gzip-compressed file content.
# Mainly used in USERDATA / EXTDATA.
#
_UTIL_TMP_UNZIP_FILE="/tmp/.${BINNAME}_$$_test_temporary"
_UTIL_TMP_ZIP_FILE="${_UTIL_TMP_UNZIP_FILE}.gz"

#--------------------------------------------------------------
# Utility Functions
#--------------------------------------------------------------
#
# Search Headers
#
# $1		: target header name
# $2...		: headers
# $?		: result
# Output
#	header value
#
util_search_header()
{
	_UTIL_SEARCH_HEADER_KEYWORD=$(to_upper "$1")
	shift

	if [ -z "${_UTIL_SEARCH_HEADER_KEYWORD}" ]; then
		pecho -n ""
		return 1
	fi

	while [ $# -gt 0 ]; do
		_UTIL_ONE_HEADER_PAIR=$(to_upper "$1")
		if pecho -n "${_UTIL_ONE_HEADER_PAIR}" | grep -q "^${_UTIL_SEARCH_HEADER_KEYWORD}"; then
			_UTIL_ONE_HEADER_VALUE=$(pecho -n "$1" | sed -e 's/:/ /g' | awk '{print $2}')
			pecho -n "${_UTIL_ONE_HEADER_VALUE}"
			return 0
		fi
		shift
	done

	return 1
}

#
# Search User Token Header
#
# $1...		: headers
# $?		: result
# Output
#	token value
#
util_search_usertoken()
{
	if ! _UTIL_SEARCH_TOKEN=$(util_search_header "x-auth-token" "$@"); then
		prn_dbg "Not found \"x-auth-token\" header"
		return 1
	fi
	_UTIL_SEARCH_TOKEN_TMP=$(pecho -n "${_UTIL_SEARCH_TOKEN}" | cut -c 1-2)
	if [ -z "${_UTIL_SEARCH_TOKEN_TMP}" ] || [ "${_UTIL_SEARCH_TOKEN_TMP}" != "U=" ]; then
		prn_err "\"x-auth-token\" header value does not start \"U=\"(x-auth-token: ${_UTIL_SEARCH_TOKEN})."
		return 1
	fi
	_UTIL_SEARCH_TOKEN_TMP=$(pecho -n "${_UTIL_SEARCH_TOKEN}" | cut -c 3-)
	if [ -z "${_UTIL_SEARCH_TOKEN_TMP}" ]; then
		prn_err "\"x-auth-token\" header value is empty(x-auth-token: ${_UTIL_SEARCH_TOKEN})."
		return 1
	fi
	pecho -n "${_UTIL_SEARCH_TOKEN_TMP}"
	return 0
}

#
# Search Role Token Header
#
# $1...		: headers
# $?		: result
# Output
#	token value
#
util_search_roletoken()
{
	if ! _UTIL_SEARCH_TOKEN=$(util_search_header "x-auth-token" "$@"); then
		prn_dbg "Not found \"x-auth-token\" header"
		return 1
	fi
	_UTIL_SEARCH_TOKEN_TMP=$(pecho -n "${_UTIL_SEARCH_TOKEN}" | cut -c 1-2)
	if [ -z "${_UTIL_SEARCH_TOKEN_TMP}" ] || [ "${_UTIL_SEARCH_TOKEN_TMP}" != "R=" ]; then
		prn_err "\"x-auth-token\" header value does not start \"U=\"(x-auth-token: ${_UTIL_SEARCH_TOKEN})."
		return 1
	fi
	_UTIL_SEARCH_TOKEN_TMP=$(pecho -n "${_UTIL_SEARCH_TOKEN}" | cut -c 3-)
	if [ -z "${_UTIL_SEARCH_TOKEN_TMP}" ]; then
		prn_err "\"x-auth-token\" header value is empty(x-auth-token: ${_UTIL_SEARCH_TOKEN})."
		return 1
	fi
	pecho -n "${_UTIL_SEARCH_TOKEN_TMP}"
	return 0
}

#
# Search URL Arguments
#
# $1		: target argument name
# $2...		: arguments
# $?		: result
# Output
#	argument value
#
util_search_urlarg()
{
	_UTIL_SEARCH_KEYWORD=$(to_upper "$1")
	shift

	if [ -z "${_UTIL_SEARCH_KEYWORD}" ]; then
		pecho -n ""
		return 1
	fi

	_UTIL_SEARCH_PARSED_ARGS=$(pecho -n "$@" | sed 's/[?|&]/ /g')
	for _UTIL_ONE_ARG_PAIR in ${_UTIL_SEARCH_PARSED_ARGS}; do
		_UTIL_ONE_ARG_PAIR_TMP=$(to_upper "${_UTIL_ONE_ARG_PAIR}")
		if pecho -n "${_UTIL_ONE_ARG_PAIR_TMP}" | grep -q "^${_UTIL_SEARCH_KEYWORD}"; then
			_UTIL_ONE_ARG_VALUE=$(pecho -n "${_UTIL_ONE_ARG_PAIR}" | sed -e 's/=/ /g' | awk '{print $2}')
			pecho -n "${_UTIL_ONE_ARG_VALUE}"
			return 0
		fi
	done

	return 1
}

#
# Create temporary zip file
#
# $?		: result
#
util_create_zip_file()
{
	if [ -f "${_UTIL_TMP_UNZIP_FILE}" ]; then
		rm -f "${_UTIL_TMP_UNZIP_FILE}"
	fi
	if [ -f "${_UTIL_TMP_ZIP_FILE}" ]; then
		rm -f "${_UTIL_TMP_ZIP_FILE}"
	fi

	pecho "TEMPORARY FILE FOR ZIP RESULT BY USERDATA/EXTDATA"	>  "${_UTIL_TMP_UNZIP_FILE}"
	pecho "CREATED BY K2HR3 CLI TEST UTILITY"					>> "${_UTIL_TMP_UNZIP_FILE}"

	if ! gzip "${_UTIL_TMP_UNZIP_FILE}"; then
		prn_err "Failed to create zip file(${_UTIL_TMP_ZIP_FILE})."
		rm -f "${_UTIL_TMP_UNZIP_FILE}"
		return 1
	fi
	rm -f "${_UTIL_TMP_UNZIP_FILE}"

	return 0
}

#--------------------------------------------------------------
# Main Response for All test
#--------------------------------------------------------------
#
# Create Dummy Response
#
# $1								: Method(GET/PUT/POST/HEAD/DELETE)
# $2								: URL path and parameters in request
# $3								: body data(string) for post
# $4								: body data(file path) for post
# $5								: need content type header (* this value is not used)
# $6...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#
create_dummy_response()
{
	if [ $# -lt 2 ]; then
		prn_err "Missing options for calling request."
		return 2
	fi

	#
	# Check Parameters
	#
	_DUMMY_METHOD="$1"
	if [ -z "${_DUMMY_METHOD}" ] || { [ "${_DUMMY_METHOD}" != "GET" ] && [ "${_DUMMY_METHOD}" != "HEAD" ] && [ "${_DUMMY_METHOD}" != "PUT" ] && [ "${_DUMMY_METHOD}" != "POST" ] && [ "${_DUMMY_METHOD}" != "DELETE" ]; }; then
		prn_err "Unknown Method($1) options for calling requet."
		return 2
	fi

	_DUMMY_URL_FULL="$2"
	_DUMMY_URL_PATH=$(pecho -n "${_DUMMY_URL_FULL}" | sed -e 's/?.*$//g' -e 's/&.*$//g')

	if pecho -n "${_DUMMY_URL_FULL}" | grep -q '[?|&]'; then
		_DUMMY_URL_ARGS=$(pecho -n "${_DUMMY_URL_FULL}" | sed -e 's/^.*?//g')
	else
		_DUMMY_URL_ARGS=""
	fi
	prn_dbg "(create_dummy_response) all url(${_DUMMY_METHOD}: ${_DUMMY_URL_FULL}) => url(${_DUMMY_METHOD}: ${_DUMMY_URL_PATH}) + args(${_DUMMY_URL_ARGS})"

	_DUMMY_BODY_STRING="$3"
	_DUMMY_BODY_FILE="$4"
	_DUMMY_CONTENT_TYPE="$5"
	if [ $# -le 5 ]; then
		shift $#
	else
		shift 5
	fi

	#
	# Branch by path
	#
	#------------------------------------------------------
	# Version
	#------------------------------------------------------
	if [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/" ]; then
		#
		# Version(/)
		#
		if [ -z "${_DUMMY_METHOD}" ] || [ "${_DUMMY_METHOD}" != "GET" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Not allowed Method(${_DUMMY_METHOD})."
			return 1
		fi
		if [ -n "${_DUMMY_URL_ARGS}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "There is an unnecessary URL arguments.(${_DUMMY_URL_ARGS})."
			return 1
		fi

		K2HR3CLI_REQUEST_EXIT_CODE=200
		_UTIL_RESPONSE_CONTENT='{"version":["v1"]}'
		pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

	elif [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1" ]; then
		#
		# Version(/v1)
		#
		if [ -z "${_DUMMY_METHOD}" ] || [ "${_DUMMY_METHOD}" != "GET" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Not allowed Method(${_DUMMY_METHOD})."
			return 1
		fi
		if [ -n "${_DUMMY_URL_ARGS}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "There is an unnecessary URL arguments.(${_DUMMY_URL_ARGS})."
			return 1
		fi

		K2HR3CLI_REQUEST_EXIT_CODE=200
		_UTIL_RESPONSE_CONTENT='{"version":{"/":["GET"],"/v1":["GET"]},"usertoken":{"/v1/user/tokens":["HEAD","GET","POST"]},"host":{"/v1/host":["GET","PUT","POST","DELETE"],"/v1/host/{port}":["PUT","POST","DELETE"],"/v1/host/FQDN":["DELETE"],"/v1/host/FQDN:{port}":["DELETE"],"/v1/host/IP":["DELETE"],"/v1/host/IP:{port}":["DELETE"]},"role":{"/v1/role":["PUT","POST"],"/v1/role/{role}":["HEAD","GET","PUT","POST","DELETE"],"/v1/role/token/{role}":["GET"]},"resource":{"/v1/resource":["PUT","POST"],"/v1/resource/{resource}":["HEAD","GET","DELETE"]},"policy":{"/v1/policy":["PUT","POST"],"/v1/policy/{policy}":["HEAD","GET","DELETE"]},"list":{"/v1/list":["HEAD","GET"],"/v1/list/{role,resource,policy}/{path}":["HEAD","GET"]}}'
		pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#------------------------------------------------------
	# Token
	#------------------------------------------------------
	elif [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/user/tokens" ]; then
		#
		# Token(/v1/user/tokens)
		#
		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "HEAD" ]; then
			#
			# HEAD Token(/v1/user/tokens)
			#
			if [ -n "${_DUMMY_URL_ARGS}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "There is an unnecessary URL arguments.(${_DUMMY_URL_ARGS})."
				return 1
			fi
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=204
			_UTIL_RESPONSE_CONTENT=''
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
			#
			# PUT Token(/v1/user/tokens)
			#
			if [ -n "${_DUMMY_URL_ARGS}" ]; then
				#
				# From user credential or unscoped token
				#
				_UTIL_TMP_USERNAME=$(util_search_urlarg "username" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_PASSPHRASE=$(util_search_urlarg "password" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_TENANT=$(util_search_urlarg "tenantname" "${_DUMMY_URL_ARGS}")
				prn_dbg "(create_dummy_response) all url args(${_DUMMY_URL_ARGS}) => username(${_UTIL_TMP_USERNAME}) + password(${_UTIL_TMP_PASSPHRASE}) + tenantname(${_UTIL_TMP_TENANT})"

				if [ -n "${_UTIL_TMP_USERNAME}" ] && [ -n "${_UTIL_TMP_PASSPHRASE}" ] && [ -n "${_UTIL_TMP_TENANT}" ]; then
					#
					# Scoped token from user credential
					#
					_UTIL_TMP_HEAD_VALUE=$(util_search_header "x-auth-token" "$@")
					if [ -n "${_UTIL_TMP_HEAD_VALUE}" ]; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "There is an unnecessary \"x-auth-token\" header.(${_UTIL_TMP_HEAD_VALUE})."
						return 1
					fi

					K2HR3CLI_REQUEST_EXIT_CODE=201
					_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":true,\"token\":\"TEST_TOKEN_SCOPED_FOR_TENANT_${_UTIL_TMP_TENANT}_USER_${_UTIL_TMP_USERNAME}\"}"
					pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				elif [ -n "${_UTIL_TMP_USERNAME}" ] && [ -n "${_UTIL_TMP_PASSPHRASE}" ] && [ -z "${_UTIL_TMP_TENANT}" ]; then
					#
					# Unscoped token from user credential
					#
					_UTIL_TMP_HEAD_VALUE=$(util_search_header "x-auth-token" "$@")
					if [ -n "${_UTIL_TMP_HEAD_VALUE}" ]; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "There is an unnecessary \"x-auth-token\" header.(${_UTIL_TMP_HEAD_VALUE})."
						return 1
					fi

					K2HR3CLI_REQUEST_EXIT_CODE=201
					_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":false,\"token\":\"TEST_TOKEN_UNSCOPED_FOR_USER_${_UTIL_TMP_USERNAME}\"}"
					pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				elif [ -z "${_UTIL_TMP_USERNAME}" ] && [ -z "${_UTIL_TMP_PASSPHRASE}" ] && [ -n "${_UTIL_TMP_TENANT}" ]; then
					#
					# Scoped token from unscoped token
					#
					if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						return 1
					fi

					K2HR3CLI_REQUEST_EXIT_CODE=201
					_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":true,\"token\":\"TEST_TOKEN_SCOPED_FOR_TENANT_${_UTIL_TMP_TENANT}_UNSCOPED_${_UTIL_TMP_TOKENVAL}\"}"
					pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				else
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "Username or Password or Tanantname are wrong in URL arguments."
					return 1
				fi

			else
				#
				# From oprnstack or OIDC token
				#
				if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					return 1
				fi
				_UTIL_TMP_TENANT=$(util_search_header "tenantname" "${_DUMMY_URL_ARGS}")

				if [ -z "${_UTIL_TMP_TENANT}" ]; then
					#
					# Unscoped token from openstack or OIDC token
					#
					K2HR3CLI_REQUEST_EXIT_CODE=201
					_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":false,\"token\":\"TEST_TOKEN_UNSCOPED_FOR_OTHER_${_UTIL_TMP_TOKENVAL}\"}"
					pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				else
					#
					# Scoped token from openstack or OIDC token
					#
					K2HR3CLI_REQUEST_EXIT_CODE=201
					_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":true,\"token\":\"TEST_TOKEN_SCOPED_FOR_TENANT_${_UTIL_TMP_TENANT}_OTHER_${_UTIL_TMP_TOKENVAL}\"}"
					pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
				fi
			fi

		elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "POST" ]; then
			#
			# POST Token(/v1/user/tokens)
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				_UTIL_TMP_TOKENVAL=""
			fi

			_UTIL_TMP_USERNAME=""
			_UTIL_TMP_PASSPHRASE=""
			_UTIL_TMP_TENANT=""
			if [ -n "${_DUMMY_BODY_STRING}" ]; then
				if jsonparser_parse_json_string "${_DUMMY_BODY_STRING}"; then
					if jsonparser_get_key_value '%"auth"%"tenantName"%' "${JP_PAERSED_FILE}"; then
						_UTIL_TMP_TENANT=${JSONPARSER_FIND_STR_VAL}
					fi

					if jsonparser_get_key_value '%"auth"%"passwordCredentials"%"username"%' "${JP_PAERSED_FILE}"; then
						_UTIL_TMP_USERNAME=${JSONPARSER_FIND_STR_VAL}
					fi

					if jsonparser_get_key_value '%"auth"%"passwordCredentials"%"password"%' "${JP_PAERSED_FILE}"; then
						_UTIL_TMP_PASSPHRASE=${JSONPARSER_FIND_STR_VAL}
					fi

					if [ -n "${_UTIL_TMP_USERNAME}" ] && [ -z "${_UTIL_TMP_PASSPHRASE}" ]; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "Credential is specified, but passphrase is empty."
						return 1
					elif [ -z "${_UTIL_TMP_USERNAME}" ] && [ -n "${_UTIL_TMP_PASSPHRASE}" ]; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "Credential is specified, but username is empty."
						return 1
					fi
				fi
				rm -f "${JP_PAERSED_FILE}"
			fi

			if [ -n "${_UTIL_TMP_USERNAME}" ]; then
				#
				# Specified User Credential
				#
				if [ -n "${_UTIL_TMP_TOKENVAL}" ]; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "There is an unnecessary \"x-auth-token\" header.(${_UTIL_TMP_HEAD_VALUE})."
					return 1
				fi

				if [ -z "${_UTIL_TMP_TENANT}" ]; then
					#
					# Create Unscoped Token from credential
					#
					K2HR3CLI_REQUEST_EXIT_CODE=201
					_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":false,\"token\":\"TEST_TOKEN_UNSCOPED_FOR_USER_${_UTIL_TMP_USERNAME}\"}"
					pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
				else
					#
					# Create Scoped Token from credential
					#
					K2HR3CLI_REQUEST_EXIT_CODE=201
					_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":true,\"token\":\"TEST_TOKEN_SCOPED_FOR_TENANT_${_UTIL_TMP_TENANT}_USER_${_UTIL_TMP_USERNAME}\"}"
					pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
				fi

			elif [ -n "${_UTIL_TMP_TENANT}" ]; then
				#
				# Specified only tenant
				#
				if [ -z "${_UTIL_TMP_TOKENVAL}" ]; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "There is no \"x-auth-token\" header."
					return 1
				fi

				#
				# Create Scoped Token from unscoped token(or OpenStack/OIDC token)
				#
				K2HR3CLI_REQUEST_EXIT_CODE=201
				_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":true,\"token\":\"TEST_TOKEN_SCOPED_FOR_TENANT_${_UTIL_TMP_TENANT}_UNSCOPED_${_UTIL_TMP_TOKENVAL}\"}"
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			else
				#
				# Specified nothing
				#
				if [ -z "${_UTIL_TMP_TOKENVAL}" ]; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "Username or Password or Tanantname or Token are not specified."
					return 1
				fi

				#
				# Create Unscoped Token from OpenStack/OIDC token(or unscoped token)
				#
				K2HR3CLI_REQUEST_EXIT_CODE=201
				_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":false,\"token\":\"TEST_TOKEN_UNSCOPED_FOR_OTHER_${_UTIL_TMP_TOKENVAL}\"}"
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
			fi

		elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
			#
			# GET Token(/v1/user/tokens)
			#
			if [ -n "${_DUMMY_URL_ARGS}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "There is an unnecessary URL arguments.(${_DUMMY_URL_ARGS})."
				return 1
			fi

			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			if pecho "${_UTIL_TMP_TOKENVAL}" | grep -q '^TEST_TOKEN_SCOPED'; then
				#
				# Get tenant list from scoped token
				#
				K2HR3CLI_REQUEST_EXIT_CODE=200
				_UTIL_RESPONSE_CONTENT='{"result":true,"message":"succeed","scoped":true,"user":"test","tenants":[{"name":"test1","display":"test1"}]}'
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			else
				#
				# Get tenant list from unscoped token(same result as scoped token)
				#
				K2HR3CLI_REQUEST_EXIT_CODE=200
				_UTIL_RESPONSE_CONTENT='{"result":true,"message":"succeed","scoped":false,"user":"test","tenants":[{"name":"test1","display":"test1"},{"name":"test2","display":"test2"}]}'
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
			fi

		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Not allowed Method(${_DUMMY_METHOD})."
			return 1
		fi

	#------------------------------------------------------
	# List
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/list/" >/dev/null 2>&1; then
		#
		# List(/v1/list/...)
		#
		if [ -z "${_DUMMY_METHOD}" ] || [ "${_DUMMY_METHOD}" != "GET" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Not allowed Method(${_DUMMY_METHOD})."
			return 1
		fi

		#
		# expand URL argument
		#
		_UTIL_TMP_EXPAND=$(util_search_urlarg "expand" "${_DUMMY_URL_ARGS}")
		prn_dbg "(create_dummy_response) all url args(${_DUMMY_URL_ARGS}) => expand(${_UTIL_TMP_EXPAND})"
		_UTIL_TMP_EXPAND=$(to_upper "${_UTIL_TMP_EXPAND}")
		if [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "TRUE" ]; then
			_UTIL_TMP_EXPAND=1
		elif [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "FALSE" ]; then
			_UTIL_TMP_EXPAND=0
		elif [ -z "${_UTIL_TMP_EXPAND}" ]; then
			_UTIL_TMP_EXPAND=0
		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "\"expand\" URL argument value is wrong.(${_DUMMY_URL_ARGS})."
			return 1
		fi

		#
		# Scoped token
		#
		if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi

		#
		# Parse path
		#
		_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/list/##g')
		_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
		_DUMMY_URL_PATH_SECOND_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $2}')
		if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Url first path is empty(${_DUMMY_URL_PATH})."
			return 1
		fi

		if [ "${_DUMMY_URL_PATH_FIRST_PART}" = "service" ]; then
			#
			# List(/v1/list/service/...)
			#
			# [NOTE]
			# Even if the expand option and service name are specified, the response will
			# be almost unchanged, so only one will be returned.
			# ex.	'{"result":true,"message":null,"children":[{"name":"test_service","children":[],"owner":true}]}'
			#		'{"result":true,"message":null,"children":[{"name":"test_service","children":[]}]}'
			#
			K2HR3CLI_REQUEST_EXIT_CODE=200
			_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"test_service","children":[],"owner":true}]}'
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif [ "${_DUMMY_URL_PATH_FIRST_PART}" = "resource" ]; then
			#
			# List(/v1/list/resource/...)
			#
			if [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
				if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
					#
					# no-Service / no-Resource / not expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"autocluster","children":[]},{"name":"test_resource","children":[]},{"name":"test_sub_resource","children":[]}]}'
				else
					#
					# no-Service / no-Resource / expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"autocluster","children":[{"name":"server","children":[]},{"name":"slave","children":[]}]},{"name":"test_resource","children":[]},{"name":"test_sub_resource","children":[]}]}'
				fi
			else
				if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
					#
					# no-Service / Resource / not expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"test_child_resource","children":[]}]}'
				else
					#
					# no-Service / Resource / expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"test_child_resource","children":[]}]}'
				fi
			fi

		elif [ "${_DUMMY_URL_PATH_FIRST_PART}" = "policy" ]; then
			#
			# List(/v1/list/policy/...)
			#
			if [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
				if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
					#
					# no-Service / no-Policy / not expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"autocluster","children":[]},{"name":"test_policy","children":[]},{"name":"test_sub_policy","children":[]}]}'
				else
					#
					# no-Service / no-Policy / expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"autocluster","children":[]},{"name":"test_policy","children":[]},{"name":"test_sub_policy","children":[]}]}'
				fi
			else
				if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
					#
					# no-Service / Policy / not expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
				else
					#
					# no-Service / Policy / expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
				fi
			fi

		elif [ "${_DUMMY_URL_PATH_FIRST_PART}" = "role" ]; then
			#
			# List(/v1/list/role/...)
			#
			if [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
				if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
					#
					# no-Service / no-Role / not expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"autocluster","children":[]},{"name":"test_role","children":[]},{"name":"test_sub_role","children":[]}]}'
				else
					#
					# no-Service / no-Role / expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[{"name":"autocluster","children":[{"name":"server","children":[]},{"name":"slave","children":[]}]},{"name":"test_role","children":[]},{"name":"test_sub_role","children":[]}]}'
				fi
			else
				if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
					#
					# no-Service / Role / not expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
				else
					#
					# no-Service / Role / expand
					#
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
				fi
			fi

		else
			if [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
				#
				# List(/v1/list/<service>)
				#
				K2HR3CLI_REQUEST_EXIT_CODE=400

			elif [ "${_DUMMY_URL_PATH_SECOND_PART}" = "resource" ]; then
				#
				# List(/v1/list/<service>/resource/...)
				#
				_DUMMY_URL_PATH_THIRD_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $3}')

				if [ -z "${_DUMMY_URL_PATH_THIRD_PART}" ]; then
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						#
						# Service / no-Resource / not expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					else
						#
						# Service / no-Resource / expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					fi
				else
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						#
						# Service / Resource / not expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					else
						#
						# Service / Resource / expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					fi
				fi

			elif [ "${_DUMMY_URL_PATH_SECOND_PART}" = "policy" ]; then
				#
				# List(/v1/list/<service>/policy/...)
				#
				_DUMMY_URL_PATH_THIRD_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $3}')

				if [ -z "${_DUMMY_URL_PATH_THIRD_PART}" ]; then
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						#
						# Service / no-Policy / not expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					else
						#
						# Service / no-Policy / expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					fi
				else
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						#
						# Service / Policy / not expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					else
						#
						# Service / Policy / expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					fi
				fi

			elif [ "${_DUMMY_URL_PATH_SECOND_PART}" = "role" ]; then
				#
				# List(/v1/list/<service>/role/...)
				#
				_DUMMY_URL_PATH_THIRD_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $3}')

				if [ -z "${_DUMMY_URL_PATH_THIRD_PART}" ]; then
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						#
						# Service / no-Role / not expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					else
						#
						# Service / no-Role / expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					fi
				else
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						#
						# Service / Role / not expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					else
						#
						# Service / Role / expand
						#
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"children":[]}'
					fi
				fi

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url path is wrong(${_DUMMY_URL_PATH})."
				return 1
			fi
		fi
		K2HR3CLI_REQUEST_EXIT_CODE=200
		pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

	#------------------------------------------------------
	# Role
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/role" >/dev/null 2>&1; then
		#
		# Role
		#
		if [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/role" ]; then
			#
			# Create Role(/v1/role)
			#
			if [ -z "${_DUMMY_METHOD}" ] || [ "${_DUMMY_METHOD}" != "PUT" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

			#
			# Scoped token
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			#
			# Url arguments
			#
			_UTIL_TMP_ROLENAME=$(util_search_urlarg "name" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_POLICIES=$(util_search_urlarg "policies" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_ALIAS=$(util_search_urlarg "alias" "${_DUMMY_URL_ARGS}")
			if [ -z "${_UTIL_TMP_ROLENAME}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not found role name."
				return 1
			fi
			if [ -z "${_UTIL_TMP_POLICIES}" ]; then
				prn_dbg "Not found policies(optional)."
			fi
			if [ -z "${_UTIL_TMP_ALIAS}" ]; then
				prn_dbg "Not found alias(optional)."
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/role/token/list/" >/dev/null 2>&1; then
			#
			# Show Role Token list(/v1/role/token/list/...)
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/role/token/##g')
			_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
			if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url first path is empty(${_DUMMY_URL_PATH})."
				return 1
			fi

			#
			# expand URL argument
			#
			_UTIL_TMP_EXPAND=$(util_search_urlarg "expand" "${_DUMMY_URL_ARGS}")
			prn_dbg "(create_dummy_response) all url args(${_DUMMY_URL_ARGS}) => expand(${_UTIL_TMP_EXPAND})"
			_UTIL_TMP_EXPAND=$(to_upper "${_UTIL_TMP_EXPAND}")
			if [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "TRUE" ]; then
				_UTIL_TMP_EXPAND=1
			elif [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "FALSE" ]; then
				_UTIL_TMP_EXPAND=0
			elif [ -z "${_UTIL_TMP_EXPAND}" ]; then
				_UTIL_TMP_EXPAND=0
			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "\"expand\" URL argument value is wrong.(${_DUMMY_URL_ARGS})."
				return 1
			fi

			if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
				#
				# Not expand
				#
				_UTIL_RESPONSE_CONTENT='{"result":true,"message":"succeed","tokens":["TEST_TOKEN_ROLE_TEST1","TEST_TOKEN_ROLE_TEST2"]}'
			else
				#
				# expand
				#
				#_UTIL_NOW_TIME=$(date '+%Y-%m-%dT%H:%M%z')
				_UTIL_NOW_TIME="2030-01-01T00:00+0000"
				_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"tokens\":{\"TEST_TOKEN_ROLE_TEST1\":{\"date\":\"${_UTIL_NOW_TIME}\",\"expire\":\"${_UTIL_NOW_TIME}\",\"user\":\"TEST\",\"hostname\":\"localhost\",\"ip\":\"\",\"port\":80,\"cuk\":\"TEST_CUK\",\"registerpath\":\"TEST_REGISTERPATH_ROLE_TOKEN1\"},\"TEST_TOKEN_ROLE_TEST2\":{\"date\":\"${_UTIL_NOW_TIME}\",\"expire\":\"${_UTIL_NOW_TIME}\",\"user\":\"TEST\",\"hostname\":\"localhost2\",\"ip\":\"\",\"port\":8000,\"cuk\":\"TEST_CUK2\",\"registerpath\":\"TEST_REGISTERPATH_ROLE_TOKEN2\"}}}"
			fi
			K2HR3CLI_REQUEST_EXIT_CODE=200
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/role/token/" >/dev/null 2>&1; then
			#
			# Create/Delete Token(/v1/role/token/...)
			#
			_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/role/token/##g')
			_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
			if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url first path is empty(${_DUMMY_URL_PATH})."
				return 1
			fi

			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Create Token
				#
				if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					return 1
				fi

				#
				# expire URL argument
				#
				_UTIL_TMP_EXPIRE=$(util_search_urlarg "expire" "${_DUMMY_URL_ARGS}")
				prn_dbg "(create_dummy_response) all url args(${_DUMMY_URL_ARGS}) => expire(${_UTIL_TMP_EXPIRE})"
				if ! is_positive_number "${_UTIL_TMP_EXPIRE}" >/dev/null 2>&1; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "\"expire\" URL argument value is wrong.(${_DUMMY_URL_ARGS})."
					return 1
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=200
				_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"token\":\"TEST_TOKEN_ROLE_${_DUMMY_URL_PATH_FIRST_PART}_EXPIRE_${_UTIL_TMP_EXPIRE}\",\"registerpath\":\"TEST_REGISTERPATH_ROLE_${_DUMMY_URL_PATH_FIRST_PART}_EXPIRE_${_UTIL_TMP_EXPIRE}\"}"
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
				#
				# Delete Token
				#
				if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					return 1
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=204
				pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

		elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/role/" >/dev/null 2>&1; then
			#
			# Show/Delete Role, Add/Delete Host and Check Role Token(/v1/role/...)
			#
			_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/role/##g')
			_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
			if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url first path is empty(${_DUMMY_URL_PATH})."
				return 1
			fi

			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Show Role
				#
				if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					return 1
				fi

				#
				# expand URL argument
				#
				_UTIL_TMP_EXPAND=$(util_search_urlarg "expand" "${_DUMMY_URL_ARGS}")
				prn_dbg "(create_dummy_response) all url args(${_DUMMY_URL_ARGS}) => expand(${_UTIL_TMP_EXPAND})"
				_UTIL_TMP_EXPAND=$(to_upper "${_UTIL_TMP_EXPAND}")
				if [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "TRUE" ]; then
					_UTIL_TMP_EXPAND=1
				elif [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "FALSE" ]; then
					_UTIL_TMP_EXPAND=0
				elif [ -z "${_UTIL_TMP_EXPAND}" ]; then
					_UTIL_TMP_EXPAND=0
				else
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "\"expand\" URL argument value is wrong.(${_DUMMY_URL_ARGS})."
					return 1
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=200
				if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"role":{"policies":["yrn:yahoo:::demo:policy:test_policy"],"aliases":["yrn:yahoo:::demo:role:test_sub_role"],"hosts":{"hostnames":["localhost * TEST_CUK"],"ips":["127.0.0.1 * TEST_CUK2"]}}}'
				else
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"role":{"policies":["yrn:yahoo:::demo:policy:test_sub_policy","yrn:yahoo:::demo:policy:test_policy"]}}'
				fi
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
				#
				# Add Host
				#
				if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					return 1
				fi

				#
				# Url Arguments
				#
				_UTIL_TMP_HOST=$(util_search_urlarg "host" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_PORT=$(util_search_urlarg "port" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_CUK=$(util_search_urlarg "cuk" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_EXTRA=$(util_search_urlarg "extra" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_TAG=$(util_search_urlarg "tag" "${_DUMMY_URL_ARGS}")
				if [ -z "${_UTIL_TMP_HOST}" ]; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "\"host\" URL argument value is empty."
					return 1
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=201
				_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "HEAD" ]; then
				#
				# Check Role Token
				#
				if ! _UTIL_TMP_TOKENVAL=$(util_search_roletoken "$@"); then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					return 1
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=204
				pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
				#
				# URL arguments
				#
				if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					return 1
				fi

				_UTIL_TMP_HOST=$(util_search_urlarg "host" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_PORT=$(util_search_urlarg "port" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_CUK=$(util_search_urlarg "cuk" "${_DUMMY_URL_ARGS}")

				if [ -z "${_UTIL_TMP_HOST}" ] && [ -z "${_UTIL_TMP_PORT}" ] && [ -z "${_UTIL_TMP_CUK}" ]; then
					#
					# Delete Role
					#
					K2HR3CLI_REQUEST_EXIT_CODE=204
					pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

				else
					#
					# Delete Host
					#
					if [ -z "${_UTIL_TMP_HOST}" ]; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "\"host\" URL argument value is empty."
						return 1
					fi

					K2HR3CLI_REQUEST_EXIT_CODE=204
					pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
				fi
			fi

		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Unknown URL(${_DUMMY_URL_PATH})."
			return 2
		fi

	#------------------------------------------------------
	# Resource
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/resource" >/dev/null 2>&1; then
		#
		# Resource
		#
		if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi

		if [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/resource" ]; then
			#
			# Create Resource(/v1/resource)
			#
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
				#
				# PUT: Url arguments
				#
				_UTIL_TMP_RESOURCENAME=$(util_search_urlarg "name" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_TYPE=$(util_search_urlarg "type" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_DATA=$(util_search_urlarg "data" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_KEYS=$(util_search_urlarg "keys" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_ALIAS=$(util_search_urlarg "alias" "${_DUMMY_URL_ARGS}")

				if [ -z "${_UTIL_TMP_RESOURCENAME}" ]; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "Not found role name."
					return 1
				fi

				_UTIL_TMP_TYPE=$(to_upper "${_UTIL_TMP_TYPE}")
				if [ -z "${_UTIL_TMP_TYPE}" ]; then
					prn_dbg "\"type\" url argument is empty(not update data)."
				elif [ "${_UTIL_TMP_TYPE}" = "NULL" ]; then
					prn_dbg "\"type\" url argument is null(not update data)."
				elif [ "${_UTIL_TMP_TYPE}" = "STRING" ]; then
					prn_dbg "\"type\" url argument is string."
				elif [ "${_UTIL_TMP_TYPE}" = "OBJECT" ]; then
					prn_dbg "\"type\" url argument is object."
				fi

				_UTIL_TMP_KEYS=$(to_upper "${_UTIL_TMP_DATA}")
				if [ -n "${_UTIL_TMP_DATA}" ] && [ "${_UTIL_TMP_DATA}" = "NULL" ]; then
					prn_dbg "\"data\" url argument is null(not update data)."
				elif [ -z "${_UTIL_TMP_DATA}" ]; then
					prn_dbg "\"data\" url argument is empty(not update date)."
				fi

				_UTIL_TMP_KEYS=$(to_upper "${_UTIL_TMP_KEYS}")
				if [ -z "${_UTIL_TMP_KEYS}" ]; then
					prn_dbg "\"keys\" url argument is empty(not update kesy)."
				elif [ "${_UTIL_TMP_KEYS}" = "NULL" ]; then
					prn_dbg "\"keys\" url argument is null(not update keys)."
				fi

				if [ -z "${_UTIL_TMP_ALIAS}" ]; then
					prn_dbg "Not found alias(optional)."
				fi

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "POST" ]; then
				#
				# POST: Url arguments
				#
				if [ -n "${_DUMMY_BODY_FILE}" ] && [ -n "${_DUMMY_BODY_STRING}" ]; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "Both post body file and data are specified."
					return 1
				elif [ -z "${_DUMMY_BODY_FILE}" ] && [ -z "${_DUMMY_BODY_STRING}" ]; then
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "Both post body file and data is not specified."
					return 1
				fi

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/resource/" >/dev/null 2>&1; then
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Show Resource(/v1/resource/...)
				#

				#
				# URL argument
				#
				_UTIL_TMP_SERVICE=$(util_search_urlarg "service" "${_DUMMY_URL_ARGS}")
				if [ -z "${_UTIL_TMP_SERVICE}" ]; then
					prn_dbg "\"service\" url argument is empty."
				fi
				_UTIL_TMP_EXPAND=$(util_search_urlarg "expand" "${_DUMMY_URL_ARGS}")
				prn_dbg "(create_dummy_response) all url args(${_DUMMY_URL_ARGS}) => expand(${_UTIL_TMP_EXPAND})"
				_UTIL_TMP_EXPAND=$(to_upper "${_UTIL_TMP_EXPAND}")
				if [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "TRUE" ]; then
					_UTIL_TMP_EXPAND=1
				elif [ -n "${_UTIL_TMP_EXPAND}" ] && [ "${_UTIL_TMP_EXPAND}" = "FALSE" ]; then
					_UTIL_TMP_EXPAND=0
				elif [ -z "${_UTIL_TMP_EXPAND}" ]; then
					_UTIL_TMP_EXPAND=0
				else
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "\"expand\" URL argument value is wrong.(${_DUMMY_URL_ARGS})."
					return 1
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=200
				if [ -z "${_UTIL_TMP_SERVICE}" ]; then
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"resource":{"string":null,"object":{"data1":"value1","data2":"value2"},"keys":{"key1":"value1","key2":"value2"},"expire":null,"aliases":["yrn:yahoo:::test_tenant:resource:test_resource_sub"]}}'
					else
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"resource":{"string":"test_sub_resource_string","object":{"data1":"value1","data2":"value2"},"keys":{"key1":"value1","key2":"value2"},"expire":null}}'
					fi
				else
					if [ "${_UTIL_TMP_EXPAND}" -eq 0 ]; then
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"resource":{"string":"","object":null,"keys":null,"expire":null,"aliases":[]}}'
					else
						_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"resource":{"string":"","object":null,"keys":null,"expire":null}}'
					fi
				fi
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
				#
				# Delete Resource(/v1/resource/...)
				#

				#
				# expand URL argument
				#
				_UTIL_TMP_TYPE=$(util_search_urlarg "type" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_KEYNAMES=$(util_search_urlarg "keynames" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_ALIASES=$(util_search_urlarg "aliases" "${_DUMMY_URL_ARGS}")

				_UTIL_TMP_TYPE=$(to_upper "${_UTIL_TMP_TYPE}")
				if [ -z "${_UTIL_TMP_TYPE}" ]; then
					prn_dbg "\"type\" url argument is empty(not update data)."
				elif [ "${_UTIL_TMP_TYPE}" = "NULL" ]; then
					prn_dbg "\"type\" url argument is null(not update data)."
				elif [ "${_UTIL_TMP_TYPE}" = "STRING" ]; then
					prn_dbg "\"type\" url argument is string."
				elif [ "${_UTIL_TMP_TYPE}" = "OBJECT" ]; then
					prn_dbg "\"type\" url argument is object."
				elif [ "${_UTIL_TMP_TYPE}" = "KEYS" ]; then
					prn_dbg "\"type\" url argument is keys."
				elif [ "${_UTIL_TMP_TYPE}" = "ALIASES" ]; then
					prn_dbg "\"type\" url argument is aliases."
				elif [ "${_UTIL_TMP_TYPE}" = "ANYTYPE" ]; then
					prn_dbg "\"type\" url argument is anytype."
				else
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "\"type\" URL argument has unknown value(${_UTIL_TMP_TYPE})."
					return 1
				fi

				if [ -n "${_UTIL_TMP_KEYNAMES}" ]; then
					if [ -z "${_UTIL_TMP_TYPE}" ] || [ "${_UTIL_TMP_TYPE}" != "KEYS" ]; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "\"type\" URL argument is not \"keys\", but specified \"keys\" argument(${_UTIL_TMP_KEYNAMES})."
						return 1
					fi
				fi

				if [ -n "${_UTIL_TMP_ALIASES}" ]; then
					if [ -z "${_UTIL_TMP_TYPE}" ] || [ "${_UTIL_TMP_TYPE}" != "ALIASES" ]; then
						K2HR3CLI_REQUEST_EXIT_CODE=400
						prn_err "\"type\" URL argument is not \"aliases\", but specified \"aliases\" argument(${_UTIL_TMP_ALIASES})."
						return 1
					fi
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=204
				pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Unknown URL(${_DUMMY_URL_PATH})."
			return 2
		fi

	#------------------------------------------------------
	# Policy
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/policy" >/dev/null 2>&1; then
		#
		# Policy
		#
		if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi

		if [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/policy" ]; then
			#
			# Create Policy(/v1/policy)
			#
			if [ -z "${_DUMMY_METHOD}" ] || [ "${_DUMMY_METHOD}" != "PUT" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

			#
			# Url arguments
			#
			_UTIL_TMP_POLICYNAME=$(util_search_urlarg "name" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_EFFECT=$(util_search_urlarg "effect" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_ACTION=$(util_search_urlarg "action" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_RESOURCE=$(util_search_urlarg "resource" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_ALIAS=$(util_search_urlarg "alias" "${_DUMMY_URL_ARGS}")

			if [ -z "${_UTIL_TMP_POLICYNAME}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not found policy name."
				return 1
			fi

			_UTIL_TMP_EFFECT=$(to_upper "${_UTIL_TMP_EFFECT}")
			if [ -n "${_UTIL_TMP_EFFECT}" ] && [ "${_UTIL_TMP_EFFECT}" = "ALLOW" ]; then
				prn_dbg "\"effect\" url argument is allow."
			elif [ -n "${_UTIL_TMP_EFFECT}" ] && [ "${_UTIL_TMP_EFFECT}" = "DENY" ]; then
				prn_dbg "\"type\" url argument is deny."
			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "\"effect\" URL argument has unknown value or empty(${_UTIL_TMP_EFFECT})."
				return 1
			fi

			if [ -n "${_UTIL_TMP_ACTION}" ]; then
				prn_dbg "\"action\" URL argument is \"${_UTIL_TMP_ACTION}\"."
			else
				prn_dbg "\"action\" URL argument is empty."
			fi

			if [ -n "${_UTIL_TMP_RESOURCE}" ]; then
				prn_dbg "\"resource\" URL argument is \"${_UTIL_TMP_RESOURCE}\"."
			else
				prn_dbg "\"resource\" URL argument is empty."
			fi

			if [ -n "${_UTIL_TMP_ALIAS}" ]; then
				prn_dbg "\"alias\" URL argument is \"${_UTIL_TMP_ALIAS}\"."
			else
				prn_dbg "\"alias\" URL argument is empty."
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/policy/" >/dev/null 2>&1; then
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Show Policy(/v1/policy/...)
				#

				#
				# URL argument
				#
				_UTIL_TMP_SERVICE=$(util_search_urlarg "service" "${_DUMMY_URL_ARGS}")
				if [ -z "${_UTIL_TMP_SERVICE}" ]; then
					prn_dbg "\"service\" url argument is empty."
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=200
				if [ -z "${_UTIL_TMP_SERVICE}" ]; then
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"policy":{"effect":"allow","action":["yrn:yahoo::::action:read","yrn:yahoo::::action:write"],"resource":["yrn:yahoo:::test_tenant:resource:test_resource1","yrn:yahoo:::test_tenant:resource:test_resource2"],"condition":[],"reference":0,"alias":["yrn:yahoo:::test_tenant:policy:test_sub_policy"]}}'
				else
					_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"policy":{"effect":"allow","action":["yrn:yahoo::::action:read"],"resource":["yrn:yahoo:test_service::test_tenant:resource:test_service_resouce_string"],"condition":[],"reference":0,"alias":[]}}'
				fi
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
				#
				# Delete Policy(/v1/policy/...)
				#
				K2HR3CLI_REQUEST_EXIT_CODE=204
				pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Unknown URL(${_DUMMY_URL_PATH})."
			return 2
		fi

	#------------------------------------------------------
	# Service
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/service" >/dev/null 2>&1; then
		#
		# Service
		#
		if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi

		if [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/service" ]; then
			#
			# Create Service, Delete Service Tenant(/v1/service)
			#
			if [ -z "${_DUMMY_METHOD}" ] || [ "${_DUMMY_METHOD}" != "PUT" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

			#
			# Url arguments
			#
			_UTIL_TMP_SERVICENAME=$(util_search_urlarg "name" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_VERIFY=$(util_search_urlarg "verify" "${_DUMMY_URL_ARGS}")

			if [ -z "${_UTIL_TMP_SERVICENAME}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not found policy name."
				return 1
			fi
			if [ -n "${_UTIL_TMP_VERIFY}" ]; then
				prn_dbg "\"verify\" URL argument is \"${_UTIL_TMP_VERIFY}\"."
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/service/" >/dev/null 2>&1; then
			#
			# Show/Delete Service, Add/Check Service Tenant(/v1/service/...)
			#
			if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
				#
				# Show Service(/v1/policy/...)
				#
				K2HR3CLI_REQUEST_EXIT_CODE=200
				_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"service":{"name":"test_service","owner":"test_tenant","verify":[{"name":"test_service_resouce_string","type":"string","data":null}],"tenant":["yrn:yahoo:::test_tenant","yrn:yahoo:::test_service_member","yrn:yahoo:::test_service_member1"]}}'
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
				#
				# Delete Service, Delete tenant member service(/v1/service/...)
				#
				K2HR3CLI_REQUEST_EXIT_CODE=204
				pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
				#
				# Add Service Tenant(/v1/service/...)
				#

				#
				# Url arguments
				#
				_UTIL_TMP_TENANT=$(util_search_urlarg "tenant" "${_DUMMY_URL_ARGS}")
				_UTIL_TMP_CLEAR_TENANT=$(util_search_urlarg "clear_tenant" "${_DUMMY_URL_ARGS}")

				if [ -n "${_UTIL_TMP_TENANT}" ]; then
					prn_dbg "\"verify\" URL argument is \"${_UTIL_TMP_TENANT}\"."
				fi
				_UTIL_TMP_CLEAR_TENANT=$(to_upper "${_UTIL_TMP_CLEAR_TENANT}")
				if [ -n "${_UTIL_TMP_CLEAR_TENANT}" ] && [ "${_UTIL_TMP_CLEAR_TENANT}" = "TRUE" ]; then
					prn_dbg "\"clear_tenant\" URL argument is true."
				elif [ -n "${_UTIL_TMP_CLEAR_TENANT}" ] && [ "${_UTIL_TMP_CLEAR_TENANT}" = "FALSE" ]; then
					prn_dbg "\"clear_tenant\" URL argument is false."
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=201
				_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
				pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "HEAD" ]; then
				#
				# Check Service Tenant(/v1/service/...)
				#

				#
				# Url arguments
				#
				_UTIL_TMP_TENANT=$(util_search_urlarg "tenant" "${_DUMMY_URL_ARGS}")

				if [ -n "${_UTIL_TMP_TENANT}" ]; then
					prn_dbg "\"verify\" URL argument is \"${_UTIL_TMP_TENANT}\"."
				else
					K2HR3CLI_REQUEST_EXIT_CODE=400
					prn_err "\"tenant\" URL argument is empty. This is not an error by nature, but it is an error because it is a function that the CLI does not provide."
					return 1
				fi

				K2HR3CLI_REQUEST_EXIT_CODE=204
				pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not allowed Method(${_DUMMY_METHOD})."
				return 1
			fi

		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Unknown URL(${_DUMMY_URL_PATH})."
			return 2
		fi

	#------------------------------------------------------
	# ACR
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/acr/" >/dev/null 2>&1; then
		#
		# ACR
		#
		if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi

		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
			#
			# Add ACR(/v1/acr/...)
			#
			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
			#
			# Show ACR(/v1/acr/...) Tenant/Resource
			#

			#
			# Url arguments
			#
			_UTIL_TMP_CIP=$(util_search_urlarg "cip" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_CPORT=$(util_search_urlarg "cport" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_CROLE=$(util_search_urlarg "crole" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_CCUK=$(util_search_urlarg "ccuk" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_SPORT=$(util_search_urlarg "sport" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_SROLE=$(util_search_urlarg "srole" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_SCUK=$(util_search_urlarg "scuk" "${_DUMMY_URL_ARGS}")

			if [ -z "${_UTIL_TMP_CIP}" ] && [ -z "${_UTIL_TMP_CPORT}" ] && [ -z "${_UTIL_TMP_CROLE}" ] && [ -z "${_UTIL_TMP_CCUK}" ] && [ -z "${_UTIL_TMP_SPORT}" ] && [ -z "${_UTIL_TMP_SROLE}" ] && [ -z "${_UTIL_TMP_SCUK}" ]; then
				#
				# Show ACR Tenant
				#
				_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"tokeninfo":{"user":"test","tenant":"test_tenant","service":"test_service"}}'

			elif [ -n "${_UTIL_TMP_CIP}" ] && [ -n "${_UTIL_TMP_CPORT}" ] && [ -n "${_UTIL_TMP_CROLE}" ] && [ -n "${_UTIL_TMP_CCUK}" ] && [ -n "${_UTIL_TMP_SPORT}" ] && [ -n "${_UTIL_TMP_SROLE}" ] && [ -n "${_UTIL_TMP_SCUK}" ]; then
				#
				# Show ACR Resource
				#
				_UTIL_RESPONSE_CONTENT='{"result":true,"message":null,"response":[{"name":"acr_resource","expire":0,"type":"string","data":"test_acr_resource_datae","keys":{"acr_key1":"acr_val1","acr_key2":"acr_val2"}}]}'

			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "The required parameters have not been specified(cip, cport, crole, ccuk, sport, srole, scuk)."
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=200
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
			#
			# Delete ACR(/v1/acr/...)
			#
			K2HR3CLI_REQUEST_EXIT_CODE=204
			pecho "" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

		else
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Not allowed Method(${_DUMMY_METHOD})."
			return 1
		fi

	#------------------------------------------------------
	# USERDATA
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/userdata/" >/dev/null 2>&1; then
		#
		# USERDATA(/v1/userdata/...)
		#
		_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/userdata/##g')
		_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
		if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Url first path is empty(${_DUMMY_URL_PATH})."
			return 1
		fi

		#
		# Make result zip file
		#
		if ! util_create_zip_file; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi
		if ! cp "${_UTIL_TMP_ZIP_FILE}" "${K2HR3CLI_REQUEST_RESULT_FILE}"; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Faild tp copy result file from temporary zip file."
			rm -f "${_UTIL_TMP_ZIP_FILE}"
			return 1
		fi
		rm -f "${_UTIL_TMP_ZIP_FILE}"

		K2HR3CLI_REQUEST_EXIT_CODE=200

	#------------------------------------------------------
	# USERDATA
	#------------------------------------------------------
	elif compare_part_string "${_DUMMY_URL_PATH}" "/v1/extdata/" >/dev/null 2>&1; then
		#
		# EXTDATA(/v1/extdata/...)
		#
		_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/userdata/##g')
		_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
		_DUMMY_URL_PATH_SECOND_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $2}')
		if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Url first path is empty(${_DUMMY_URL_PATH})."
			return 1
		fi
		if [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Url second path is empty(${_DUMMY_URL_PATH})."
			return 1
		fi

		#
		# Check User-Agent header
		#
		_UTIL_TMP_HEAD_VALUE=$(util_search_header "User-Agent" "$@")
		if [ -z "${_UTIL_TMP_HEAD_VALUE}" ]; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "\"User-Agent\" header is not existed."
			return 1
		fi

		#
		# Make result zip file
		#
		if ! util_create_zip_file; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi
		if ! cp "${_UTIL_TMP_ZIP_FILE}" "${K2HR3CLI_REQUEST_RESULT_FILE}"; then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			prn_err "Faild tp copy result file from temporary zip file."
			rm -f "${_UTIL_TMP_ZIP_FILE}"
			return 1
		fi
		rm -f "${_UTIL_TMP_ZIP_FILE}"

		K2HR3CLI_REQUEST_EXIT_CODE=200

	else
		K2HR3CLI_REQUEST_EXIT_CODE=400
		prn_err "Unknown URL(${_DUMMY_URL_PATH})."
		return 2
	fi

	return 0
}

#
# Head Request
#
# $1								: URL path and parameters in request
# $2								: need content type header(1)
# $3...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#	K2HR3CLI_REQUEST_DEBUG_FILE		: curl debug file
#
head_request()
{
	if [ $# -lt 1 ]; then
		prn_err "Missing options for calling CURL."
		return 1
	fi

	_HEAD_OPTION_PATH="$1"
	shift

	if [ $# -gt 0 ]; then
		_HEAD_OPTION_CONTENT_HEAD="$1"
	else
		_HEAD_OPTION_CONTENT_HEAD=""
	fi
	shift

	#
	# Send
	#
	${TEST_CREATE_DUMMY_RESPONSE_FUNC} "HEAD" "${_HEAD_OPTION_PATH}" "" "" "${_HEAD_OPTION_CONTENT_HEAD}" "$@"

	return $?
}

#
# Get Request
#
# $1								: URL path and parameters in request
# $2								: need content type header(1)
# $3...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#	K2HR3CLI_REQUEST_DEBUG_FILE		: curl debug file
#
get_request()
{
	if [ $# -lt 1 ]; then
		prn_err "Missing options for calling CURL."
		return 1
	fi

	_GET_OPTION_PATH="$1"
	shift

	if [ $# -gt 0 ]; then
		_GET_OPTION_CONTENT_HEAD="$1"
	else
		_GET_OPTION_CONTENT_HEAD=""
	fi
	shift

	#
	# Send
	#
	${TEST_CREATE_DUMMY_RESPONSE_FUNC} "GET" "${_GET_OPTION_PATH}" "" "" "${_GET_OPTION_CONTENT_HEAD}" "$@"

	return $?
}

#
# Put Request
#
# $1								: URL path and parameters in request
# $2								: need content type header(1)
# $3...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#	K2HR3CLI_REQUEST_DEBUG_FILE		: curl debug file
#
put_request()
{
	if [ $# -lt 1 ]; then
		prn_err "Missing options for calling CURL."
		return 1
	fi

	_PUT_OPTION_PATH="$1"
	shift

	if [ $# -gt 0 ]; then
		_PUT_OPTION_CONTENT_HEAD="$1"
	else
		_PUT_OPTION_CONTENT_HEAD=""
	fi
	shift

	#
	# Send
	#
	${TEST_CREATE_DUMMY_RESPONSE_FUNC} "PUT" "${_PUT_OPTION_PATH}" "" "" "${_PUT_OPTION_CONTENT_HEAD}" "$@"

	return $?
}

#
# Post Request with Body file
#
# $1								: URL path and parameters in request
# $2								: body data(file path) for post
# $3								: need content type header(1)
# $4...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#	K2HR3CLI_REQUEST_DEBUG_FILE		: curl debug file
#
post_file_request()
{
	if [ $# -lt 2 ]; then
		prn_err "Missing options for calling CURL."
		return 1
	fi

	_POST_OPTION_PATH="$1"
	_POST_OPTION_BODYFILE="$2"
	shift 2

	if [ $# -gt 0 ]; then
		_POST_OPTION_CONTENT_HEAD="$1"
	else
		_POST_OPTION_CONTENT_HEAD=""
	fi
	shift

	#
	# Send
	#
	${TEST_CREATE_DUMMY_RESPONSE_FUNC} "POST" "${_POST_OPTION_PATH}" "" "${_POST_OPTION_BODYFILE}" "${_POST_OPTION_CONTENT_HEAD}" "$@"

	return $?
}

#
# Post Request with String body
#
# $1								: URL path and parameters in request
# $2								: body data(string) for post
# $3								: need content type header(1)
# $4...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#	K2HR3CLI_REQUEST_DEBUG_FILE		: curl debug file
#
post_string_request()
{
	if [ $# -lt 2 ]; then
		prn_err "Missing options for calling CURL."
		return 1
	fi

	_POST_OPTION_PATH="$1"
	_POST_OPTION_BODYSTRING="$2"
	shift 2

	if [ $# -gt 0 ]; then
		_POST_OPTION_CONTENT_HEAD="$1"
	else
		_POST_OPTION_CONTENT_HEAD=""
	fi
	shift

	#
	# Send
	#
	${TEST_CREATE_DUMMY_RESPONSE_FUNC} "POST" "${_POST_OPTION_PATH}" "${_POST_OPTION_BODYSTRING}" "" "${_POST_OPTION_CONTENT_HEAD}" "$@"

	return $?
}

#
# Delete Request
#
# $1								: URL path and parameters in request
# $2								: need content type header(1)
# $3...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#	K2HR3CLI_REQUEST_DEBUG_FILE		: curl debug file
#
delete_request()
{
	if [ $# -lt 1 ]; then
		prn_err "Missing options for calling CURL."
		return 1
	fi

	_DELETE_OPTION_PATH="$1"
	shift

	if [ $# -gt 0 ]; then
		_DELETE_OPTION_CONTENT_HEAD="$1"
	else
		_DELETE_OPTION_CONTENT_HEAD=""
	fi
	shift

	#
	# Send
	#
	${TEST_CREATE_DUMMY_RESPONSE_FUNC} "DELETE" "${_DELETE_OPTION_PATH}" "" "" "${_DELETE_OPTION_CONTENT_HEAD}" "$@"

	return $?
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
