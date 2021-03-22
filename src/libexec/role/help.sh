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
echo "K2HR3 CLI command for the ROLE API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_role.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on role in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"create\", \"show\", \"delete\", \"host\" and \"token\""
echo "subcommands."
echo ""
echo "OPERATE ROLE DATA: Create(set)/Show/Delete ROLE data"
echo "    This command is used to operate the ROLE data of K2HR3."
echo "    Create(set), display details, and delete ROLE data."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} [create|show|delete] <option...>"
echo ""
echo "    Create(set) ROLE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_POLICIES_LONG} <policy path>"
echo "            ${K2HR3CLI_COMMAND_OPT_ALIAS_LONG} <role path>"
echo ""
echo "    Show ROLE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}"
echo ""
echo "    Delete ROLE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} delete <name|yrn path>"
echo ""
echo "OPERATE HOST DATA: Add/Delete HOST as ROLE member"
echo "    This command is used to add/delete the HOST in ROLE member."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} host [add|delete] <option...>"
echo ""
echo "    Add HOST:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} host add <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_HOST_LONG} <hostname or ip address>"
echo "            ${K2HR3CLI_COMMAND_OPT_PORT_LONG} <port number>"
echo "            ${K2HR3CLI_COMMAND_OPT_CUK_LONG} <custom unique key>"
echo "            ${K2HR3CLI_COMMAND_OPT_EXTRA_LONG} <extra information>"
echo "            ${K2HR3CLI_COMMAND_OPT_TAG_LONG} <tag name>"
echo ""
echo "    Delete HOST:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} host delete <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_HOST_LONG} <hostname or ip address>"
echo "            ${K2HR3CLI_COMMAND_OPT_PORT_LONG} <port number>"
echo "            ${K2HR3CLI_COMMAND_OPT_CUK_LONG} <custom unique key>"
echo ""
echo "OPERATE ROLE TOKEN: Create/Show/Delete/Check ROLE TOKEN"
echo "    This command is used to create/show/delete/check ROLE TOKEN."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} token [create|show|delete|check] <option...>"
echo ""
echo "    Create ROLE TOKEN:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} token create <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_EXPIRE_LONG}"
echo ""
echo "    Show ROLE TOKEN list:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} token show <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}"
echo ""
echo "    Delete ROLE TOKEN:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} token delete <role token>"
echo ""
echo "    Check ROLE TOKEN:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} token check <name|yrn path> <role token>"
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_POLICIES_LONG}"
echo "        Specifies the POLICY YRN path to set as ROLE data."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_ALIAS_LONG}"
echo "        Specifies the Alias to other ROLE YRN path to set as ROLE data."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_HOST_LONG}"
echo "        Specifies the hostname or IP address."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_PORT_LONG}"
echo "        Specifies the port number for HOST."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_CUK_LONG}"
echo "        Specifies the CUK data for HOST."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_EXTRA_LONG}"
echo "        Specifies the Extra data for HOST."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_TAG_LONG}"
echo "        Specifies the TAG name for HOST."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_EXPIRE_LONG}"
echo "        Specify the expiration date (seconds) of ROLE TOKEN."
echo "        You can specify 0 to specify the maximum expiration date."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}"
echo "        Expand the alias set in ROLE."
echo ""
echo "    Options other than the above"
echo "        The Token command uses the following options."
echo "        You can get help with run \"${BINNAME} --help(-h)\" to find"
echo "        out more about these options."
echo ""
echo "        ${K2HR3CLI_COMMAND_OPT_USER_LONG}(${K2HR3CLI_COMMAND_OPT_USER_SHORT}) <user name>"
echo "        ${K2HR3CLI_COMMAND_OPT_PASS_LONG}(${K2HR3CLI_COMMAND_OPT_PASS_SHORT}) <passphrase>"
echo "        ${K2HR3CLI_COMMAND_OPT_TENANT_LONG}(${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}) <tenant>"
echo "        ${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}) <unscoped token>"
echo "        ${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_SHORT}) <scoped token>"
echo "        ${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT}) <openstack token>"
echo "        ${K2HR3CLI_COMMON_OPT_SAVE_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_SHORT})"
echo "        ${K2HR3CLI_COMMON_OPT_SAVE_PASS_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_PASS_SHORT})"
echo "        ${K2HR3CLI_COMMON_OPT_MSGLEVEL_LONG}(${K2HR3CLI_COMMON_OPT_MSGLEVEL_SHORT})"
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
