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
# The file name for variable description in plugin directory
#
CONFIG_VARIABLE_NAMES_FILENAME="variables.sh"

#
# SubCommand(2'nd option)
#
_CONFIG_COMMAND_SUB_SET="set"
_CONFIG_COMMAND_SUB_SHOW="show"
_CONFIG_COMMAND_SUB_CLEAR="clear"

#
# Command type(3'rd option)
#
_CONFIG_COMMAND_TYPE_ALL="all"

#--------------------------------------------------------------
# Load Plugins
#--------------------------------------------------------------
#
# Load K2HR3 CLI Plugin files
#
for _MODELIST_ONE in ${K2HR3CLI_MODES}; do
	if [ -f "${LIBEXECDIR}/${_MODELIST_ONE}/${CONFIG_VARIABLE_NAMES_FILENAME}" ]; then
		. "${LIBEXECDIR}/${_MODELIST_ONE}/${CONFIG_VARIABLE_NAMES_FILENAME}"
		prn_dbg "Loaded ${LIBEXECDIR}/${_MODELIST_ONE}/${CONFIG_VARIABLE_NAMES_FILENAME}"
	fi
done

#--------------------------------------------------------------
# Functions
#--------------------------------------------------------------
#
# Print all variable names and description
#
# $?	: result
#
# [NOTE]
#           +---+----+----+----+----+----+----+----+----+----+----+----+----|
#           ^   ^
#           |   +--- Start for Description
#           +------- Start for Variables Title
#
config_print_all_varnames()
{
	prn_msg "K2HR3CLI_API_URI"
	prn_msg "   Set the URI to the K2HR3 REST API."
	prn_msg "   (ex. \"https://localhost:3000\")"
	prn_msg ""

	prn_msg "K2HR3CLI_USER"
	prn_msg "   Set the user name of K2HR3."
	prn_msg ""

	prn_msg "K2HR3CLI_PASS"
	prn_msg "   Set the passphrase for the K2HR3 user."
	prn_msg "   RECOMMEND THAT THIS VALUE IS NOT SET TO ADDRESS SECURITY"
	prn_msg "   VULNERABILITIES."
	prn_msg ""

	prn_msg "K2HR3CLI_TENANT"
	prn_msg "   Specify the available tenants for K2HR3. A Scoped Token will"
	prn_msg "   be issued to this tenant."
	prn_msg ""

	prn_msg "K2HR3CLI_UNSCOPED_TOKEN"
	prn_msg "   Stores the Unscoped Token for the K2HR3 user."
	prn_msg ""

	prn_msg "K2HR3CLI_SCOPED_TOKEN"
	prn_msg "   Stores Unscoped Tokens for K2HR3 users and tenants."
	prn_msg ""

	prn_msg "K2HR3CLI_OPENSTACK_TOKEN"
	prn_msg "   Stores the (Un)Scoped Token issued by OpenStack."
	prn_msg ""

	if [ "X${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC}" != "X" ]; then
		for _CONFIG_VAR_DESC in ${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC}; do
			${_CONFIG_VAR_DESC}
		done
	fi
}

#
# Print all variable names and values
#
# $?	: result
#
config_print_all_var()
{
	if [ "X${K2HR3CLI_API_URI}" != "X" ]; then
		prn_msg "K2HR3CLI_API_URI: \"${K2HR3CLI_API_URI}\""
	else
		prn_msg "K2HR3CLI_API_URI: (empty)"
	fi

	if [ "X${K2HR3CLI_USER}" != "X" ]; then
		prn_msg "K2HR3CLI_USER: \"${K2HR3CLI_USER}\""
	else
		prn_msg "K2HR3CLI_USER: (empty)"
	fi

	if [ "X${K2HR3CLI_PASS}" != "X" ]; then
		prn_msg "K2HR3CLI_PASS: \"********(${#K2HR3CLI_PASS})\""
	else
		prn_msg "K2HR3CLI_PASS: (empty)"
	fi

	if [ "X${K2HR3CLI_TENANT}" != "X" ]; then
		prn_msg "K2HR3CLI_TENANT: \"${K2HR3CLI_TENANT}\""
	else
		prn_msg "K2HR3CLI_TENANT: (empty)"
	fi

	if [ "X${K2HR3CLI_UNSCOPED_TOKEN}" != "X" ]; then
		prn_msg "K2HR3CLI_UNSCOPED_TOKEN: \"${K2HR3CLI_UNSCOPED_TOKEN}\""
	else
		prn_msg "K2HR3CLI_UNSCOPED_TOKEN: (empty)"
	fi

	if [ "X${K2HR3CLI_SCOPED_TOKEN}" != "X" ]; then
		prn_msg "K2HR3CLI_SCOPED_TOKEN: \"${K2HR3CLI_SCOPED_TOKEN}\""
	else
		prn_msg "K2HR3CLI_SCOPED_TOKEN: (empty)"
	fi

	if [ "X${K2HR3CLI_OPENSTACK_TOKEN}" != "X" ]; then
		prn_msg "K2HR3CLI_OPENSTACK_TOKEN: \"${K2HR3CLI_OPENSTACK_TOKEN}\""
	else
		prn_msg "K2HR3CLI_OPENSTACK_TOKEN: (empty)"
	fi

	if [ "X${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME}" != "X" ]; then
		for _CONFIG_VAR_NAME in ${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME}; do
			${_CONFIG_VAR_NAME}
		done
	fi
}

#
# Print variable names and values
#
# $1	: variable name
# $?	: result
#
config_print_var()
{
	if [ "X$1" = "X" ]; then
		prn_err "Input variable name is empty."
		return 1
	fi

	if [ "X$1" = "XK2HR3CLI_API_URI" ]; then
		if [ "X${K2HR3CLI_API_URI}" != "X" ]; then
			prn_msg "K2HR3CLI_API_URI: \"${K2HR3CLI_API_URI}\""
		else
			prn_msg "K2HR3CLI_API_URI: (empty)"
		fi
		return 0

	elif [ "X$1" = "XK2HR3CLI_USER" ]; then
		if [ "X${K2HR3CLI_USER}" != "X" ]; then
			prn_msg "K2HR3CLI_USER: \"${K2HR3CLI_USER}\""
		else
			prn_msg "K2HR3CLI_USER: (empty)"
		fi
		return 0

	elif [ "X$1" = "XK2HR3CLI_PASS" ]; then
		if [ "X${K2HR3CLI_PASS}" != "X" ]; then
			prn_msg "K2HR3CLI_PASS: \"********(${#K2HR3CLI_PASS})\""
		else
			prn_msg "K2HR3CLI_PASS: (empty)"
		fi
		return 0

	elif [ "X$1" = "XK2HR3CLI_TENANT" ]; then
		if [ "X${K2HR3CLI_TENANT}" != "X" ]; then
			prn_msg "K2HR3CLI_TENANT: \"${K2HR3CLI_TENANT}\""
		else
			prn_msg "K2HR3CLI_TENANT: (empty)"
		fi
		return 0

	elif [ "X$1" = "XK2HR3CLI_UNSCOPED_TOKEN" ]; then
		if [ "X${K2HR3CLI_UNSCOPED_TOKEN}" != "X" ]; then
			prn_msg "K2HR3CLI_UNSCOPED_TOKEN: \"${K2HR3CLI_UNSCOPED_TOKEN}\""
		else
			prn_msg "K2HR3CLI_UNSCOPED_TOKEN: (empty)"
		fi
		return 0

	elif [ "X$1" = "XK2HR3CLI_SCOPED_TOKEN" ]; then
		if [ "X${K2HR3CLI_SCOPED_TOKEN}" != "X" ]; then
			prn_msg "K2HR3CLI_SCOPED_TOKEN: \"${K2HR3CLI_SCOPED_TOKEN}\""
		else
			prn_msg "K2HR3CLI_SCOPED_TOKEN: (empty)"
		fi
		return 0

	elif [ "X$1" = "XK2HR3CLI_OPENSTACK_TOKEN" ]; then
		if [ "X${K2HR3CLI_OPENSTACK_TOKEN}" != "X" ]; then
			prn_msg "K2HR3CLI_OPENSTACK_TOKEN: \"${K2HR3CLI_OPENSTACK_TOKEN}\""
		else
			prn_msg "K2HR3CLI_OPENSTACK_TOKEN: (empty)"
		fi
		return 0

	elif [ "X${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME}" != "X" ]; then
		for _CONFIG_VAR_NAME in ${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME}; do
			${_CONFIG_VAR_NAME}
			if [ $? -eq 0 ]; then
				return 0
			fi
		done
	fi

	return 1
}

#
# Set variable
#
# $1	: variable name
# $2	: variable value
# $?	: result
#
config_set_var()
{
	if [ "X$1" = "X" ]; then
		prn_err "Input variable name is empty."
		return 1
	fi
	if [ "X$2" = "X" ]; then
		prn_err "Input value is empty."
		return 1
	fi

	#
	# Check the variable name is allowed
	#
	_CONFIG_SET_VAR_FOUND_NAME=0
	if [ "X$1" = "XK2HR3CLI_API_URI" ] || [ "X$1" = "XK2HR3CLI_USER" ] || [ "X$1" = "XK2HR3CLI_PASS" ] || [ "X$1" = "XK2HR3CLI_TENANT" ] || [ "X$1" = "XK2HR3CLI_UNSCOPED_TOKEN" ] || [ "X$1" = "XK2HR3CLI_SCOPED_TOKEN" ] || [ "X$1" = "XK2HR3CLI_OPENSTACK_TOKEN" ]; then
		_CONFIG_SET_VAR_FOUND_NAME=1
	elif [ "X${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR}" != "X" ]; then
		for _CONFIG_CHECK_VAR in ${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR}; do
			${_CONFIG_CHECK_VAR} "$1"
			if [ $? -eq 0 ]; then
				_CONFIG_SET_VAR_FOUND_NAME=1
				break
			fi
		done
	fi
	if [ ${_CONFIG_SET_VAR_FOUND_NAME} -ne 1 ]; then
		prn_err "\"$1\" is not a variable that can be set in the configuration."
		return 1
	fi

	#
	# Configuration file type
	#
	if [ "X${K2HR3CLI_OPT_CONFIG}" != "X" ]; then
		_CONFIG_SET_CONFIG_FILE=${K2HR3CLI_OPT_CONFIG}
	elif [ "X${K2HR3CLI_CUSTOM_CONFIG}" != "X" ]; then
		_CONFIG_SET_CONFIG_FILE=${K2HR3CLI_CUSTOM_CONFIG}
	else
		_CONFIG_SET_CONFIG_FILE=
	fi

	#
	# Set variables
	#
	_CONFIG_BACKUP_OPT_SABE=${K2HR3CLI_OPT_SAVE}
	K2HR3CLI_OPT_SAVE=1
	if [ "X${_CONFIG_SET_CONFIG_FILE}" != "X" ]; then
		config_set_key "${_CONFIG_SET_CONFIG_FILE}" "$1" "$2"
	else
		config_default_set_key "$1" "$2"
	fi
	if [ $? -ne 0 ]; then
		if [ "${_CONFIG_SET_CONFIG_FILE}" = "X" ]; then
			_CONFIG_SET_CONFIG_FILE=$(config_get_default_user_path)
		fi
		K2HR3CLI_OPT_SAVE=${_CONFIG_BACKUP_OPT_SABE}
		prn_err "Failed to set value to \"$1\" in the configuration file(${_CONFIG_SET_CONFIG_FILE})."
		return 1
	fi
	K2HR3CLI_OPT_SAVE=${_CONFIG_BACKUP_OPT_SABE}

	return 0
}

#
# Clear variable
#
# $1	: variable name
# $?	: result
#
config_clear_var()
{
	if [ "X$1" = "X" ]; then
		prn_err "Input variable name is empty."
		return 1
	fi

	#
	# Check the variable name is allowed
	#
	_CONFIG_CLEAR_VAR_FOUND_NAME=0
	if [ "X$1" = "XK2HR3CLI_API_URI" ] || [ "X$1" = "XK2HR3CLI_USER" ] || [ "X$1" = "XK2HR3CLI_PASS" ] || [ "X$1" = "XK2HR3CLI_TENANT" ] || [ "X$1" = "XK2HR3CLI_UNSCOPED_TOKEN" ] || [ "X$1" = "XK2HR3CLI_SCOPED_TOKEN" ] || [ "X$1" = "XK2HR3CLI_OPENSTACK_TOKEN" ]; then
		_CONFIG_CLEAR_VAR_FOUND_NAME=1
	elif [ "X${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR}" != "X" ]; then
		for _CONFIG_CHECK_VAR in ${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR}; do
			${_CONFIG_CHECK_VAR} "$1"
			if [ $? -eq 0 ]; then
				_CONFIG_CLEAR_VAR_FOUND_NAME=1
				break
			fi
		done
	fi
	if [ ${_CONFIG_CLEAR_VAR_FOUND_NAME} -ne 1 ]; then
		prn_err "\"$1\" is not a variable that can be set in the configuration."
		return 1
	fi

	#
	# Configuration file type
	#
	if [ "X${K2HR3CLI_OPT_CONFIG}" != "X" ]; then
		_CONFIG_CLEAR_CONFIG_FILE=${K2HR3CLI_OPT_CONFIG}
	elif [ "X${K2HR3CLI_CUSTOM_CONFIG}" != "X" ]; then
		_CONFIG_CLEAR_CONFIG_FILE=${K2HR3CLI_CUSTOM_CONFIG}
	else
		_CONFIG_CLEAR_CONFIG_FILE=$(config_get_default_user_path)
	fi

	#
	# Clear variables
	#
	_CONFIG_BACKUP_OPT_SABE=${K2HR3CLI_OPT_SAVE}
	K2HR3CLI_OPT_SAVE=1
	config_unset_key "${_CONFIG_CLEAR_CONFIG_FILE}" "$1"
	if [ $? -ne 0 ]; then
		prn_err "Failed to clear value to \"$1\" in the configuration file(${_CONFIG_CLEAR_CONFIG_FILE})."
		K2HR3CLI_OPT_SAVE=${_CONFIG_BACKUP_OPT_SABE}
		return 1
	fi
	K2HR3CLI_OPT_SAVE=${_CONFIG_BACKUP_OPT_SABE}

	return 0
}

#--------------------------------------------------------------
# Parse arguments
#--------------------------------------------------------------
#
# Sub-command
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

#
# 3'rd parameter if it is exited
#
_CONFIG_3RD_PARAM=""
parse_noprefix_option "$@"
if [ $? -eq 0 ]; then
	if [ "X${K2HR3CLI_OPTION_NOPREFIX}" != "X" ]; then
		_CONFIG_3RD_PARAM="${K2HR3CLI_OPTION_NOPREFIX}"
	fi
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
if [ "X${K2HR3CLI_SUBCOMMAND}" = "X${_CONFIG_COMMAND_SUB_SHOW}" ]; then
	#
	# SHOW
	#
	__CONFIG_3RD_PARAM_TMP=$(to_lower "${_CONFIG_3RD_PARAM}")
	if [ "X${_CONFIG_3RD_PARAM}" = "X" ]; then
		#
		# show all variable names and details
		#
		config_print_all_varnames

	elif [ "X${__CONFIG_3RD_PARAM_TMP}" = "X${_CONFIG_COMMAND_TYPE_ALL}" ]; then
		#
		# show all variables
		#
		config_print_all_var

	else
		#
		# show one variable
		#
		config_print_var "${_CONFIG_3RD_PARAM}"
		if [ $? -ne 0 ]; then
			prn_err "Unknown configuration variable(\"${_CONFIG_3RD_PARAM}\")."
			exit 1
		fi
	fi

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${_CONFIG_COMMAND_SUB_SET}" ]; then
	#
	# SET
	#

	#
	# Check parameters
	#
	_CONFIG_4TH_PARAM=""
	parse_noprefix_option "$@"
	if [ $? -eq 0 ]; then
		if [ "X${K2HR3CLI_OPTION_NOPREFIX}" != "X" ]; then
			_CONFIG_4TH_PARAM="${K2HR3CLI_OPTION_NOPREFIX}"
		fi
	fi
	if [ "X${_CONFIG_3RD_PARAM}" = "X" ] || [ "X${_CONFIG_4TH_PARAM}" = "X" ]; then
		prn_err "\"${_CONFIG_COMMAND_SUB_SET}\" sub command needs more parameter(for variable name and value), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

	#
	# Set
	#
	config_set_var "${_CONFIG_3RD_PARAM}" "${_CONFIG_4TH_PARAM}"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	if [ "X${_CONFIG_3RD_PARAM}" = "XK2HR3CLI_PASS" ]; then
		_CONFIG_4TH_PARAM="********(${#K2HR3CLI_PASS})"
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Set \"${_CONFIG_3RD_PARAM}: ${_CONFIG_4TH_PARAM}\""

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${_CONFIG_COMMAND_SUB_CLEAR}" ]; then
	#
	# CLEAR
	#

	#
	# Check parameters
	#
	if [ "X${_CONFIG_3RD_PARAM}" = "X" ]; then
		prn_err "\"${_CONFIG_COMMAND_SUB_CLEAR}\" sub command needs more parameter(for variable name), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

	#
	# Clear
	#
	config_clear_var "${_CONFIG_3RD_PARAM}"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	prn_msg "${CGRN}Succeed${CDEF} : Clear(unset) \"${_CONFIG_3RD_PARAM}:\""

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${_CONFIG_COMMAND_SUB_SHOW}, ${_CONFIG_COMMAND_SUB_SET} and ${_CONFIG_COMMAND_SUB_CLEAR}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
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
