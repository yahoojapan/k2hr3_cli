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
echo "K2HR3 CLI command for the RESOURCE API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_resource.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on resoure in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"create\", \"show\" and \"delete\" subcommands."
echo ""
echo "OPERATE: Create(set)/Show/Delete RESOURCE data"
echo "    This command is used to create the RESOURCE data of K2HR3."
echo "    Create(update), display details, and delete RESOURCE data."
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} [create|show|delete] <option...>"
echo ""
echo "    Create(Update) RESOURCE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} create <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_TYPE_LONG} <type>"
echo "            ${K2HR3CLI_COMMAND_OPT_DATA_LONG} <data>"
echo "            ${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG} <filepath>"
echo "            ${K2HR3CLI_COMMAND_OPT_KEYS_LONG} <key pair>"
echo "            ${K2HR3CLI_COMMAND_OPT_ALIAS_LONG} <role path>"
echo ""
echo "            *) ${K2HR3CLI_COMMAND_OPT_DATA_LONG} and ${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG} cannot be specified at the"
echo "               same time."
echo ""
echo "    Show RESOURCE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} show <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}"
echo "            ${K2HR3CLI_COMMAND_OPT_SERVICE_LONG} <service name>"
echo ""
echo "    Delete RESOURCE:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} delete <name|yrn path> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_TYPE_LONG} <type>"
echo "            ${K2HR3CLI_COMMAND_OPT_KEYNAMES_LONG} <key names>"
echo "            ${K2HR3CLI_COMMAND_OPT_ALIASES_LONG} <aliases>"
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_TYPE_LONG}"
echo "        For the Create subcommand, a resource type of the"
echo "        resource. A valid value is \"string\", \"object\", \"null\""
echo "        or \"undefined\"."
echo "        For the Delete subcommand, a resource type of the"
echo "        resource. A valid value is \"anytype\", \"string\","
echo "        \"object\", \"keys\", \"aliases\", null or undefined."
echo "        \"anytype\" will be will be interpreted as the \"type\" of"
echo "        the RESOURCE. Undefined and null will be will be"
echo "        interpreted as everything, which means delete all of the"
echo "        RESOURCE."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_DATA_LONG}"
echo "        A data of the resource. If the resource type is"
echo "        \"string\", data must be a string literal. If the"
echo "        resource type is \"object\", data must be a JSON object."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG}"
echo "        A file of the resource which type is \"string\"."
echo "        If the data contains non-escaped characters such as"
echo "        line breaks, you can specify it in the file."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_KEYS_LONG}"
echo "        A pair of a key and a value of the resource."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_ALIAS_LONG}"
echo "        An alias of the resource."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_SERVICE_LONG}"
echo "        A service name."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_KEYNAMES_LONG}"
echo "        A key name. You must also specify the \"type\" url"
echo "        argument with \"keys\". The value can be a string literal"
echo "        of an JSON array object."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_ALIASES_LONG}"
echo "        alias names. You must also specify the \"type\" url"
echo "        argument with \"aliases\". The value can be an array of"
echo "        aliases or comma separated string if multiple aliases."
echo "        The value can be a string if the alias is a single value."
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
