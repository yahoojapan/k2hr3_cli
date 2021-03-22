#
# K2HR3 CLI PLUGIN - Example
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

#
# [NOTE]
# If your plugin reads or writes variables to its own Configuration
# file, prepare this file.
# Register the function name you defined in the variables shown below.
# This registered function is called when ${BINNAME} manipulates
# the Configuration file.
# Please refer to the sample below.
#

#--------------------------------------------------------------
# Variables for Configration
#--------------------------------------------------------------
# The value of "K2HR3CLI_PLUGIN_CONFIG_VAR_DESC" is the value
# used by the K2HR3 CLI itself.
# Add this variable value for the function name which returns
# the variable name and its description.
# You can see follow example for this function.
# If the PLUGIN has a variable/value to store in the configuration
# file, enumerate the "function name" in this environment.
# If the value of "K2HR3CLI_PLUGIN_CONFIG_VAR_DESC" has already
# been set, add the value here.
#
if [ "X${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC}" != "X" ]; then
	K2HR3CLI_PLUGIN_CONFIG_VAR_DESC="${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC} config_var_desciption_example"
else
	K2HR3CLI_PLUGIN_CONFIG_VAR_DESC="config_var_desciption_example"
fi

# The value of "K2HR3CLI_PLUGIN_CONFIG_VAR_NAME" is the value
# used by the K2HR3 CLI itself.
# Add this variable value for the function name which returns
# the variable name.
# You can see follow example for this function.
# If the value of "K2HR3CLI_PLUGIN_CONFIG_VAR_NAME" has already
# been set, add the value here.
#
if [ "X${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME}" != "X" ]; then
	K2HR3CLI_PLUGIN_CONFIG_VAR_NAME="${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME} config_var_name_example"
else
	K2HR3CLI_PLUGIN_CONFIG_VAR_NAME="config_var_name_example"
fi

# The value of "K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR" is the value
# used by the K2HR3 CLI itself.
# Add this variable value for the function name which checks
# the variable name for self.
# You can see follow example for this function.
# If the value of "K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR" has already
# been set, add the value here.
#
if [ "X${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR}" != "X" ]; then
	K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR="${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR} config_check_var_name_example"
else
	K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR="config_check_var_name_example"
fi

#--------------------------------------------------------------
# Functions
#--------------------------------------------------------------
#
# Return variable description for this Example Plugin
#
# $?	: result
#
# [NOTE]
#           +---+----+----+----+----+----+----+----+----+----+----+----+----|
#           ^   ^
#           |   +--- Start for Description
#           +------- Start for Variables Title
#
config_var_desciption_example()
{
	prn_msg "K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE"
	prn_msg "   Example variable for K2HR3 CLI PLUGIN."
	prn_msg ""
}

#
# Return variable name
#
# $1		: variable name(if empty, it means all)
# $?		: result
# Output	: variable names(with separator is space)
#
config_var_name_example()
{
	if [ "X$1" = "X" ]; then
		if [ "X${K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE}" != "X" ]; then
			prn_msg "K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE: \"${K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE}\""
		else
			prn_msg "K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE: (empty)"
		fi
		return 0

	elif [ "X$1" = "XK2HR3CLI_PLUGIN_VARIABLE_EXAMPLE" ]; then
		if [ "X${K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE}" != "X" ]; then
			prn_msg "K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE: \"${K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE}\""
		else
			prn_msg "K2HR3CLI_PLUGIN_VARIABLE_EXAMPLE: (empty)"
		fi
		return 0

	fi
	return 1
}

#
# Check variable name
#
# $1		: variable name
# $?		: result
#
config_check_var_name_example()
{
	if [ "X$1" = "XK2HR3CLI_PLUGIN_VARIABLE_EXAMPLE" ]; then
		return 0
	fi
	return 1
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
