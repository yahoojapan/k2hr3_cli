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
echo "K2HR3 CLI command for the USERDATA API of the K2HR3 REST API."
echo "    See https://k2hr3.antpick.ax/api_userdata.html"
echo ""
echo "${K2HR3CLI_MODE} is a command that operates on userdata in the K2HR3"
echo "system."
echo ""
echo "GET USERDATA:"
echo ""
echo "    USAGE: ${BINNAME} ${K2HR3CLI_MODE} <registerpath> <option...>"
echo "            ${K2HR3CLI_COMMAND_OPT_OUTPUT_LONG} <file path>"
echo ""
echo "        *) The registerpath is included in the information that"
echo "           you can get when you create the role token."
echo "           You can also get it by getting (expanding) the list of"
echo "           role tokens using scoped tokens."
echo ""
echo "OPTION:"
echo "    ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})"
echo "        Display ${K2HR3CLI_MODE} command help."
echo ""
echo "    ${K2HR3CLI_COMMAND_OPT_OUTPUT_LONG}"
echo "         The result of this command is a file downloaded from"
echo "         the K2HR3 REST API."
echo "         If it is not specified this option, the zip file is"
echo "         unzipped and its contents are printed to standard"
echo "         output."
echo ""
echo "    Options other than the above"
echo "        The Token command uses the following options."
echo "        You can get help with run \"${BINNAME} --help(-h)\" to find"
echo "        out more about these options."
echo ""
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
