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
echo "K2HR3 CLI command for the POLICY API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_policy.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on policy in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"create\", \"show\" and \"delete\" subcommands."
echo ""
echo "OPERATE: Create(set)/Show/Delete POLICY data"
echo "    This command is used to create the POLICY data of K2HR3."
echo "    Create(set), display details, and delete POLICY data."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} [create|show|delete] <option...>"
echo ""
echo "    Create(set) POLICY:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_EFFECT_LONG} <effect type>"
echo "            ${K2HR3CLI_COMMAND_OPT_ACTION_LONG} <action type>"
echo "            ${K2HR3CLI_COMMAND_OPT_RESOURCE_LONG} <resource yrn path>"
echo "            ${K2HR3CLI_COMMAND_OPT_ALIAS_LONG} <policy yrn path>"
echo ""
echo "    Show POLICY:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_SERVICE_LONG} <service name>"
echo ""
echo "    Delete POLICY:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} delete <name|yrn path>"
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_EFFECT_LONG}"
echo "        A EFFECT type that resource members are allowed"
echo "        (or denied) to use the policy. A valid value is \"allow\""
echo "        or \"deny\". Default is \"deny\"."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_ACTION_LONG}"
echo "        An ACTION type or ACTION types that how resource members"
echo "        are allowed to use the resource. A valid value is"
echo "        \"yrn:yahoo::::action:read\" or \"yrn:yahoo::::action:write\""
echo "        or both. A string literal if a single value. A valid"
echo "        value is \"read\" or \"write\"."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_RESOURCE_LONG}"
echo "        A resource name in YRN form. Undefined(including empty"
echo "        value) will be interpreted as null."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_ALIAS_LONG}"
echo "        A policy name aliased to in YRN form. Undefined("
echo "        including empty value) will be interpreted as null."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_SERVICE_LONG}"
echo "        A service name."
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
