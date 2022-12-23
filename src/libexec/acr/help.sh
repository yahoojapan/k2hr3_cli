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
echo "K2HR3 CLI command for the ACR API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_acr.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on ACR(ACCESS CROSS"
echo "ROLE) in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"add\", \"show\" and \"delete\" subcommands."
echo ""
echo "OPERATE: Add/Show/Delete member TENANT for ACR"
echo "    This command is used to add/show/delete the member TENANT"
echo "    for the ACR."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} [add|show|delete] <option...>"
echo ""
echo "    Add member TENANT:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} add <service|yrn path>"
echo ""
echo "    Delete member TENANT:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} delete <service|yrn path>"
echo ""
echo "    Show member TENANT information:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show tenant <service|yrn path>"
echo ""
echo "    Show member TENANT resource:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show resource <service|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_CIP_LONG} <client IP address>"
echo "            ${K2HR3CLI_COMMAND_OPT_CPORT_LONG} <client port>"
echo "            ${K2HR3CLI_COMMAND_OPT_CROLE_LONG} <client role>"
echo "            ${K2HR3CLI_COMMAND_OPT_CCUK_LONG} <client CUK>"
echo "            ${K2HR3CLI_COMMAND_OPT_SPORT_LONG} <service port>"
echo "            ${K2HR3CLI_COMMAND_OPT_SROLE_LONG} <service role>"
echo "            ${K2HR3CLI_COMMAND_OPT_SCUK_LONG} <service CUK>"
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_CIP_LONG}"
echo "         An IP address, which is owned by a service member and"
echo "         the other end IP address of the service owner(a peer IP)."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_CPORT_LONG}"
echo "         An port number, which is used to determine the K2HR3"
echo "         ROLE name of the IP address."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_CROLE_LONG}"
echo "         A K2HR3 ROLE name. If a service member host is a"
echo "         member of multiple K2HR3 ROLE, the service member"
echo "         should pass the K2HR3 ROLE name it want to be"
echo "         authorized."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_CCUK_LONG}"
echo "         This parameter is reserved for future use. Setting this"
echo "         currently has no effect."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_SPORT_LONG}"
echo "         A port number of the service owner host. The IP"
echo "         address of the service owner host is not required."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_SROLE_LONG}"
echo "         A role name assigned to service owner host"
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_SCUK_LONG}"
echo "         This parameter is reserved for future use."
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
echo "        ${K2HR3CLI_COMMAND_OPT_OIDC_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_OIDC_TOKEN_SHORT}) <OIDC token>"
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
