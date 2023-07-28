#
# K2HR3 Utilities - Command Line Interface
#
# Copyright 2023 Yahoo Japan Corporation.
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
# CREATE:   Thu Jul 27 2023
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
echo "K2HR3 CLI command for the TENANT API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_tenant.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on tenant in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"create\", \"update\", \"show\" and \"delete\""
echo "subcommands."
echo ""
echo "OPERATE: Create/Update/Show/Delete LOCAL TENANT"
echo "    This command is used to create the LOCAL TENANT of K2HR3."
echo "    Create(set), display details, and delete LOCAL TENANT."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} [create|update|show|delete] <option...>"
echo ""
echo "    Create TENANT:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create <name> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_DISPLAY_LONG} <display name>"
echo "            ${K2HR3CLI_COMMAND_OPT_DESCRIPTION_LONG} <description>"
echo "            ${K2HR3CLI_COMMAND_OPT_USERS_LONG} <user,user,...>"
echo ""
echo "    Update TENANT:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} update <name> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_TENANTID_LONG} <tenant id>"
echo "            ${K2HR3CLI_COMMAND_OPT_DISPLAY_LONG} <display name>"
echo "            ${K2HR3CLI_COMMAND_OPT_DESCRIPTION_LONG} <description>"
echo "            ${K2HR3CLI_COMMAND_OPT_USERS_LONG} <user,user,...>"
echo ""
echo "    Show TENANT:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show { <name> | <option...> }"
echo "            ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}"
echo ""
echo "    Delete TENANT:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} delete <name> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_TENANTID_LONG} <tenant id>"
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_TENANTID_LONG}"
echo "        Specify the ID of the K2HR3 Local Tenant(TENANT)."
echo "        If the K2HR3 Local Tenant(TENANT) name and this ID value do not"
echo "        match, it will be failure."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_DISPLAY_LONG}"
echo "        Specify the display name for the K2HR3 Local Tenant(TENANT) in"
echo "        the K2HR3 Web Application."
echo "        This value can be omitted, and if omitted, the TENANT name is"
echo "        set."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_DESCRIPTION_LONG}"
echo "        Specify a description of the K2HR3 Local Tenant(TENANT)."
echo "        This value is optional and defaults to the descriptive text if"
echo "        omitted."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_USERS_LONG}"
echo "        Specify the USER names who can use the K2HR3 Local Tenant(TENANT)"
echo "        as an array.(ex, '[\"user1\",\"user2\"]')"
echo "        Only create mode, the USER name indicated by the Unscoped/Scoped"
echo "        User Token sending this request cab be omit."
echo "        It is necessary to specify the USER name registered in the K2HR3"
echo "        system, and if the USER is not existed, it is ignored."
echo "        And the USER name can not set as YRN full path."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}"
echo "        Expand the tenant information."
echo ""
echo "    Options other than the above"
echo "        This command requires a K2HR3 Unscoped(os Scoped) Token."
echo "        The Token command uses the following options."
echo "        You can get help with run \"${BINNAME} --help(-h)\" to find"
echo "        out more about these options."
echo ""
echo "        ${K2HR3CLI_COMMAND_OPT_USER_LONG}(${K2HR3CLI_COMMAND_OPT_USER_SHORT}) <user name>"
echo "        ${K2HR3CLI_COMMAND_OPT_PASS_LONG}(${K2HR3CLI_COMMAND_OPT_PASS_SHORT}) <passphrase>"
echo "        ${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}) <unscoped token>"
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
