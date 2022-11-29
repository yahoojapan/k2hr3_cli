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
#	K2HR3CLI_REQUEST_DEBUG_FILE		: file of curl debug by request
#
K2HR3CLI_REQUEST_RESULT_FILE="/tmp/.${BINNAME}_$$_curl.result"
K2HR3CLI_REQUEST_RESHEADER_FILE="/tmp/.${BINNAME}_$$_curl.header"
K2HR3CLI_REQUEST_DEBUG_FILE="/tmp/.${BINNAME}_$$_curl.debug"

#--------------------------------------------------------------
# Utilities
#--------------------------------------------------------------
# [Variables]
#	K2HR3CLI_API_URI			: URI to K2HR3 REST API
#	K2HR3CLI_OPT_JSON			: result formatted by json
#
# [NOTE]
# Call curl using the following options conditionally.
#
#	-v							: if K2HR3CLI_OPT_CURLDBG=1(--curldebug(-cd)), this option is granted.
#	-s							: always set for silent
#	-S							: always set for silent without error message
#	-w "%{http_code}\n"			: always specified to get the exit code.
#	-o <output temporary file>	: he response body outputs to a temporary file.
#								  this file will be deleted after processing.
#	-X <method>					: specified method(GET/PUT/POST/HEAD/DELETE)
#	-H <headers>				: instructs to specify the header.(not has space)
#								  specify "Content-Type: application/json" in most cases.
#								  if authentication is required, specify "x-auth-token".
#								  headers are added when specified from the outside.
#								  [NOTICE]
#								  Only the ':' character between the header name and its
#								  value, NO SPACES..
#

#
# Common options for curl
#
_REQUEST_OPTION_SILENT="-s -S"
_REQUEST_OPTION_EXITCODE="-w '%{http_code}\n'"
_REQUEST_OPTION_RESULT_FILE="-o ${K2HR3CLI_REQUEST_RESULT_FILE}"
_REQUEST_OPTION_DBG_FILE="--stderr ${K2HR3CLI_REQUEST_DEBUG_FILE}"
_REQUEST_OPTION_RESHEADER_FILE="--dump-header ${K2HR3CLI_REQUEST_RESHEADER_FILE}"

#--------------------------------------------------------------
# Functions
#--------------------------------------------------------------
#
# Print curl verbose
#
# $?	: result
#
print_curl_verbose()
{
	if [ -n "${K2HR3CLI_OPT_CURLDBG}" ]; then
		if [ "${K2HR3CLI_OPT_CURLDBG}" -eq 1 ]; then
			if [ ! -f "${K2HR3CLI_REQUEST_DEBUG_FILE}" ]; then
				prn_err "Curl Verbose file ${K2HR3CLI_REQUEST_DEBUG_FILE} is not existed."
			else
				prn_msg_stderr "${CREV}[CURL VERBOSE]${CDEF}"
				if [ -n "${K2HR3CLI_PASS}" ]; then
					sed -e "s/=${K2HR3CLI_PASS}/=********/g" "${K2HR3CLI_REQUEST_DEBUG_FILE}" 1>&2
				else
					cat "${K2HR3CLI_REQUEST_DEBUG_FILE}" 1>&2
				fi
			fi
		fi
	fi
	rm -f "${K2HR3CLI_REQUEST_DEBUG_FILE}"

	if [ -n "${K2HR3CLI_OPT_CURLBODY}" ]; then
		if [ "${K2HR3CLI_OPT_CURLBODY}" -eq 1 ]; then
			if [ -f "${K2HR3CLI_REQUEST_RESULT_FILE}" ]; then
				prn_msg_stderr "${CREV}[CURL BODY]${CDEF}"
				if [ -n "${K2HR3CLI_PASS}" ]; then
					sed -e "s/${K2HR3CLI_PASS}/********/g" "${K2HR3CLI_REQUEST_RESULT_FILE}" 1>&2
				else
					cat "${K2HR3CLI_REQUEST_RESULT_FILE}" 1>&2
				fi
				prn_msg_stderr ""
			fi
		fi
	fi
	return 0
}

#
# Send Request
#
# $1								: Method(GET/PUT/POST/HEAD/DELETE)
# $2								: URL path and parameters in request
# $3								: body data(string) for post
# $4								: body data(file path) for post
# $5								: need content type header(1)
# $6...								: other headers (do not include spaces in each header)
#
# $?								: result
#										0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#									  	1	failure(if the curl request fails)
#										2	fatal error
# Variables that change behavior
#	K2HR3CLI_API_URI				: default URI
#	K2HR3CLI_OVERRIDE_URI			: If specified this, use URI instead of K2HR3CLI_API_URI
#	K2HR3CLI_CURL_RESHEADER			: Set "1", output response header to file(K2HR3CLI_REQUEST_RESHEADER_FILE)
#
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#	K2HR3CLI_REQUEST_DEBUG_FILE		: curl debug file
#	K2HR3CLI_REQUEST_RESHEADER_FILE	: response header(case K2HR3CLI_CURL_RESHEADER=1)
#
# [NOTE]
# The following calling method is assumed.
#	ex1) exitcode=$(curl -s -S -X GET -H 'Content-Type: application/json' -w "%{http_code}\n" -o resultfile https://localhost/path?args 2>debugfile)
#	ex2) exitcode=$(curl -s -S -X POST -H 'Content-Type: application/json' -w "%{http_code}\n" -d @file -o resultfile https://localhost/path?args 2>debugfile)
#
# [NOTE]
# If the K2HR3CLI_CURL_RESHEADER environment is "1", put K2HR3CLI_REQUEST_RESHEADER_FILE for response header.
#
raw_request()
{
	if [ $# -lt 2 ]; then
		prn_err "Internal Error : Missing options for calling CURL."
		return 2
	fi

	#
	# URI
	#
	_REQUEST_URI=""
	if [ -n "${K2HR3CLI_OVERRIDE_URI}" ]; then
		_REQUEST_URI=${K2HR3CLI_OVERRIDE_URI}
	else
		if [ -z "${K2HR3CLI_API_URI}" ]; then
			prn_err "K2HR3 REST API endpoint is not specified."
			return 1
		fi
		_REQUEST_URI=${K2HR3CLI_API_URI}
	fi

	#
	# Method
	#
	_REQUEST_OPTION_METHOD_NAME=$(to_upper "$1")
	if [ -z "${_REQUEST_OPTION_METHOD_NAME}" ]; then
		prn_err "Internal Error : Unknown method(empty)"
		return 2
	elif [ "${_REQUEST_OPTION_METHOD_NAME}" != "GET" ] && [ "${_REQUEST_OPTION_METHOD_NAME}" != "PUT" ] && [ "${_REQUEST_OPTION_METHOD_NAME}" != "POST" ] && [ "${_REQUEST_OPTION_METHOD_NAME}" != "HEAD" ] && [ "${_REQUEST_OPTION_METHOD_NAME}" != "DELETE" ]; then
		prn_err "Internal Error : Unknown method($1)"
		return 2
	fi
	_REQUEST_OPTION_METHOD="-X ${_REQUEST_OPTION_METHOD_NAME}"

	#
	# URL path and parameters
	#
	# Escape '&' for /bin/sh / Url Encode
	#
	_REQUEST_OPTION_PATH=$(pecho -n "$2" | sed 's/&/\\&/g')

	#
	# Body data(string)
	#
	_REQUEST_OPTION_BODY=""
	if [ -n "$3" ]; then
		if [ "${_REQUEST_OPTION_METHOD_NAME}" != "POST" ]; then
			prn_err "Internal Error : Body data was specified other than the POST method($1)."
			return 2
		fi
		_REQUEST_OPTION_BODY="-d '$3'"
	fi

	#
	# Body data(file)
	#
	if [ -n "$4" ]; then
		if [ -n "${_REQUEST_OPTION_BODY}" ]; then
			prn_err "Internal Error : Body data is specified as a string and a file."
			return 2
		fi
		if [ "${_REQUEST_OPTION_METHOD_NAME}" != "POST" ]; then
			prn_err "Internal Error : Body data was specified other than the POST method($1)."
			return 2
		fi
		if [ ! -f "$4" ]; then
			prn_err "Body data file($4) is not existed."
			return 2
		fi
		_REQUEST_OPTION_BODY="--data-binary @$4"
	fi

	#
	# Content-type header
	#
	if [ -n "$5" ] && [ "$5" = "1" ]; then
		_REQUEST_OPTION_HEADERS="-H 'Content-Type: application/json'"
	else
		_REQUEST_OPTION_HEADERS=""
	fi

	#
	# Other headers
	#
	shift 5
	while [ $# -gt 0 ]; do
		if [ -n "$1" ]; then
			_REQUEST_OPTION_HEADER_TMP=$(pecho -n "$1" | sed -e 's/:/: /' -e 's/\\s/ /g')
			if [ -n "${_REQUEST_OPTION_HEADERS}" ]; then
				_REQUEST_OPTION_HEADERS="${_REQUEST_OPTION_HEADERS} "
			fi
			_REQUEST_OPTION_HEADERS="${_REQUEST_OPTION_HEADERS}-H '${_REQUEST_OPTION_HEADER_TMP}'"
		fi
		shift
	done

	#
	# -v option
	#
	_REQUEST_OPTION_DBG=""
	if [ -n "${K2HR3CLI_OPT_CURLDBG}" ]; then
		if [ "${K2HR3CLI_OPT_CURLDBG}" -eq 1 ]; then
			_REQUEST_OPTION_DBG="-v"
		fi
	fi

	#
	# --dump-header option
	#
	_REQUEST_OPTION_RESHEADER=
	if [ -n "${K2HR3CLI_CURL_RESHEADER}" ] && [ "${K2HR3CLI_CURL_RESHEADER}" = "1" ]; then
		_REQUEST_OPTION_RESHEADER=${_REQUEST_OPTION_RESHEADER_FILE}
	fi

	#
	# Remove result/response header/debug file and clear exit code
	#
	if [ -f "${K2HR3CLI_REQUEST_RESULT_FILE}" ]; then
		if ! rm "${K2HR3CLI_REQUEST_RESULT_FILE}" >/dev/null 2>&1; then
			prn_err "${K2HR3CLI_REQUEST_RESULT_FILE} is existed and could not remove it."
			return 1
		fi
	fi
	if [ -f "${K2HR3CLI_REQUEST_DEBUG_FILE}" ]; then
		if ! rm "${K2HR3CLI_REQUEST_DEBUG_FILE}" >/dev/null 2>&1; then
			prn_err "${K2HR3CLI_REQUEST_DEBUG_FILE} is existed and could not remove it."
			return 1
		fi
	fi
	if [ -f "${K2HR3CLI_REQUEST_RESHEADER_FILE}" ]; then
		if ! rm "${K2HR3CLI_REQUEST_RESHEADER_FILE}" >/dev/null 2>&1; then
			prn_err "${K2HR3CLI_REQUEST_RESHEADER_FILE} is existed and could not remove it."
			return 1
		fi
	fi

	K2HR3CLI_REQUEST_EXIT_CODE=""

	#
	# Send request by curl
	#
	K2HR3CLI_REQUEST_EXIT_CODE=$(/bin/sh -c "curl ${_REQUEST_OPTION_SILENT} ${_REQUEST_OPTION_DBG} ${_REQUEST_OPTION_RESHEADER} ${_REQUEST_OPTION_EXITCODE} ${_REQUEST_OPTION_RESULT_FILE} ${_REQUEST_OPTION_HEADERS} ${_REQUEST_OPTION_DBG_FILE} ${_REQUEST_OPTION_BODY} ${_REQUEST_OPTION_METHOD} ${_REQUEST_URI}${_REQUEST_OPTION_PATH}")
	K2HR3CLI_REQUEST_CURL_EXITCODE=$?

	#
	# Verbose
	#
	print_curl_verbose

	#
	# Check
	#
	if [ "${K2HR3CLI_REQUEST_CURL_EXITCODE}" -ne 0 ]; then
		prn_err "Something error occured in curl request : [${_REQUEST_OPTION_METHOD}] ${_REQUEST_URI}${_REQUEST_OPTION_PATH}"
		return 1
	fi

	#
	# Check result file
	#
	# [NOTE]
	# If the body data file does not exist for the sake of overall unification,
	# create an empty file.
	# This is because methods such as DELETE / HEAD may not have a file if the
	# body does not exist. It's painful for the caller to determine this every
	# time, so create an empty file.
	#
	if [ ! -f "${K2HR3CLI_REQUEST_RESULT_FILE}" ]; then
		touch "${K2HR3CLI_REQUEST_RESULT_FILE}"
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
	raw_request "HEAD" "${_HEAD_OPTION_PATH}" "" "" "${_HEAD_OPTION_CONTENT_HEAD}" "$@"

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
	raw_request "GET" "${_GET_OPTION_PATH}" "" "" "${_GET_OPTION_CONTENT_HEAD}" "$@"

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
	raw_request "PUT" "${_PUT_OPTION_PATH}" "" "" "${_PUT_OPTION_CONTENT_HEAD}" "$@"

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
	raw_request "POST" "${_POST_OPTION_PATH}" "" "${_POST_OPTION_BODYFILE}" "${_POST_OPTION_CONTENT_HEAD}" "$@"

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
	raw_request "POST" "${_POST_OPTION_PATH}" "${_POST_OPTION_BODYSTRING}" "" "${_POST_OPTION_CONTENT_HEAD}" "$@"

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
	raw_request "DELETE" "${_DELETE_OPTION_PATH}" "" "" "${_DELETE_OPTION_CONTENT_HEAD}" "$@"

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
