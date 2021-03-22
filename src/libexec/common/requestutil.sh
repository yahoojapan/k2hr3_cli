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
# Utility functions for K2HR3 Request
#--------------------------------------------------------------
#
# Check RESULT in response body formatted json
#
# $1	: json parsed file
# $?	: success is 0
#
requtil_check_result_parsed_file()
{
	#
	# Get "result" value
	#
	jsonparser_get_key_value '%"result"%' "$1"
	if [ $? -ne 0 ]; then
		prn_dbg "(requtil_check_result_parsed_file) Not found \"result\" key in parsed json file."
		return 1
	fi

	#
	# Check result
	#
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_TRUE}" ] && [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_FALSE}" ]; then
		prn_dbg "(requtil_check_result_parsed_file) Unknown value type(${JSONPARSER_FIND_VAL_TYPE}) for \"result\" key in response json."
		return 1
	fi

	if [ "X${JSONPARSER_FIND_VAL}" != "Xtrue" ]; then
		#
		# Result is false
		#
		jsonparser_get_key_value '%"message"%' "$1"
		if [ $? -ne 0 ]; then
			prn_err "RESULT in response body is FALSE : Unknown reason."
		else
			prn_err "RESULT in response body is FALSE : ${JSONPARSER_FIND_VAL}"
		fi
		return 1
	fi
	return 0
}

#
# Check curl result code/http response code and result in response
#
# $1	: curl result code
# $2	: http response code
# $3	: result parsed json file path
# $4	: success http response code
# $5	: if not check result, set 1
# $?	: result
#
requtil_check_result()
{
	if [ $# -lt 4 ]; then
		return 1
	fi
	if [ "X$1" = "X" ] || [ "X$2" = "X" ] || [ "X$3" = "X" ] || [ "X$4" = "X" ]; then
		return 1
	fi
	_CHECK_RESULT_CODE_NOCHECK_RESULT=0
	if [ $# -ge 5 ]; then
		if [ "X$5" = "X1" ]; then
			_CHECK_RESULT_CODE_NOCHECK_RESULT=1
		fi
	fi

	#
	# Check curl response code
	#
	if [ "$1" -eq 1 ]; then
		#
		# Something error occured by curl
		#
		prn_err "Failed to send request by curl."
		return 1

	elif [ "$1" -eq 2 ]; then
		#
		# fatal error
		#
		prn_err "Fatal error send request by curl."
		return 1
	fi

	#
	# Check HTTP response code
	#
	if [ "X$2" = "X$4" ]; then
		#
		# Success -> check result in response body
		#
		if [ "${_CHECK_RESULT_CODE_NOCHECK_RESULT}" -ne 1 ]; then
			requtil_check_result_parsed_file "$3"
			if [ $? -ne 0 ]; then
				return 1
			fi
		fi
		return 0
	fi

	#
	# Error
	#
	prn_err "Unexpected HTTP Response Code = ${K2HR3CLI_REQUEST_EXIT_CODE}."
	if [ "${_CHECK_RESULT_CODE_NOCHECK_RESULT}" -ne 1 ]; then
		requtil_check_result_parsed_file "$3"
	fi
	return 1
}

#
# Added expand url argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_expand_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_EXPAND}" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?expand=true"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&expand=true"
		fi
	else
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?expand=false"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&expand=false"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added policies argements
#
# $1		: base string
# $2		: set null parameter(1)
# $?		: result
# Output	: result string
#
requtil_urlarg_policies_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_POLICIES}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_POLICIES}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?policies=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&policies=${_REQUTIL_OPT_STR_TMP}"
		fi
	elif [ "X$2" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?policies="
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&policies="
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added alias argements
#
# $1		: base string
# $2		: set null parameter(1)
# $?		: result
# Output	: result string
#
requtil_urlarg_alias_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_ALIAS}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_ALIAS}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?alias=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&alias=${_REQUTIL_OPT_STR_TMP}"
		fi
	elif [ "X$2" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?alias="
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&alias="
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added host argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_host_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_HOST}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_HOST}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?host=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&host=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added port argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_port_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_PORT}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_PORT}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?port=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&port=${_REQUTIL_OPT_STR_TMP}"
		fi
	else
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?port=0"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&port=0"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added CUK argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_cuk_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_CUK}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_CUK}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?cuk=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&cuk=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added extra argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_extra_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_EXTRA}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_EXTRA}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?extra=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&extra=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added tag argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_tag_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_TAG}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_TAG}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?tag=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&tag=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added expire argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_expire_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_EXPIRE}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_EXPIRE}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?expire=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&expire=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added type argements
#
# $1		: base string
# $2		: set null parameter(1)
# $?		: result
# Output	: result string
#
requtil_urlarg_type_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_TYPE}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_TYPE}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?type=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&type=${_REQUTIL_OPT_STR_TMP}"
		fi
	elif [ "X$2" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?type="
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&type="
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added data argements
#
# $1		: base string
# $2		: set null parameter(1)
# $?		: result
# Output	: result string
#
requtil_urlarg_data_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_DATA}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_DATA}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?data=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&data=${_REQUTIL_OPT_STR_TMP}"
		fi
	elif [ "X$2" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?data="
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&data="
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added keys argements
#
# $1		: base string
# $2		: set null parameter(1)
# $?		: result
# Output	: result string
#
requtil_urlarg_keys_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_KEYS}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_KEYS}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?keys=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&keys=${_REQUTIL_OPT_STR_TMP}"
		fi
	elif [ "X$2" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?keys="
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&keys="
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added service argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_service_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_SERVICE}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_SERVICE}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?service=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&service=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added keynames argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_keynames_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_KEYNAMES}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_KEYNAMES}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?keynames=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&keynames=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added aliases argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_aliases_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_ALIASES}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_ALIASES}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?aliases=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&aliases=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added effect argements
#
# $1		: base string
# $2		: set null parameter(1)
# $?		: result
# Output	: result string
#
requtil_urlarg_effect_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_EFFECT}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_EFFECT}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?effect=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&effect=${_REQUTIL_OPT_STR_TMP}"
		fi
	elif [ "X$2" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?effect="
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&effect="
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added action argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_action_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_ACTION}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_ACTION}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?action=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&action=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added resource argements
#
# $1		: base string
# $2		: set null parameter(1)
# $?		: result
# Output	: result string
#
requtil_urlarg_resource_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_RESOURCE}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_RESOURCE}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?resource=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&resource=${_REQUTIL_OPT_STR_TMP}"
		fi
	elif [ "X$2" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?resource="
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&resource="
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added verify argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_verify_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_VERIFY}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_VERIFY}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?verify=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&verify=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added clear_tenant argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_clear_tenant_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_CLEAR_TENANT}" = "X1" ]; then
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?clear_tenant=true"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&clear_tenant=true"
		fi
	else
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?clear_tenant=false"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&clear_tenant=false"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added acr cip argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_acr_cip_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_CIP}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_CIP}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?cip=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&cip=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added acr cport argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_acr_cport_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_CPORT}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_CPORT}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?cport=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&cport=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added acr crole argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_acr_crole_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_CROLE}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_CROLE}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?crole=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&crole=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added acr ccuk argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_acr_ccuk_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_CCUK}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_CCUK}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?ccuk=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&ccuk=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added acr sport argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_acr_sport_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_SPORT}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_SPORT}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?sport=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&sport=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added acr srole argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_acr_srole_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_SROLE}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_SROLE}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?srole=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&srole=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Added acr scuk argements
#
# $1		: base string
# $?		: result
# Output	: result string
#
requtil_urlarg_acr_scuk_param()
{
	_REQUTIL_BASE_STR="$1"
	if [ "X${K2HR3CLI_OPT_SCUK}" != "X" ]; then
		_REQUTIL_OPT_STR_TMP=$(k2hr3cli_urlencode "${K2HR3CLI_OPT_SCUK}")
		if [ "X${_REQUTIL_BASE_STR}" = "X" ]; then
			_REQUTIL_BASE_STR="?scuk=${_REQUTIL_OPT_STR_TMP}"
		else
			_REQUTIL_BASE_STR="${_REQUTIL_BASE_STR}&scuk=${_REQUTIL_OPT_STR_TMP}"
		fi
	fi
	pecho -n "${_REQUTIL_BASE_STR}"
	return 0
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
