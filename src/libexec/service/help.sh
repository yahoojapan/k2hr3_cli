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
echo "K2HR3 CLI command for the SERVICE API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_service.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on policy in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"create\", \"show\" and \"delete\" subcommands."
echo ""
echo "OPERATE SERVICE DATA: Create(set)/Show/Delete SERVICE"
echo "    This command is used to create the SERVICE of K2HR3."
echo "    Create, Update, display details, and delete SERVICE data."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} [create|show|delete] <option...>"
echo ""
echo "    Create SERVICE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_VERIFY_LONG} <verify url>"
echo ""
echo "    Show SERVICE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show <name|yrn path>"
echo ""
echo "    Delete SERVICE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} delete <name|yrn path>"
echo ""
echo "OPERATE TENANT MEMBER: Add/Delete/Check TENANT member"
echo "    This command is used to add/delete/clear/check the TENANT"
echo "    member SERVICE in ROLE member."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} tenant [add|delete|check] <option...>"
echo ""
echo "    Add TENANT member:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} tenant add <name|yrn path> <tenant> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_CLEAR_TENANT_LONG}"
echo ""
echo "    Delete TENANT member(from owner service member list):"
echo "        ${BINNAME} ${K2HR3CLI_MODE} tenant delete <name|yrn path> <tenant> <option...>"
echo ""
echo "    Check TENANT member:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} tenant check <name|yrn path> <tenant> <option...>"
echo ""
echo "OPERATE VERIFY URL: Update VERIFY URL"
echo "    This command is used to update the VERIFY URL."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} verify update"
echo ""
echo "    Update VERIFY URL:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} verify update <name|yrn path> <verify url>"
echo ""
echo "OPERATE TENANT MEMBER SERVICE: Clear service in TENANT member"
echo "    This command is used to clear the TENANT member's service."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} member clear <option...>"
echo ""
echo "    Clear TENANT member's service:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} member clear <service name> <member tenant> <option...>"
echo ""
echo "        *) Please specify the Scoped Token of the TENANT member."
echo "           (Other commands are operated with the ScopedToken of"
echo "           the Serivce owner, but this command is operated with"
echo "           the ScopedToken of the TENANT member.)"
echo "        *) Service settings(ROLE, RESOURCE, and POLICY) on the"
echo "           SERVICE member side are made using the acr command"
echo "           (ACR API)."
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_VERIFY_LONG}"
echo "        A url to define a dynamic resource or a string literal"
echo "        or a boolean literal."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_CLEAR_TENANT_LONG}"
echo "        Specify when deleting a tenant from a service member."
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
