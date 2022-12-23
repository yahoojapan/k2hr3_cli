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

#---------------------------------------------------------------------
# Put Help
#---------------------------------------------------------------------
# [NOTE]
# Adjust the start and end positions of the characters according to the
# scale below, and arrange the lines.
#
#     +-- start position(ex. title)
#     |   +-- indent for description
#     |   |
#     v   v
#     +---+----+----+----+----+----+----+----+----+----+----+----+----|
#
echo ""
echo "K2HR3 CLI command for the Manipulating the Configuration file."
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on tokens in the K2HR3 system."
echo "${K2HR3CLI_MODE} is a command that manipulates(\"show\", \"set\" and \"clear\")"
echo "the K2HR3 CLI configuration file."
echo ""
echo "SHOW: Show the variables"
echo "    Show the variables in the K2HR3 CLI Configuration file."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} show <option...>"
echo ""
echo "    Show all variable names and details:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show"
echo "            ${K2HR3CLI_COMMON_OPT_CONFIG_LONG}(${K2HR3CLI_COMMON_OPT_CONFIG_SHORT}) <file>"
echo ""
echo "    Show all variables:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show all"
echo "            ${K2HR3CLI_COMMON_OPT_CONFIG_LONG}(${K2HR3CLI_COMMON_OPT_CONFIG_SHORT}) <file>"
echo ""
echo "    Show a variable:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show <variable name>"
echo "            ${K2HR3CLI_COMMON_OPT_CONFIG_LONG}(${K2HR3CLI_COMMON_OPT_CONFIG_SHORT}) <file>"
echo ""
echo "SET: Set the variables:"
echo "    Set the variables in the K2HR3 CLI Configuration file."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} set <option...>"
echo ""
echo "    Set a variable and its value:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} set <variable name> <value>"
echo "            ${K2HR3CLI_COMMON_OPT_CONFIG_LONG}(${K2HR3CLI_COMMON_OPT_CONFIG_SHORT}) <file>"
echo ""
echo "CLEAR: Clear the variables:"
echo "    Clear the variables in the K2HR3 CLI Configuration file."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} clear <option...>"
echo ""
echo "    Clear a variable and its value:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} clear <variable name>"
echo "            ${K2HR3CLI_COMMON_OPT_CONFIG_LONG}(${K2HR3CLI_COMMON_OPT_CONFIG_SHORT}) <file>"
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    Options other than the above"
echo "        The Token command uses the following options."
echo "        You can get help with run \"${BINNAME} --help(-h)\" to find"
echo "        out more about these options."
echo ""
echo "        ${K2HR3CLI_COMMON_OPT_CONFIG_LONG}(${K2HR3CLI_COMMON_OPT_CONFIG_SHORT}) <file>"
echo ""
echo "        You can pass values in environment variables equivalent"
echo "        to them without the options mentioned above."
echo "        And you can also define variables in the configuration"
echo "        file instead of environment variables."
echo ""

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
