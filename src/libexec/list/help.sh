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
echo "K2HR3 CLI command for the LIST API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_list.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on tokens in the K2HR3 system."
echo "${K2HR3CLI_MODE} has the \"create\", \"show\"and \"check\""
echo "subcommands."
echo ""
echo "List available K2HR3 SERVICEs, RESOURCEs, ROLEs and POLICIess."
echo ""
echo "    Specify the ${K2HR3CLI_COMMAND_OPT_SERVICE_LONG}(${K2HR3CLI_COMMAND_OPT_SERVICE_SHORT}) for service name"
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} [type] <option...>"
echo ""
echo "    List SERVICEs:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} service <service name>"
echo ""
echo "    List RESOURCEs:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} ressource <yrn path> [<service name>]"
echo "            For the list of RESOURCEs under the SERVICE, specify"
echo "            <service name>."
echo ""
echo "    List ROLEs:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} role <yrn path> [<service name>]"
echo "            For the list of ROLEs under the SERVICE, specify"
echo "            <service name>."
echo ""
echo "    List POLICIes:"
echo "        ${BINNAME} ${K2HR3CLI_MODE} policy <yrn path> [<service name>]"
echo "            For the list of POLICIes under the SERVICE, specify"
echo "            <service name>."
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}"
echo "        Returns the data of the child element of the response data."
echo ""
echo "    Options other than the above"
echo "        This command requires a K2HR3 Scoped Token."
echo "        Specify the K2HR3 Scoped Token itself or the options to"
echo "        create it."
echo "        Alternatively, specify an equivalent value in the"
echo "        Configuration file or environment variable."
echo "        Options other than the above"
echo ""

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
