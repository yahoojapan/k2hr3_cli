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

#---------------------------------------------------------------------
# Environments and Variables
#---------------------------------------------------------------------
#
# The functions contained in this file are operations related to K2HR3
# Token.
#
# Based on the K2HR3 CLI startup option and the conditions set in the
# configuration, check the expiration date and validity of Unscoped
# Token and Scoped Token, and generate them on the spot if necessary.
# In particular, if interactive option is specified, a prompt will be
# displayed and the Token will be acquired while prompting for input
# as appropriate.
#
# The following global variables are modified by the functions in this file.
#
#	K2HR3CLI_USER
#	K2HR3CLI_PASS
#	K2HR3CLI_TENANT
#	K2HR3CLI_UNSCOPED_TOKEN
#	K2HR3CLI_SCOPED_TOKEN
#	K2HR3CLI_OPENSTACK_TOKEN
#	K2HR3CLI_OIDC_TOKEN
#
# After the ScopedToken has been validated, use the following variables
# to prevent the same Token from being validated again.
# Performance improvement is expected because it is not confirmed every
# time by itself and plugins.
#
#	K2HR3CLI_SCOPED_TOKEN_VERIFIED(1)
#

#--------------------------------------------------------------
# Utilities
#--------------------------------------------------------------
#
# Complement and Set K2HR3 user name
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_USER
#
complement_user_name()
{
	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_USER" "K2HR3 User name: " 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(complement_user_name) K2HR3 User name = \"${K2HR3CLI_USER}\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Complement and Set K2HR3 user passphrase
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_PASS
#
complement_user_passphrase()
{
	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_PASS" "K2HR3 User passphrase: " 1 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(complement_user_passphrase) K2HR3 User passphrase = \"*****(${#K2HR3CLI_PASS})\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Complement and Set OpenStack Token
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_OPENSTACK_TOKEN
#
get_openstack_token()
{
	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_OPENSTACK_TOKEN" "OpenStack Token: " 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(get_openstack_token) OpenStack Token = \"${K2HR3CLI_OPENSTACK_TOKEN}\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Complement and Set OIDC Token
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_OIDC_TOKEN
#
get_oidc_token()
{
	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_OIDC_TOKEN" "OpenID Connect(OIDC) Token: " 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(get_oidc_token) OIDC Token = \"${K2HR3CLI_OIDC_TOKEN}\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Complement and Set Tenant
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_TENANT
#
complement_tenant()
{
	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_TENANT" "Tanant Name(id) for Scoped Token: " 1
	_TOKEN_LIB_RESULT_TMP=$?
	prn_dbg "(complement_tenant) Tanant Name(id) for Scoped Token = \"${K2HR3CLI_TENANT}\"."
	return ${_TOKEN_LIB_RESULT_TMP}
}

#
# Select credential or openstack/OIDC token
#
# $1	: unscoped token based by ("cred" or "op" or "oidc" or "abort", other is selection)
# $?	: selected type(cred:0, openstack:1, oidc:2, error:3)
#
select_credential_type_for_unscopedtoken()
{
	_TOKEN_UPSCOPED_SELECT_BASE=$(to_upper "$1")
	if [ "X${_TOKEN_UPSCOPED_SELECT_BASE}" = "XCRED" ]; then
		#
		# Force : Use user credential(either is not set)
		#
		complement_user_name
		if [ $? -ne 0 ]; then
			return 3
		fi
		complement_user_passphrase
		if [ $? -ne 0 ]; then
			return 3
		fi
		return 0

	elif [ "X${_TOKEN_UPSCOPED_SELECT_BASE}" = "XOP" ]; then
		#
		# Force : Select openstack token
		#
		get_openstack_token
		if [ $? -ne 0 ]; then
			return 3
		fi
		return 1

	elif [ "X${_TOKEN_UPSCOPED_SELECT_BASE}" = "XOIDC" ]; then
		#
		# Force : Select OIDC token
		#
		get_oidc_token
		if [ $? -ne 0 ]; then
			return 3
		fi
		return 2

	else
		#
		# Selection
		#
		if [ "X${K2HR3CLI_USER}" = "X" ] && [ "X${K2HR3CLI_PASS}" = "X" ] && [ "X${K2HR3CLI_OPENSTACK_TOKEN}" = "X" ] && [ "X${K2HR3CLI_OIDC_TOKEN}" = "X" ]; then
			#
			# Need to choose
			#
			_TOKEN_LIBRARY_LOOP_FLAG=1
			while [ "${_TOKEN_LIBRARY_LOOP_FLAG}" -eq 1 ]; do
				_TOKEN_UNSCOPEDTOKEN_BASE_SELECT=""
				completion_variable_auto "_TOKEN_UNSCOPEDTOKEN_BASE_SELECT" "Select either to get the K2HR3 Unscoped Token [K2HR3 user credential (cred) or OpenStack Token (op) or OpenID Connect Token (oidc)]: " 1
				if [ $? -ne 0 ]; then
					return 3
				else
					_TOKEN_UNSCOPEDTOKEN_BASE_SELECT=$(to_upper "${_TOKEN_UNSCOPEDTOKEN_BASE_SELECT}")
					if [ "X${_TOKEN_UNSCOPEDTOKEN_BASE_SELECT}" = "XCRED" ] || [ "X${_TOKEN_UNSCOPEDTOKEN_BASE_SELECT}" = "XOP" ] || [ "X${_TOKEN_UNSCOPEDTOKEN_BASE_SELECT}" = "XOIDC" ]; then
						_TOKEN_LIBRARY_LOOP_FLAG=0
					fi
				fi
			done
			if [ "X${_TOKEN_UNSCOPEDTOKEN_BASE_SELECT}" = "XCRED" ] ;then
				#
				# Select user credential
				#
				complement_user_name
				if [ $? -ne 0 ]; then
					return 3
				fi
				complement_user_passphrase
				if [ $? -ne 0 ]; then
					return 3
				fi
				return 0
			elif [ "X${_TOKEN_UNSCOPEDTOKEN_BASE_SELECT}" = "XOP" ] ;then
				#
				# Select openstack token
				#
				get_openstack_token
				if [ $? -ne 0 ]; then
					return 3
				fi
				return 1

			else
				#
				# Select OIDC token
				#
				get_oidc_token
				if [ $? -ne 0 ]; then
					return 3
				fi
				return 2
			fi

		elif [ "X${K2HR3CLI_USER}" != "X" ] && [ "X${K2HR3CLI_PASS}" != "X" ]; then
			#
			# Use user credential(already set both)
			#
			return 0

		elif [ "X${K2HR3CLI_OPENSTACK_TOKEN}" != "X" ]; then
			#
			# Use openstack toekn(already set)
			#
			return 1

		elif [ "X${K2HR3CLI_OIDC_TOKEN}" != "X" ]; then
			#
			# Use OIDC toekn(already set)
			#
			return 2

		else
			#
			# Use user credential(either is not set)
			#
			complement_user_name
			if [ $? -ne 0 ]; then
				return 3
			fi
			complement_user_passphrase
			if [ $? -ne 0 ]; then
				return 3
			fi
			return 0
		fi
	fi
	return 3
}

#
# Complement and Set K2HR3 unscoped token
#
# $1	: unscoped token based by ("cred" or "op" or "oidc" or "abort", other is selection)
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_USER
#	K2HR3CLI_PASS
#	K2HR3CLI_UNSCOPED_TOKEN
#	K2HR3CLI_OPENSTACK_TOKEN
#	K2HR3CLI_OIDC_TOKEN
#
complement_unscoped_token()
{
	#
	# Check Unscoped Token validation
	#
	if [ "X${K2HR3CLI_UNSCOPED_TOKEN}" != "X" ]; then
		#
		# Head request
		#
		head_request "/v1/user/tokens" 1 "x-auth-token:U=${K2HR3CLI_UNSCOPED_TOKEN}"
		_TOKEN_REQUEST_RESULT=$?

		#
		# Check result
		#
		if [ ${_TOKEN_REQUEST_RESULT} -eq 0 ]; then
			#
			# Request : Success -> Check HTTP response code
			#
			if [ "X${K2HR3CLI_REQUEST_EXIT_CODE}" = "X204" ]; then
				#
				# HTTP response code = 204
				#
				prn_dbg "(complement_unscoped_token) Existed K2HR3 Unscoped Tokens = \"${K2HR3CLI_UNSCOPED_TOKEN}\"."
				rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
				return 0
			fi

			#
			# HTTP response code != 204
			#
			prn_dbg "K2HR3 Unscoped token is invalid or expired."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif [ ${_TOKEN_REQUEST_RESULT} -eq 1 ]; then
			#
			# Something error occured by curl
			#
			prn_err "Failed to send request by curl."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1

		else	# [ ${_TOKEN_REQUEST_RESULT} -eq 2 ]
			#
			# fatal error
			#
			prn_err "Fatal error send request by curl."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1
		fi
	fi

	#--------------------------------------------
	# Unscoped token is invalid or empty
	#--------------------------------------------
	#
	# Select user credential or openstack token
	#
	select_credential_type_for_unscopedtoken "$1"
	_TOKEN_UPSCOPED_TOKEN_BASE=$?

	#
	# Get K2HR3 unscoped token
	#
	if [ ${_TOKEN_UPSCOPED_TOKEN_BASE} -eq 0 ]; then
		#
		# Get K2HR3 Unscoped token by User credential
		#
		_TOKEN_REQUEST_BODY="{\"auth\":{\"passwordCredentials\":{\"username\":\"${K2HR3CLI_USER}\",\"password\":\"${K2HR3CLI_PASS}\"}}}"
		post_string_request "/v1/user/tokens" "${_TOKEN_REQUEST_BODY}" 1
		_TOKEN_REQUEST_RESULT=$?

	elif [ ${_TOKEN_UPSCOPED_TOKEN_BASE} -eq 1 ]; then
		#
		# Get K2HR3 Unscoped token by OpenStack token
		#
		_TOKEN_REQUEST_BODY=""
		post_string_request "/v1/user/tokens" "${_TOKEN_REQUEST_BODY}" 1 "x-auth-token:U=${K2HR3CLI_OPENSTACK_TOKEN}"
		_TOKEN_REQUEST_RESULT=$?

	elif [ ${_TOKEN_UPSCOPED_TOKEN_BASE} -eq 2 ]; then
		#
		# Get K2HR3 Unscoped token by OIDC token
		#
		_TOKEN_REQUEST_BODY=""
		post_string_request "/v1/user/tokens" "${_TOKEN_REQUEST_BODY}" 1 "x-auth-token:U=${K2HR3CLI_OIDC_TOKEN}"
		_TOKEN_REQUEST_RESULT=$?

	else
		prn_err "K2HR3 User Credential or OpenStack Token or OpenID Connect Token for creating K2HR3 Unscoped Tokens is not specified."
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
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
	# Check Result
	#
	requtil_check_result "${_TOKEN_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"
	if [ $? -ne 0 ]; then
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#
	# Check scoped value in json
	#
	jsonparser_get_key_value '%"scoped"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to get K2HR3 unscoped token : \"scoped\" element is not existed in token api response."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_TRUE}" ] && [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_FALSE}" ]; then
		prn_err "Failed to get K2HR3 unscoped token : \"scoped\" element is not \"false\"."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL}" != "Xfalse" ]; then
		prn_err "Failed to get K2HR3 unscoped token : \"scoped\" element is not \"false\"."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#
	# Get token from json
	#
	jsonparser_get_key_value '%"token"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to get K2HR3 unscoped token : \"token\" element is not existed in token api response."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_STR}" ] || [ "X${JSONPARSER_FIND_STR_VAL}" = "X" ]; then
		prn_err "Failed to get K2HR3 unscoped token : \"token\" element is not string or empty."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Got K2HR3 Unscoped Token -> Set K2HR3CLI_UNSCOPED_TOKEN
	#
	K2HR3CLI_UNSCOPED_TOKEN="${JSONPARSER_FIND_STR_VAL}"
	prn_dbg "(complement_unscoped_token) New K2HR3 Unscoped Tokens = \"${K2HR3CLI_UNSCOPED_TOKEN}\"."

	#
	# Set save configuration variable names
	#
	if [ ${_TOKEN_UPSCOPED_TOKEN_BASE} -eq 0 ]; then
		add_config_update_var "K2HR3CLI_USER"
		if [ "X${K2HR3CLI_OPT_SAVE_PASS}" = "X1" ]; then
			add_config_update_var "K2HR3CLI_PASS"
		fi
	elif [ ${_TOKEN_UPSCOPED_TOKEN_BASE} -eq 1 ]; then
		add_config_update_var "K2HR3CLI_OPENSTACK_TOKEN"
	else
		add_config_update_var "K2HR3CLI_OIDC_TOKEN"
	fi
	add_config_update_var "K2HR3CLI_UNSCOPED_TOKEN"

	return 0
}

#
# Complement and Set K2HR3 scoped token
#
# $1	: unscoped token based by ("cred" or "op", other is selection)
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_USER
#	K2HR3CLI_PASS
#	K2HR3CLI_TENANT
#	K2HR3CLI_UNSCOPED_TOKEN
#	K2HR3CLI_SCOPED_TOKEN
#	K2HR3CLI_OPENSTACK_TOKEN
#	K2HR3CLI_OIDC_TOKEN
#
complement_scoped_token()
{
	#
	# Check Scoped Token validation
	#
	if [ "X${K2HR3CLI_SCOPED_TOKEN}" != "X" ]; then
		if [ "X${K2HR3CLI_SCOPED_TOKEN_VERIFIED}" = "X1" ]; then
			prn_dbg "(complement_scoped_token) Already K2HR3 Scoped token is verified = \"${K2HR3CLI_SCOPED_TOKEN}\"."
			return 0
		fi

		#
		# Head request
		#
		head_request "/v1/user/tokens" 1 "x-auth-token:U=${K2HR3CLI_SCOPED_TOKEN}"
		_TOKEN_REQUEST_RESULT=$?

		#
		# Check result
		#
		if [ ${_TOKEN_REQUEST_RESULT} -eq 0 ]; then
			#
			# Request : Success -> Check HTTP response code
			#
			if [ "X${K2HR3CLI_REQUEST_EXIT_CODE}" = "X204" ]; then
				#
				# HTTP response code = 204
				#
				prn_dbg "(complement_scoped_token) Existed K2HR3 Scoped token = \"${K2HR3CLI_SCOPED_TOKEN}\"."
				rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

				return 0
			fi

			#
			# HTTP response code != 204
			#
			prn_dbg "K2HR3 Scoped token is invalid or expired."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"

		elif [ ${_TOKEN_REQUEST_RESULT} -eq 1 ]; then
			#
			# Something error occured by curl
			#
			prn_err "Failed to send request by curl."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1

		else	# [ ${_TOKEN_REQUEST_RESULT} -eq 2 ]
			#
			# fatal error
			#
			prn_err "Fatal error send request by curl."
			rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 1
		fi
	fi

	#
	# Get Unscoped Token
	#
	complement_unscoped_token "$1"
	if [ $? -ne 0 ]; then
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi

	#
	# Check Tenant
	#
	complement_tenant
	if [ $? -ne 0 ]; then
		rm -f "${K2HR3CLI_REQUEST_RESULT_FILE}"
		return 1
	fi

	#--------------------------------------------
	# Scoped token is invalid or empty
	#--------------------------------------------
	#
	# Get K2HR3 Scoped token
	#
	_TOKEN_REQUEST_BODY="{\"auth\":{\"tenantName\":\"${K2HR3CLI_TENANT}\"}}"
	post_string_request "/v1/user/tokens" "${_TOKEN_REQUEST_BODY}" 1 "x-auth-token:U=${K2HR3CLI_UNSCOPED_TOKEN}"
	_TOKEN_REQUEST_RESULT=$?

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
	# Check Result
	#
	requtil_check_result "${_TOKEN_REQUEST_RESULT}" "${K2HR3CLI_REQUEST_EXIT_CODE}" "${JP_PAERSED_FILE}" "201"
	if [ $? -ne 0 ]; then
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#
	# Check scoped value in json
	#
	jsonparser_get_key_value '%"scoped"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to get K2HR3 Scoped token : \"scoped\" element is not existed in token api response."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_TRUE}" ] && [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_FALSE}" ]; then
		prn_err "Failed to get K2HR3 Scoped token : \"scoped\" element is not \"true\"."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL}" != "Xtrue" ]; then
		prn_err "Failed to get K2HR3 Scoped token : \"scoped\" element is not \"true\"."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi

	#
	# Get token from json
	#
	jsonparser_get_key_value '%"token"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to get K2HR3 Scoped token : \"token\" element is not existed in token api response."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	if [ "X${JSONPARSER_FIND_VAL_TYPE}" != "X${JP_TYPE_STR}" ] || [ "X${JSONPARSER_FIND_STR_VAL}" = "X" ]; then
		prn_err "Failed to get K2HR3 Scoped token : \"token\" element is not string or empty."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	#
	# Got K2HR3 Scoped Token -> Set K2HR3CLI_SCOPED_TOKEN
	#
	K2HR3CLI_SCOPED_TOKEN="${JSONPARSER_FIND_STR_VAL}"
	prn_dbg "(complement_scoped_token) New K2HR3 Scoped token = \"${K2HR3CLI_SCOPED_TOKEN}\"."

	#
	# Set save configuration variable names
	#
	add_config_update_var "K2HR3CLI_TENANT"
	add_config_update_var "K2HR3CLI_SCOPED_TOKEN"

	K2HR3CLI_SCOPED_TOKEN_VERIFIED=1

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
