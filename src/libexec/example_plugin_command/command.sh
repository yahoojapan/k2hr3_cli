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
# ${BINNAME} loads this file as the main process of the plugin.
# Describe the main processing of the plug-in in this file.
# In this file, you can call COMMON functions used by ${BINNAME},
# and you can freely access variables.
#

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
# This file will be loaded directly into the ${BINNAME} program.
# And "$@" is loaded with the parameters at program startup.
# However. Options parsed by ${BINNAME} have been removed.
# The options parsed by ${BINNAME} are set to
# "K2HR3CLI_COMMON_OPT_XXXX" or "K2HR3CLI_COMMAND_OPT_XXXX".
# If you want to parse the options yourself, parse "$@" yourself.
#
# The "K2HR3CLI_SUBCOMMAND" variable contains this directory
# name, the command name.

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
prn_msg "This is a sample command for creating a $ {BINNAME} subcommand as a plugin."

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
