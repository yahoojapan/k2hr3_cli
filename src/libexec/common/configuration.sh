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
# Use Environments and Variables
#---------------------------------------------------------------------
# Allowed variables are loaded from the configuration file. These variable
# is read at startup.
#
# The configuration files are as follows:
#	[Loading Priority]
#	1) Global configuration file:	/etc/antpickax/k2hr3.config (always loading)
#	2) Command option:				--config(-c) value to K2HR3CLI_OPT_CONFIG
#	3) Environment variable:		K2HR3CLI_CUSTOM_CONFIG
#	4) User configuration file:		<USER HOME>/.antpickax/k2hr3.config
#
# The (1)global configuration file is always loaded first.
# Then, if (2)a command option(--config(-c)) with file is specified,
# those variables will be overloaded by option file.
# If no command option is specified and (3)Environment(K2HR3CLI_CUSTOM_CONFIG)
# is specified, those variables will be overwritten by environment's file.
# If neither the command option nor the environment(K2HR3CLI_CUSTOM_CONFIG)
# is specified, those variables will be overwritten by (4)User configuration
# file.
#
# [Case of that individual variables are specified as environment]
# If individual variables are given as environment variables, they
# will be overwritten with the following priorities:
# 
# If the same variable exists in (1)Global configuration file, the
# value of the environment variable takes precedence.
# Also, when (4)User configuration file is loaded, the value of
# the environment variable has priority.
# When any other configuration file((2)optional or specified by
# (3)environment) is loaded, the value of the variable takes
# precedence over the contents of the configuration file.
#
# [Configuration Variables]
# The following are variables that can be stored as a configuration.
# This value is the variable for which the above environment variables
# and variables in the configuration are prioritized.
#	K2HR3CLI_API_URI
#	K2HR3CLI_USER
#	K2HR3CLI_PASS
#	K2HR3CLI_TENANT
#	K2HR3CLI_UNSCOPED_TOKEN
#	K2HR3CLI_SCOPED_TOKEN
#	K2HR3CLI_OPENSTACK_TOKEN
#	K2HR3CLI_OIDC_TOKEN
#

#
# Configuration file for template
#
K2HR3CLI_TEMPLATE_CONFIG="${COMMONDIR}/k2hr3.config"

#
# Global configuration
#
K2HR3CLI_GLOBAL_CONFIG="/etc/antpickax/k2hr3.config"

#
# User configuration : <USER HOME>/.antpickax/k2hr3.config
#
K2HR3_USER_CONFIG_DIRNAME=".antpickax"
K2HR3_USER_CONFIG_FILENAME="k2hr3.config"

#
# Configuration Variables List to save
#
# [NOTE]
# This variable enumerates the variable names if there are variables
# that are automatically updated during processing(variables that
# can be saved in Configuration).
# When the program exits, the variable names listed in this variable
# will be updated if the save option was specified.
#
# Do not manipulate this variable directly, use utility functions.
#
K2HR3CLI_UPDATED_CONFIG_VARS=""

#---------------------------------------------------------------------
# Utility function for modifing configuration file
#---------------------------------------------------------------------
#
# Get user default configuration directory
#
# $?		: result
# Output	: configuration file path
#
config_get_default_user_dir()
{
	_CONFIG_DEFAULT_USER_NAME=$(id -nu)

	# [NOTE]
	# Don't want to use "~user"  because it depends on the HOME environment variable.
	#
	_CONFIG_DEFAULT_USER_HOME=$(grep "${_CONFIG_DEFAULT_USER_NAME}" /etc/passwd | awk -F: '{print $6}' 2>/dev/null)
	if [ -z "${_CONFIG_DEFAULT_USER_HOME}" ]; then
		prn_dbg "(config_get_default_user_dir) Could not get user(${_CONFIG_DEFAULT_USER_NAME}) home directory."
		pecho -n ""
		return 1
	fi

	_CONFIG_DEFAULT_USER_DIR="${_CONFIG_DEFAULT_USER_HOME}/${K2HR3_USER_CONFIG_DIRNAME}"

	pecho -n "${_CONFIG_DEFAULT_USER_DIR}"
	return 0
}

#
# Get user default configuration file path
#
# $?		: result
# Output	: configuration file path
#
config_get_default_user_path()
{
	if ! _CONFIG_DEFAULT_USER_DIR=$(config_get_default_user_dir); then
		pecho -n ""
		return 1
	fi

	_CONFIG_DEFAULT_USER_FILE="${_CONFIG_DEFAULT_USER_DIR}/${K2HR3_USER_CONFIG_FILENAME}"

	pecho -n "${_CONFIG_DEFAULT_USER_FILE}"
	return 0
}

#
# Create new configration file
#
# $1		: file path
# $2		: overwrite(1)
# $?		: result(0/1)
#
config_create_file()
{
	if [ $# -lt 1 ]; then
		prn_dbg "(config_create_file) Insufficient input parameters($#)"
		return 1
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_create_file) Configuration file path is empty."
		return 1
	fi

	_CONFIG_CREATE_FILE_OVERWRITE=0
	if [ $# -gt 1 ]; then
		if [ -n "$2" ] && [ "$2" = "1" ]; then
			_CONFIG_CREATE_FILE_OVERWRITE=1
		fi
	fi
	if [ "${_CONFIG_CREATE_FILE_OVERWRITE}" -ne 1 ]; then
		if [ -f "$1" ]; then
			prn_dbg "(config_create_file) Configuration file($1) is already existed, so could not over write."
			return 1
		fi
	fi

	#
	# Check template file
	#
	if [ ! -f "${K2HR3CLI_TEMPLATE_CONFIG}" ]; then
		prn_err "${K2HR3CLI_TEMPLATE_CONFIG} is the initial file of the configuration file, is missing."
		return 1
	fi

	#
	# Check directory, if not exist, make it
	#
	_CONFIG_CREATE_UMASK_BUP=$(umask)
	umask 0077

	_CONFIG_CREATE_FILE_DIR=$(dirname "$1")
	if [ ! -d "${_CONFIG_CREATE_FILE_DIR}" ]; then
		if [ -f "${_CONFIG_CREATE_FILE_DIR}" ]; then
			prn_err "${_CONFIG_CREATE_FILE_DIR} file is existed, so do not create \"$1\" file."
			umask "${_CONFIG_CREATE_UMASK_BUP}"
			return 1
		fi

		#
		# Try to create directory
		#
		if ! mkdir -p "${_CONFIG_CREATE_FILE_DIR}"; then
			prn_err "Cloud not create ${_CONFIG_CREATE_FILE_DIR} directory."
			umask "${_CONFIG_CREATE_UMASK_BUP}"
			return 1
		fi
	fi

	#
	# Create file
	#
	if ! cat "${K2HR3CLI_TEMPLATE_CONFIG}" > "$1"; then
		prn_err "Failed to create(overwirte) configuration file($1)."
		umask "${_CONFIG_CREATE_UMASK_BUP}"
		return 1
	fi
	umask "${_CONFIG_CREATE_UMASK_BUP}"

	return 0
}

#
# Check default configration file exist
#
# $?		: result(0/1)
#
config_check_default_file()
{
	if ! _CONFIG_DEFAULT_USER_FILE=$(config_get_default_user_path); then
		return 1
	fi

	if [ -f "${_CONFIG_DEFAULT_USER_FILE}" ]; then
		return 0
	fi
	return 1
}

#
# Create new default configration file
#
# $1		: overwrite(1)
# $?		: result(0/1)
#
config_create_default_file()
{
	if ! _CONFIG_DEFAULT_USER_FILE=$(config_get_default_user_path); then
		return 1
	fi

	_CONFIG_CREATE_FILE_OVERWRITE=0
	if [ -n "$1" ] && [ "$1" = "1" ]; then
		_CONFIG_CREATE_FILE_OVERWRITE=1
	fi
	if [ "${_CONFIG_CREATE_FILE_OVERWRITE}" -ne 1 ]; then
		if [ -f "${_CONFIG_DEFAULT_USER_FILE}" ]; then
			prn_dbg "(config_create_file) Configuration file(${_CONFIG_DEFAULT_USER_FILE}) is already existed, so could not over write."
			return 1
		fi
	fi

	config_create_file "${_CONFIG_DEFAULT_USER_FILE}" "${_CONFIG_CREATE_FILE_OVERWRITE}"
	return $?
}

#
# Search key in configration file
#
# $1		: file path
# $2		: key name
# $?		: line number(not found:0)
# Output	: found line string
#
config_search_key()
{
	if [ $# -lt 2 ]; then
		prn_dbg "(config_search_key) Insufficient input parameters($#)"
		pecho -n ""
		return 0
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_search_key) Configuration file path is empty."
		pecho -n ""
		return 0
	fi
	if [ ! -f "$1" ]; then
		prn_dbg "(config_search_key) Configuration file($1) is not existed."
		pecho -n ""
		return 0
	fi
	if [ -z "$2" ]; then
		prn_dbg "(config_search_key) Key name is empty."
		pecho -n ""
		return 0
	fi
	_CONFIG_SEARCH_CONF_FILE="$1"
	_CONFIG_SEARCH_KEY_NAME="$2"

	#
	# Search key and get line
	#
	if ! _CONFIG_SEARCH_FOUND=$(grep -n "^[[:space:]]*${_CONFIG_SEARCH_KEY_NAME}[[:space:]]*=" "${_CONFIG_SEARCH_CONF_FILE}" | head -1 2>/dev/null); then
		prn_dbg "(config_search_key) Key name(${_CONFIG_SEARCH_KEY_NAME}) is not existed in configuration file(${_CONFIG_SEARCH_CONF_FILE})."
		pecho -n ""
		return 0
	fi
	if [ -z "${_CONFIG_SEARCH_FOUND}" ]; then
		prn_dbg "(config_search_key) Key name(${_CONFIG_SEARCH_KEY_NAME}) is not existed in configuration file(${_CONFIG_SEARCH_CONF_FILE})."
		pecho -n ""
		return 0
	fi

	# [NOTE]
	# If multiple lines are detected, only the last line is operated.
	# In the first place, the same key must not exist.
	# And if the same key exists, all you need is the last key.
	#
	_CONFIG_SEARCH_FOUND_NUMBER=$(echo "${_CONFIG_SEARCH_FOUND}" | awk 'END{print $NF}' | sed "s/:/ /g" | awk '{print $1}')
	_CONFIG_SEARCH_FOUND_LINE=$(echo "${_CONFIG_SEARCH_FOUND}" | awk 'END{print $NF}' | sed "s/:/ /g" | awk '{print $2}')

	pecho -n "${_CONFIG_SEARCH_FOUND}"
	return "${_CONFIG_SEARCH_FOUND_NUMBER}"
}

#
# Get key and value from configration file
#
# $1		: file path
# $2		: key name
# $?		: result(found:0, not found:1)
# Output	: value
#
config_get_keyvalue()
{
	if [ $# -lt 2 ]; then
		prn_dbg "(config_get_keyvalue) Insufficient input parameters($#)"
		pecho -n ""
		return 1
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_get_keyvalue) Configuration file path is empty."
		pecho -n ""
		return 1
	fi
	if [ ! -f "$1" ]; then
		prn_dbg "(config_get_keyvalue) Configuration file($1) is not existed."
		pecho -n ""
		return 1
	fi
	if [ -z "$2" ]; then
		prn_dbg "(config_get_keyvalue) Key name is empty."
		pecho -n ""
		return 1
	fi
	_CONFIG_GET_CONF_FILE="$1"
	_CONFIG_GET_KEY_NAME="$2"

	#
	# Search key and get line
	#
	_CONFIG_GET_KEY_LINE=$(config_search_key "${_CONFIG_GET_CONF_FILE}" "${_CONFIG_GET_KEY_NAME}")
	_CONFIG_GET_KEY_NUMBER=$?
	if [ "${_CONFIG_GET_KEY_NUMBER}" -eq 0 ]; then
		pecho -n ""
		return 1
	fi

	#
	# Parse value
	#
	if ! _CONFIG_KEY_FOUND=$(pecho -n "${_CONFIG_GET_KEY_LINE}" | sed "s/^[[:space:]]*${_CONFIG_GET_KEY_NAME}[[:space:]]*=[[:space:]]*//g" 2>/dev/null); then
		prn_dbg "(config_get_keyvalue) Could not get the value from key(${_CONFIG_GET_KEY_NAME}) in configuration file(${_CONFIG_GET_CONF_FILE})."
		pecho -n ""
		return 1
	fi

	pecho -n "${_CONFIG_KEY_FOUND}"
	return 0
}

#
# Replace/Remove key and value in configration file
#
# $1		: file path
# $2		: key name
# $3		: make backup(if not empty, string means backup file extension. if empty, means not making backup)
# $4		: Specify 1 to delete the key
# $5		: value(allow empty)
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_UPDATED_CONFIG_VARS
#
config_modify_key()
{
	if [ $# -lt 2 ]; then
		prn_dbg "(config_modify_key) Insufficient input parameters($#)"
		return 1
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_modify_key) Configuration file path is empty."
		return 1
	fi
	if [ ! -f "$1" ]; then
		prn_dbg "(config_modify_key) Configuration file($1) is not existed."
		return 1
	fi
	if [ -z "$2" ]; then
		prn_dbg "(config_modify_key) Key name is empty."
		return 1
	fi

	_CONFIG_MODIFY_CONF_FILE="$1"
	_CONFIG_MODIFY_KEY_NAME="$2"
	_CONFIG_MODIFY_BACKUP_EXT=""
	_CONFIG_MODIFY_BACKUP_OPT="-i"
	if [ $# -ge 3 ]; then
		if [ -n "$3" ]; then
			_CONFIG_MODIFY_BACKUP_EXT=".$3"
			_CONFIG_MODIFY_BACKUP_OPT="-i.$3"
		fi
	fi
	_CONFIG_MODIFY_REMOVE_MODE=0
	if [ $# -ge 4 ]; then
		if [ -n "$4" ] && [ "$4" = "1" ]; then
			_CONFIG_MODIFY_REMOVE_MODE=1
		fi
	fi
	if [ $# -ge 5 ]; then
		_CONFIG_MODIFY_VALUE="$5"
	else
		_CONFIG_MODIFY_VALUE=""
	fi

	if pecho -n "${_CONFIG_MODIFY_KEY_NAME}" | grep -q '_PASS$'; then
		if [ -n "${_CONFIG_MODIFY_VALUE}" ]; then
			_CONFIG_MODIFY_LOGGING_VALUE="**********(${#_CONFIG_MODIFY_VALUE})"
		else
			_CONFIG_MODIFY_LOGGING_VALUE="empty"
		fi
	else
		_CONFIG_MODIFY_LOGGING_VALUE=${_CONFIG_MODIFY_VALUE}
	fi

	#
	# Check key existed
	#
	config_search_key "${_CONFIG_MODIFY_CONF_FILE}" "${_CONFIG_MODIFY_KEY_NAME}" >/dev/null
	_CONFIG_SEARCH_NUMBER=$?
	if [ "${_CONFIG_SEARCH_NUMBER}" -gt 0 ]; then
		#
		# Found key
		#
		if [ "${_CONFIG_MODIFY_REMOVE_MODE}" -eq 1 ]; then
			#
			# remove key
			#
			if ! sed "${_CONFIG_MODIFY_BACKUP_OPT}" -e "${_CONFIG_SEARCH_NUMBER}d" "${_CONFIG_MODIFY_CONF_FILE}" >/dev/null 2>&1; then
				prn_dbg "(config_modify_key) Failed remove key(${_CONFIG_MODIFY_KEY_NAME}) in configuration file(${_CONFIG_MODIFY_CONF_FILE}): line number(${_CONFIG_SEARCH_NUMBER})"
				return 1
			fi
			prn_dbg "(config_modify_key) Removed key(${_CONFIG_MODIFY_KEY_NAME}) in configuration file(${_CONFIG_MODIFY_CONF_FILE}): line number(${_CONFIG_SEARCH_NUMBER})"
		else
			#
			# replace key
			#
			if ! sed "${_CONFIG_MODIFY_BACKUP_OPT}" -e "s|^[[:space:]]*${_CONFIG_MODIFY_KEY_NAME}[[:space:]]*=.*$|${_CONFIG_MODIFY_KEY_NAME}=${_CONFIG_MODIFY_VALUE}|g" "${_CONFIG_MODIFY_CONF_FILE}" >/dev/null 2>&1; then
				prn_dbg "(config_modify_key) Failed replace key(${_CONFIG_MODIFY_KEY_NAME}) value(${_CONFIG_MODIFY_LOGGING_VALUE}) in configuration file(${_CONFIG_MODIFY_CONF_FILE})"
				return 1
			fi
			prn_dbg "(config_modify_key) Replaced key(${_CONFIG_MODIFY_KEY_NAME}) value(${_CONFIG_MODIFY_LOGGING_VALUE}) in configuration file(${_CONFIG_MODIFY_CONF_FILE})"
		fi
	else
		#
		# Not found key
		#
		if [ "${_CONFIG_MODIFY_REMOVE_MODE}" -eq 1 ]; then
			#
			# remove key -> nothing to do
			#
			prn_dbg "(config_modify_key) Already key(${_CONFIG_MODIFY_KEY_NAME}) is not exitsed in configuration file(${_CONFIG_MODIFY_CONF_FILE}), so nothing to remove key."
		else
			#
			# add key
			#

			#
			# If lastest line is empty, it is removed here.
			#
			_CONFIG_MODIFY_CONF_LASTLINE=$(tail -1 "${_CONFIG_MODIFY_CONF_FILE}" | sed 's/^[[:space:]]*//g')
			if [ -z "${_CONFIG_MODIFY_CONF_LASTLINE}" ]; then
				#
				# Cut lastest empty line
				#
				_CONFIG_MODIFY_CONF_RMLINE=$(wc -l "${_CONFIG_MODIFY_CONF_FILE}" | awk '{print $1}')
				if ! sed "${_CONFIG_MODIFY_BACKUP_OPT}" -e "${_CONFIG_MODIFY_CONF_RMLINE}d" "${_CONFIG_MODIFY_CONF_FILE}" >/dev/null 2>&1; then
					prn_dbg "(config_modify_key) Failed remove empty lasted line(${_CONFIG_MODIFY_CONF_RMLINE}) in configuration file(${_CONFIG_MODIFY_CONF_FILE})"
					return 1
				fi
				prn_dbg "(config_modify_key) Removed empty lasted line(${_CONFIG_MODIFY_CONF_RMLINE}) in configuration file(${_CONFIG_MODIFY_CONF_FILE})"
			else
				#
				# Copy backup file
				#
				if [ -n "${_CONFIG_MODIFY_BACKUP_EXT}" ]; then
					if ! cp -p "${_CONFIG_MODIFY_CONF_FILE}" "${_CONFIG_MODIFY_CONF_FILE}${_CONFIG_MODIFY_BACKUP_EXT}" >/dev/null 2>&1; then
						prn_dbg "(config_modify_key) Failed remove empty lasted line(${_CONFIG_MODIFY_CONF_RMLINE}) in configuration file(${_CONFIG_MODIFY_CONF_FILE})"
						return 1
					fi
					prn_dbg "(config_modify_key) Remove empty lasted line(${_CONFIG_MODIFY_CONF_RMLINE}) in configuration file(${_CONFIG_MODIFY_CONF_FILE})"
				fi
			fi

			#
			# Add new key and value line
			#
			pecho "" >> "${_CONFIG_MODIFY_CONF_FILE}"
			pecho "${_CONFIG_MODIFY_KEY_NAME}=${_CONFIG_MODIFY_VALUE}" >> "${_CONFIG_MODIFY_CONF_FILE}"
			prn_dbg "(config_modify_key) Added key(${_CONFIG_MODIFY_KEY_NAME}) value(${_CONFIG_MODIFY_LOGGING_VALUE}) in configuration file(${_CONFIG_MODIFY_CONF_FILE})"
		fi
	fi

	return 0
}

#
# Set key and value in configration file(without backup)
#
# $1		: file path
# $2		: key name
# $3		: value(allow empty)
# $?		: result(0/1)
#
config_set_key()
{
	if [ $# -lt 3 ]; then
		prn_dbg "(config_set_key) Insufficient input parameters($#)"
		return 1
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_set_key) Configuration file path is empty."
		return 1
	fi
	if [ -z "$2" ]; then
		prn_dbg "(config_set_key) Key name is empty."
		return 1
	fi
	if [ ! -f "$1" ]; then
		if ! touch "$1" >/dev/null 2>&1; then
			prn_dbg "(config_set_key) Configuration file($1) is not existed, and failed to create new file."
			return 1
		fi
		prn_dbg "(config_set_key) Configuration file($1) is not existed, so create new file"
	fi

	#
	# Remove variable name from K2HR3CLI_UPDATED_CONFIG_VARS
	#
	# [NOTE]
	# The variable will be updated, so if the variable name exists in 
	# K2HR3CLI_UPDATED_CONFIG_VARS, delete it.
	#
	delete_config_update_var "$2"

	#
	# Execute
	#
	config_modify_key "$1" "$2" "" 0 "$3"
	return $?
}

#
# Set key and value in default configration file(without backup)
#
# $1		: key name
# $2		: value(allow empty)
# $?		: result(0/1)
#
config_default_set_key()
{
	if [ -z "${K2HR3CLI_OPT_SAVE}" ]; then
		return 0
	fi
	if [ -z "${K2HR3CLI_OPT_SAVE}" ] || [ "${K2HR3CLI_OPT_SAVE}" != "1" ]; then
		return 0
	fi

	if [ $# -lt 1 ]; then
		prn_dbg "(config_default_modify_key) Insufficient input parameters($#)"
		return 1
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_default_modify_key) Key name is empty."
		return 1
	fi

	#
	# Check and Create default configuration file
	#
	if ! config_check_default_file; then
		if ! config_create_default_file 1; then
			prn_err "Could not find or create default user configuration file."
			return 1
		fi
	fi

	#
	# Overwrite key
	#
	if ! config_set_key "${_CONFIG_DEFAULT_USER_FILE}" "$1" "$2"; then
		prn_err "Failed set key($1) to default configuration file(${_CONFIG_DEFAULT_USER_FILE})."
		return 1
	fi
	return 0
}

#
# Unset value for key in configration file(without backup)
#
# $1		: file path
# $2		: key name
# $?		: result(0/1)
#
config_unset_key()
{
	if [ $# -lt 2 ]; then
		prn_dbg "(config_unset_key) Insufficient input parameters($#)"
		return 1
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_unset_key) Configuration file path is empty."
		return 1
	fi
	if [ -z "$2" ]; then
		prn_dbg "(config_unset_key) Key name is empty."
		return 1
	fi
	if [ ! -f "$1" ]; then
		prn_dbg "(config_unset_key) Configuration file($1) is not existed, so nothing to remove."
		return 1
	fi

	#
	# Remove variable name from K2HR3CLI_UPDATED_CONFIG_VARS
	#
	# [NOTE]
	# The variable will be updated, so if the variable name exists in 
	# K2HR3CLI_UPDATED_CONFIG_VARS, delete it.
	#
	delete_config_update_var "$2"

	#
	# Loop for removing excessive keys with the same name
	#
	_CONFIG_UNSET_KEY_LOOP=1
	while [ "${_CONFIG_UNSET_KEY_LOOP}" -eq 1 ]; do
		_CONFIG_UNSET_FOUND_CNT=$(grep -c "^[[:space:]]*$2[[:space:]]*=" "$1")
		if [ "${_CONFIG_UNSET_FOUND_CNT}" -le 1 ]; then
			break
		fi
		if ! _CONFIG_UNSET_FOUND=$(grep -n "^[[:space:]]*$2[[:space:]]*=" "$1" | head -1 2>/dev/null); then
			break
		fi
		_CONFIG_UNSET_FOUND_LINENO=$(echo "${_CONFIG_UNSET_FOUND}" | awk 'END{print $NF}' | sed "s/:/ /g" | awk '{print $1}')

		#
		# remove line
		#
		if ! sed -i -e "${_CONFIG_UNSET_FOUND_LINENO}d" "$1" >/dev/null 2>&1; then
			prn_dbg "(config_unset_key) Failed remove key($2) in configuration file($1): line number(${_CONFIG_UNSET_FOUND_LINENO})"
			return 1
		fi
	done

	#
	# Unset key
	#
	if config_search_key "$1" "$2" >/dev/null; then
		#
		# Not found key in configuration file -> loop end
		#
		prn_dbg "(config_unset_key) Not found unset key($2) in configuration file($1)."
		return 0
	fi
	if ! config_modify_key "$1" "$2" "" 0; then
		prn_dbg "(config_unset_key) Failed to unset key($2) in configuration file($1)."
		return 1
	fi

	return 0
}

#
# Remove key in configration file(without backup)
#
# $1		: file path
# $2		: key name
# $?		: result(0/1)
#
config_remove_key()
{
	if [ $# -lt 2 ]; then
		prn_dbg "(config_remove_key) Insufficient input parameters($#)"
		return 1
	fi
	if [ -z "$1" ]; then
		prn_dbg "(config_remove_key) Configuration file path is empty."
		return 1
	fi
	if [ -z "$2" ]; then
		prn_dbg "(config_remove_key) Key name is empty."
		return 1
	fi
	if [ ! -f "$1" ]; then
		prn_dbg "(config_remove_key) Configuration file($1) is not existed, so nothing to remove."
		return 1
	fi

	#
	# Remove variable name from K2HR3CLI_UPDATED_CONFIG_VARS
	#
	# [NOTE]
	# The variable will be updated, so if the variable name exists in 
	# K2HR3CLI_UPDATED_CONFIG_VARS, delete it.
	#
	delete_config_update_var "$2"

	#
	# Loop for all key
	#
	_CONFIG_REMOVE_KEY_LOOP=1
	while [ "${_CONFIG_REMOVE_KEY_LOOP}" -eq 1 ]; do
		if config_search_key "$1" "$2" >/dev/null; then
			#
			# Not found key in configuration file -> loop end
			#
			break
		fi
		#
		# Remove lastest key line
		#
		if ! config_modify_key "$1" "$2" "" 1; then
			return 1
		fi
	done

	return 0
}

#
# Add configuration variables
#
# $1		: Variable name
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_UPDATED_CONFIG_VARS
#
add_config_update_var()
{
	if [ -z "$1" ]; then
		return 1
	fi
	if [ -z "${K2HR3CLI_UPDATED_CONFIG_VARS}" ]; then
		K2HR3CLI_UPDATED_CONFIG_VARS="$1"
	else
		for _UPDATED_CONFIG_ONE_VAR in ${K2HR3CLI_UPDATED_CONFIG_VARS}; do
			if [ -n "${_UPDATED_CONFIG_ONE_VAR}" ] && [ "${_UPDATED_CONFIG_ONE_VAR}" = "$1" ]; then
				#
				# Already set variable name
				#
				return 0
			fi
		done
		K2HR3CLI_UPDATED_CONFIG_VARS="${K2HR3CLI_UPDATED_CONFIG_VARS} $1"
	fi
	return 0
}

#
# Delete configuration variables
#
# $1		: Variable name
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_UPDATED_CONFIG_VARS
#
delete_config_update_var()
{
	if [ -z "$1" ]; then
		return 1
	fi
	if [ -z "${K2HR3CLI_UPDATED_CONFIG_VARS}" ]; then
		return 0
	fi
	_UPDATED_CONFIG_NEW_VARS=""
	for _UPDATED_CONFIG_ONE_VAR in ${K2HR3CLI_UPDATED_CONFIG_VARS}; do
		if [ -z "${_UPDATED_CONFIG_ONE_VAR}" ] || [ "${_UPDATED_CONFIG_ONE_VAR}" != "$1" ]; then
			if [ -n "${_UPDATED_CONFIG_NEW_VARS}" ]; then
				_UPDATED_CONFIG_NEW_VARS="${_UPDATED_CONFIG_NEW_VARS} ${_UPDATED_CONFIG_ONE_VAR}"
			else
				_UPDATED_CONFIG_NEW_VARS="${_UPDATED_CONFIG_ONE_VAR}"
			fi
		fi
	done

	K2HR3CLI_UPDATED_CONFIG_VARS="${_UPDATED_CONFIG_NEW_VARS}"
	return 0
}

#
# Update configuration variables
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_UPDATED_CONFIG_VARS
#
update_config_vars()
{
	if [ -z "${K2HR3CLI_OPT_SAVE}" ]; then
		return 0
	fi
	if [ -z "${K2HR3CLI_OPT_SAVE}" ] || [ "${K2HR3CLI_OPT_SAVE}" != "1" ]; then
		return 0
	fi
	if [ -z "${K2HR3CLI_UPDATED_CONFIG_VARS}" ]; then
		return 0
	fi

	for _UPDATED_CONFIG_ONE_VAR in ${K2HR3CLI_UPDATED_CONFIG_VARS}; do
		_UPDATED_CONFIG_ONE_VAR_VAL=$(eval pecho -n '$'"${_UPDATED_CONFIG_ONE_VAR}")

		if [ -n "${_CONFIG_SET_CONFIG_FILE}" ]; then
			config_set_key "${_CONFIG_SET_CONFIG_FILE}" "${_UPDATED_CONFIG_ONE_VAR}" "${_UPDATED_CONFIG_ONE_VAR_VAL}"
		else
			config_default_set_key "${_UPDATED_CONFIG_ONE_VAR}" "${_UPDATED_CONFIG_ONE_VAR_VAL}"
		fi
	done
	K2HR3CLI_UPDATED_CONFIG_VARS=""

	return 0
}

#---------------------------------------------------------------------
# Main
#---------------------------------------------------------------------
#
# Load global configuration file
#
if [ -f "${K2HR3CLI_GLOBAL_CONFIG}" ]; then
	if ! check_backquote_in_file "${K2HR3CLI_GLOBAL_CONFIG}"; then
		prn_warn "${K2HR3CLI_GLOBAL_CONFIG} configuration file has back quote for shell executable charactor, then skip it loading."
	else
		prn_info "Loaded ${K2HR3CLI_GLOBAL_CONFIG} configuration file."
		. "${K2HR3CLI_GLOBAL_CONFIG}"
	fi
fi

#
# Load configuration file with priority
#
if [ -n "${K2HR3CLI_OPT_CONFIG}" ]; then
	#
	# Custom configuration file
	#
	if [ ! -f "${K2HR3CLI_OPT_CONFIG}" ]; then
		prn_warn "${K2HR3CLI_OPT_CONFIG} configuration file is specified, but the file is not found."
	else
		if ! check_backquote_in_file "${K2HR3CLI_OPT_CONFIG}"; then
			prn_warn "${K2HR3CLI_OPT_CONFIG} configuration file has back quote for shell executable charactor, then skip it loading."
		else
			prn_dbg "Loaded ${K2HR3CLI_OPT_CONFIG} configuration file."
			. "${K2HR3CLI_OPT_CONFIG}"
		fi
	fi
elif [ -n "${K2HR3CLI_CUSTOM_CONFIG}" ]; then
	#
	# Custom configuration file
	#
	if [ ! -f "${K2HR3CLI_CUSTOM_CONFIG}" ]; then
		prn_warn "${K2HR3CLI_CUSTOM_CONFIG} configuration file is specified, but the file is not found."
	else
		if ! check_backquote_in_file "${K2HR3CLI_CUSTOM_CONFIG}"; then
			prn_warn "${K2HR3CLI_CUSTOM_CONFIG} configuration file has back quote for shell executable charactor, then skip it loading."
		else
			prn_info "Loaded ${K2HR3CLI_CUSTOM_CONFIG} configuration file."
			. "${K2HR3CLI_CUSTOM_CONFIG}"
		fi
	fi
	#
	# restore environments
	#
else
	#
	# Check and load user configuration file
	#
	if _CONFIG_DEFAULT_USER_FILE=$(config_get_default_user_path); then
		if [ -f "${_CONFIG_DEFAULT_USER_FILE}" ]; then
			if ! check_backquote_in_file "${_CONFIG_DEFAULT_USER_FILE}"; then
				prn_warn "${_CONFIG_DEFAULT_USER_FILE} configuration file has back quote for shell executable charactor, then skip it loading."
			else
				prn_info "Loaded ${_CONFIG_DEFAULT_USER_FILE} configuration file."
				. "${_CONFIG_DEFAULT_USER_FILE}"
			fi
		fi
	fi
	#
	# restore environments
	#
fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
