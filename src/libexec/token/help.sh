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
echo "K2HR3 CLI command for the TOKEN API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_token.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on tokens in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"create\", \"show\"and \"check\""
echo "subcommands."
echo ""
echo "CREATE: Create Unscoped Token and Scoped Token"
echo "    This command gets the Unscoped and Scoped Token for K2HR3."
echo "    The method of creating Unscoped and Scoped Token has the"
echo "    following format, and the kind of Token that can be acquired"
echo "    differs depending on the option."
echo ""
echo "    Specify the ${K2HR3CLI_COMMON_OPT_SAVE_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_SHORT}) and ${K2HR3CLI_COMMON_OPT_MSGLEVEL_LONG}(${K2HR3CLI_COMMON_OPT_MSGLEVEL_SHORT})"
echo "    option, the generated (Un)Scoped Token is saved in the"
echo "    configuration file."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} create [type] <option...>"
echo ""
echo "    Unscoped Token From Credential:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create utoken_cred"
echo "            ${K2HR3CLI_COMMAND_OPT_USER_LONG}(${K2HR3CLI_COMMAND_OPT_USER_SHORT}) <user name>"
echo "            ${K2HR3CLI_COMMAND_OPT_PASS_LONG}(${K2HR3CLI_COMMAND_OPT_PASS_SHORT}) <passphrase>"
echo ""
echo "    Unscoped Token From OpenStack Token:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create utoken_optoken"
echo "            ${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT}) <openstack token>"
echo ""
echo "    Scoped Token From Credential:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create token_cred"
echo "            ${K2HR3CLI_COMMAND_OPT_USER_LONG}(${K2HR3CLI_COMMAND_OPT_USER_SHORT}) <user name>"
echo "            ${K2HR3CLI_COMMAND_OPT_PASS_LONG}(${K2HR3CLI_COMMAND_OPT_PASS_SHORT}) <passphrase>"
echo "            ${K2HR3CLI_COMMAND_OPT_TENANT_LONG}(${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}) <tenant>"
echo ""
echo "    Scoped Token From Unscoped Token:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create token_utoken"
echo "            ${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}) <unscoped token>"
echo "            ${K2HR3CLI_COMMAND_OPT_TENANT_LONG}(${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}) <tenant>"
echo ""
echo "    Scoped Token From OpenStack Token:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create token_optoken"
echo "            ${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT}) <openstack token>"
echo "            ${K2HR3CLI_COMMAND_OPT_TENANT_LONG}(${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}) <tenant>"
echo ""
echo "SHOW: Show list the available tenants"
echo "    Show List the tenants available for each user in the K2HR3"
echo "    system. A Token is required to use this subcommand."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} show [type] <option...>"
echo ""
echo "    Show Tenant List From Unscoped Totken:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show utoken"
echo "            ${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}) <unscoped token>"
echo ""
echo "    Show Tenant List From Scoped Totken:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show token"
echo "            ${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_SHORT}) <scoped token>"
echo ""
echo ""
echo "CHECK: Validity and Expiration date of K2HR3 (Un)Scoped Token"
echo "    Specify Unscoped Token or Scoped Token to check its"
echo "    validation and expiration date."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} check <option...>"
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
echo "        ${K2HR3CLI_COMMAND_OPT_USER_LONG}(${K2HR3CLI_COMMAND_OPT_USER_SHORT}) <user name>"
echo "        ${K2HR3CLI_COMMAND_OPT_PASS_LONG}(${K2HR3CLI_COMMAND_OPT_PASS_SHORT}) <passphrase>"
echo "        ${K2HR3CLI_COMMAND_OPT_TENANT_LONG}(${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}) <tenant>"
echo "        ${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}) <unscoped token>"
echo "        ${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_SHORT}) <scoped token>"
echo "        ${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT}) <openstack token>"
echo "        ${K2HR3CLI_COMMON_OPT_SAVE_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_SHORT})"
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
