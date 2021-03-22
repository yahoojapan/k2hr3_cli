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
# Environments and Variables
#---------------------------------------------------------------------
#
# Common options
#
# [NOTE]
# These options are not checked in parse_common_option function.
#
# shellcheck disable=SC2034
K2HR3CLI_COMMON_OPT_CONFIG_SHORT="-c"
# shellcheck disable=SC2034
K2HR3CLI_COMMON_OPT_CONFIG_LONG="--config"

#
# Common options
#
K2HR3CLI_COMMON_OPT_HELP_SHORT="-h"
K2HR3CLI_COMMON_OPT_HELP_LONG="--help"

K2HR3CLI_COMMON_OPT_VERSION_SHORT="-v"
K2HR3CLI_COMMON_OPT_VERSION_LONG="--version"

K2HR3CLI_COMMON_OPT_INTERACTIVE_SHORT="-i"
K2HR3CLI_COMMON_OPT_INTERACTIVE_LONG="--interactive"

K2HR3CLI_COMMON_OPT_NOINTERACTIVE_SHORT="-ni"
K2HR3CLI_COMMON_OPT_NOINTERACTIVE_LONG="--nointeractive"

K2HR3CLI_COMMON_OPT_MSGLEVEL_SHORT="-m"
K2HR3CLI_COMMON_OPT_MSGLEVEL_LONG="--messagelevel"

K2HR3CLI_COMMON_OPT_NODATE_SHORT="-nd"
K2HR3CLI_COMMON_OPT_NODATE_LONG="--nodate"

K2HR3CLI_COMMON_OPT_NOCOLOR_SHORT="-nc"
K2HR3CLI_COMMON_OPT_NOCOLOR_LONG="--nocolor"

K2HR3CLI_COMMON_OPT_JSON_SHORT="-j"
K2HR3CLI_COMMON_OPT_JSON_LONG="--json"

K2HR3CLI_COMMON_OPT_CURLDBG_SHORT="-cd"
K2HR3CLI_COMMON_OPT_CURLDBG_LONG="--curldebug"

K2HR3CLI_COMMON_OPT_CURLBODY_SHORT="-cb"
K2HR3CLI_COMMON_OPT_CURLBODY_LONG="--curlbody"

K2HR3CLI_COMMON_OPT_SAVE_SHORT="-s"
K2HR3CLI_COMMON_OPT_SAVE_LONG="--saveconfig"

K2HR3CLI_COMMON_OPT_SAVE_PASS_SHORT="-sp"
K2HR3CLI_COMMON_OPT_SAVE_PASS_LONG="--savepassphrase"

#
# Options used for basical command
#
K2HR3CLI_COMMAND_OPT_API_URI_SHORT="-a"
K2HR3CLI_COMMAND_OPT_API_URI_LONG="--apiuri"

K2HR3CLI_COMMAND_OPT_USER_SHORT="-u"
K2HR3CLI_COMMAND_OPT_USER_LONG="--user"

K2HR3CLI_COMMAND_OPT_PASS_SHORT="-p"
K2HR3CLI_COMMAND_OPT_PASS_LONG="--passphrase"

K2HR3CLI_COMMAND_OPT_TENANT_SHORT="-t"
K2HR3CLI_COMMAND_OPT_TENANT_LONG="--tenant"

K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT="-utoken"
K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG="--unscopedtoken"

K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_SHORT="-token"
K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_LONG="--scopedtoken"

K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT="-optoken"
K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG="--openstacktoken"

#
# Options used by each command
#
K2HR3CLI_COMMAND_OPT_EXPAND_LONG="--expand"
K2HR3CLI_COMMAND_OPT_POLICIES_LONG="--policies"
K2HR3CLI_COMMAND_OPT_ALIAS_LONG="--alias"
K2HR3CLI_COMMAND_OPT_HOST_LONG="--host"
K2HR3CLI_COMMAND_OPT_PORT_LONG="--port"
K2HR3CLI_COMMAND_OPT_CUK_LONG="--cuk"
K2HR3CLI_COMMAND_OPT_EXTRA_LONG="--extra"
K2HR3CLI_COMMAND_OPT_TAG_LONG="--tag"
K2HR3CLI_COMMAND_OPT_EXPIRE_LONG="--expire"
K2HR3CLI_COMMAND_OPT_TYPE_LONG="--type"
K2HR3CLI_COMMAND_OPT_DATA_LONG="--data"
K2HR3CLI_COMMAND_OPT_DATAFILE_LONG="--datafile"
K2HR3CLI_COMMAND_OPT_KEYS_LONG="--keys"
K2HR3CLI_COMMAND_OPT_SERVICE_LONG="--service"
K2HR3CLI_COMMAND_OPT_RESOURCE_LONG="--resource"
K2HR3CLI_COMMAND_OPT_KEYNAMES_LONG="--keynames"
K2HR3CLI_COMMAND_OPT_ALIASES_LONG="--aliases"
K2HR3CLI_COMMAND_OPT_EFFECT_LONG="--effect"
K2HR3CLI_COMMAND_OPT_ACTION_LONG="--action"
K2HR3CLI_COMMAND_OPT_CLEAR_TENANT_LONG="--clear_tenant"
K2HR3CLI_COMMAND_OPT_VERIFY_LONG="--verify"
K2HR3CLI_COMMAND_OPT_CIP_LONG="--cip"
K2HR3CLI_COMMAND_OPT_CPORT_LONG="--cport"
K2HR3CLI_COMMAND_OPT_CROLE_LONG="--crole"
K2HR3CLI_COMMAND_OPT_CCUK_LONG="--ccuk"
K2HR3CLI_COMMAND_OPT_SPORT_LONG="--sport"
K2HR3CLI_COMMAND_OPT_SROLE_LONG="--srole"
K2HR3CLI_COMMAND_OPT_SCUK_LONG="--scuk"
K2HR3CLI_COMMAND_OPT_OUTPUT_LONG="--output"

#
# Set variables for options
#
#	K2HR3CLI_OPT_HELP			: help option is specified
#	K2HR3CLI_OPT_VERSION		: version option is specified
#	K2HR3CLI_OPT_INTERACTIVE	: "1" means interactive mode, other is not.
#	K2HR3CLI_OPT_NODATE			: not output date in message(see. message.sh)
#	K2HR3CLI_OPT_NOCOLOR		: not use color in message(see. message.sh)
#	K2HR3CLI_OPT_JSON			: output result formatted by json
#	K2HR3CLI_OPT_CURLDBG		: use curl debug option for debugging
#	K2HR3CLI_OPT_CURLBODY		: use curl debug option(body) for debugging
#	K2HR3CLI_OPT_SAVE			: save spacial value(token etc) to configuration file
#	K2HR3CLI_OPT_SAVE_PASS		: save passphrase value to configuration file(need with --saveconfig option)
#	K2HR3CLI_OPT_EXPAND			: specify expand url arguments
#	K2HR3CLI_OPT_POLICIES		: ppolicies parameter
#	K2HR3CLI_OPT_ALIAS			: alias parameter
#	K2HR3CLI_OPT_HOST			: host parameter
#	K2HR3CLI_OPT_PORT			: port parameter
#	K2HR3CLI_OPT_CUK			: CUK parameter
#	K2HR3CLI_OPT_EXTRA			: extra parameter
#	K2HR3CLI_OPT_TAG			: tag parameter
#	K2HR3CLI_OPT_EXPIRE			: expire parameter
#	K2HR3CLI_OPT_TYPE			: type parameter
#	K2HR3CLI_OPT_DATA			: data parameter
#	K2HR3CLI_OPT_DATAFILE		: data file parameter
#	K2HR3CLI_OPT_KEYS			: keys parameter
#	K2HR3CLI_OPT_SERVICE		: service parameter
#	K2HR3CLI_OPT_RESOURCE		: resource parameter
#	K2HR3CLI_OPT_KEYNAMES		: keynames parameter
#	K2HR3CLI_OPT_ALIASES		: aliases parameter(not "alias")
#	K2HR3CLI_OPT_EFFECT			: effect parameter
#	K2HR3CLI_OPT_ACTION			: action parameter
#	K2HR3CLI_OPT_CLEAR_TENANT	: clear tenant parameter for service
#	K2HR3CLI_OPT_VERIFY			: verify parameter for service
#	K2HR3CLI_OPT_CIP			: cip parameter for ACR
#	K2HR3CLI_OPT_CPORT			: cport parameter for ACR
#	K2HR3CLI_OPT_CROLE			: crole parameter for ACR
#	K2HR3CLI_OPT_CCUK			: ccuk parameter for ACR
#	K2HR3CLI_OPT_SPORT			: sport parameter for ACR
#	K2HR3CLI_OPT_SROLE			: srole parameter for ACR
#	K2HR3CLI_OPT_SCUK			: scuk parameter for ACR
#	K2HR3CLI_OPT_OUTPUT			: output file path for userdata/extdata
#
# Set global variables for options
#	Some variables are allowed in configuration and can be loaded from
#	the configuration.('*' is allowed in configuration file)
#
#	K2HR3CLI_MSGLEVEL			: 		debug level(see. message.sh)
#	K2HR3CLI_API_URI			: (*)	URI to K2HR3 REST API
#	K2HR3CLI_USER				: (*)	user name for credential
#	K2HR3CLI_PASS				: (*)	passphrase for credential
#	K2HR3CLI_TENANT				: (*)	tenant for scoped token
#	K2HR3CLI_UNSCOPED_TOKEN		: (*)	unscoped token
#	K2HR3CLI_SCOPED_TOKEN		: (*)	scoped token
#	K2HR3CLI_OPENSTACK_TOKEN	: (*)	openstack (un)scoped token
#

#---------------------------------------------------------------------
# Utilities
#---------------------------------------------------------------------
#
# Escape space word for parsing all option
#
# $@	: all option
#
# Set global values
#	K2HR3CLI_OPTION_PARSER_REST	: the escaped option strings
#
escape_all_options()
{
	K2HR3CLI_OPTION_PARSER_REST=""
	_OPTION_IS_SET=0
	while [ $# -gt 0 ]; do
		if [ "X$1" != "X" ]; then
			_OPTION_TMP=$(pecho -n "$1" | sed -e 's/%/%25/g' -e 's/ /%20/g')
			if [ "${_OPTION_IS_SET}" -eq 0 ]; then
				K2HR3CLI_OPTION_PARSER_REST=${_OPTION_TMP}
				_OPTION_IS_SET=1
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} ${_OPTION_TMP}"
			fi
		fi
		shift
	done
}

#
# Check option parameter prefix
#
# $1	string
#
is_option_prefix()
{
	if [ "X$1" = "X" ]; then
		return 1
	fi
	_OPTION_TMP=$(pecho -n "$1" | cut -b 1)

	if [ "X${_OPTION_TMP}" = "X-" ]; then
		#
		# option prefix start '-'.(ex. "--option" or "-o")
		#
		return 0
	fi
	return 1
}

#
# Get two option value
#
# $1							: find option keyword 1
# $2							: find option keyword 2
# $3...							: input parameters
#
# $?							: returns 1 for fatal errors
# Set global values
#	K2HR3CLI_OPTION_PARSER_REST	: the remaining option string with the help option cut off(for new $@)
#	K2HR3_OPTION_VALUE			: output option value
#
get_option2_value()
{
	K2HR3CLI_OPTION_PARSER_REST=""
	K2HR3_OPTION_VALUE=
	if [ $# -lt 3 ]; then
		return 0
	fi
	_OPTION_KEYWORD1=$(to_lower "$1")
	_OPTION_KEYWORD2=$(to_lower "$2")
	shift 2

	_OPTION_VALUE=""
	while [ $# -gt 0 ]; do
		_OPTION_TMP=$(pecho -n "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
		_OPTION_TMP=$(to_lower "${_OPTION_TMP}")

		if [ "X${_OPTION_TMP}" = "X${_OPTION_KEYWORD1}" ] || [ "X${_OPTION_TMP}" = "X${_OPTION_KEYWORD2}" ]; then
			if [ "X${_OPTION_TMP}" = "X${_OPTION_KEYWORD1}" ]; then
				_OPTION_KEYWORD_TMP=${_OPTION_KEYWORD1}
			else
				_OPTION_KEYWORD_TMP=${_OPTION_KEYWORD2}
			fi
			if [ "X${_OPTION_VALUE}" != "X" ]; then
				prn_info "already specified ${_OPTION_KEYWORD_TMP} option with value(${_OPTION_VALUE})."
				return 1
			fi
			shift
			if [ $# -eq 0 ]; then
				prn_info "${_OPTION_KEYWORD_TMP} option does not have value."
				return 1
			fi
			_OPTION_VALUE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
		else
			if [ "X${K2HR3CLI_OPTION_PARSER_REST}" = "X" ]; then
				K2HR3CLI_OPTION_PARSER_REST="$1"
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $1"
			fi
		fi
		shift
	done

	if [ "X${_OPTION_VALUE}" = "X" ]; then
		if [ "X${_OPTION_KEYWORD1}" != "X" ] && [ "X${_OPTION_KEYWORD2}" != "X" ]; then
			prn_dbg "${_OPTION_KEYWORD1} or ${_OPTION_KEYWORD2} option is not found."
		elif [ "X${_OPTION_KEYWORD1}" != "X" ]; then
			prn_dbg "${_OPTION_KEYWORD1} option is not found."
		else
			prn_dbg "${_OPTION_KEYWORD2} option is not found."
		fi
		return 0
	fi

	# shellcheck disable=SC2034
	K2HR3_OPTION_VALUE=${_OPTION_VALUE}

	return 0
}

#
# Parse no-prefix option
#
# $@							: option strings
#
# $?							; returns 1 for fatal errors
# Set global values
#	K2HR3CLI_OPTION_PARSER_REST	: the remaining option string with the help option cut off(for new $@)
#	K2HR3CLI_OPTION_NOPREFIX	: first string in command line other than option prefix("-").
#
parse_noprefix_option()
{
	K2HR3CLI_OPTION_PARSER_REST=""
	K2HR3CLI_OPTION_NOPREFIX=
	while [ $# -gt 0 ]; do
		is_option_prefix "$1"
		if [ $? -ne 0 ]; then
			# shellcheck disable=SC2034
			K2HR3CLI_OPTION_NOPREFIX=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

			shift
			if [ "X${K2HR3CLI_OPTION_PARSER_REST}" = "X" ]; then
				# shellcheck disable=SC2124
				K2HR3CLI_OPTION_PARSER_REST="$@"
			else
				# shellcheck disable=SC2124
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $@"
			fi
			return 0
		else
			if [ "X${K2HR3CLI_OPTION_PARSER_REST}" = "X" ]; then
				K2HR3CLI_OPTION_PARSER_REST="$1"
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $1"
			fi
		fi
		shift
	done

	#
	# not found
	#
	return 0
}

#
# Parse mode option
#
# $@							: option strings
#
# $?							; returns 1 for fatal errors
# Set global values
#	K2HR3CLI_OPTION_PARSER_REST	: the remaining option string with the help option cut off(for new $@)
#	K2HR3CLI_OPTION_NOPREFIX	: first string in command line other than option prefix("-").
#
parse_mode_option()
{
	K2HR3CLI_OPTION_PARSER_REST=""
	K2HR3CLI_OPTION_NOPREFIX=
	while [ $# -gt 0 ]; do
		is_option_prefix "$1"
		if [ $? -ne 0 ]; then
			check_mode_string "$1"
			if [ $? -ne 0 ]; then
				prn_err "Unknown mode($1) is specified. Specify the mode with one of the following: ${K2HR3CLI_MODES}"
				return 1
			fi
			# shellcheck disable=SC2034
			K2HR3CLI_OPTION_NOPREFIX=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

			shift
			if [ "X${K2HR3CLI_OPTION_PARSER_REST}" = "X" ]; then
				# shellcheck disable=SC2124
				K2HR3CLI_OPTION_PARSER_REST="$@"
			else
				# shellcheck disable=SC2124
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $@"
			fi
			return 0
		else
			if [ "X${K2HR3CLI_OPTION_PARSER_REST}" = "X" ]; then
				K2HR3CLI_OPTION_PARSER_REST="$1"
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $1"
			fi
		fi
		shift
	done

	#
	# not found
	#
	return 0
}

#
# Parse common option
#
# $@							option strings
#
# $?							returns 1 for fatal errors
# Set global values
#	K2HR3CLI_OPTION_PARSER_REST	: the remaining option string with the help option cut off(for new $@)
#	K2HR3CLI_OPT_HELP			: --help(-h)
#	K2HR3CLI_OPT_VERSION		: --version(-v)
#	K2HR3CLI_OPT_INTERACTIVE	: --interactive(-i) and --nointeractive(-ni)
#	K2HR3CLI_OPT_NODATE			: --nodate(-nd)
#	K2HR3CLI_OPT_NOCOLOR		: --nocolor(-nc)
#	K2HR3CLI_OPT_JSON			: --json(-j)
#	K2HR3CLI_OPT_CURLDBG		: --curldebug(-cd)
#	K2HR3CLI_OPT_CURLBODY		: --curlbody(-cb)
#	K2HR3CLI_OPT_SAVE			: --saveconfig(-s)
#	K2HR3CLI_OPT_SAVE_PASS		: --savepassphrase(-sp)
#	K2HR3CLI_OPT_EXPAND			: --expand(-ex)
#	K2HR3CLI_OPT_POLICIES		: --ppolicies
#	K2HR3CLI_OPT_ALIAS			: --alias
#	K2HR3CLI_OPT_HOST			: --host
#	K2HR3CLI_OPT_PORT			: --port
#	K2HR3CLI_OPT_CUK			: --cuk
#	K2HR3CLI_OPT_EXTRA			: --extra
#	K2HR3CLI_OPT_TAG			: --tag
#	K2HR3CLI_OPT_EXPIRE			: --expire
#	K2HR3CLI_OPT_TYPE			: --type
#	K2HR3CLI_OPT_DATA			: --data
#	K2HR3CLI_OPT_DATAFILE		: --datafile
#	K2HR3CLI_OPT_KEYS			: --keys
#	K2HR3CLI_OPT_SERVICE		: --service
#	K2HR3CLI_OPT_RESOURCE		: --resource
#	K2HR3CLI_OPT_KEYNAMES		: --keynames
#	K2HR3CLI_OPT_ALIASES		: --aliases
#	K2HR3CLI_OPT_EFFECT			: --effect
#	K2HR3CLI_OPT_ACTION			: --action
#	K2HR3CLI_OPT_CLEAR_TENANT	: --clear_tenant
#	K2HR3CLI_OPT_VERIFY			: --verify
#	K2HR3CLI_OPT_CIP			: --cip
#	K2HR3CLI_OPT_CPORT			: --cport
#	K2HR3CLI_OPT_CROLE			: --crole
#	K2HR3CLI_OPT_CCUK   		: --ccuk
#	K2HR3CLI_OPT_SPORT  		: --sport
#	K2HR3CLI_OPT_SROLE  		: --srole
#	K2HR3CLI_OPT_SCUK   		: --scuk
#	K2HR3CLI_OPT_OUTPUT   		: --output
#
#	K2HR3CLI_MSGLEVEL			: --messagelevel(-m)
#	K2HR3CLI_API_URI			: --apiuri(-a)
#	K2HR3CLI_USER				: --user(-u)
#	K2HR3CLI_PASS				: --passphrase(-p)
#	K2HR3CLI_TENANT				: --tenant(-t)
#	K2HR3CLI_UNSCOPED_TOKEN		: --unscopedtoken(-utoken)
#	K2HR3CLI_SCOPED_TOKEN		: --scopedtoken(-token)
#	K2HR3CLI_OPENSTACK_TOKEN	: --openstacktoken(-optoken)
#
# [NOTE]
# Unscoped Token(K2HR3CLI_UNSCOPED_TOKEN) and Scoped Token(K2HR3CLI_SCOPED_TOKEN) are removed
# if --user(-u) and --passphrase(-p) are specified.
# This means that the specified user will get the Unscoped Toke and Scoped Toke again.
#
parse_common_option()
{
	#
	# Temporary values
	#
	_OPT_TMP_MSGLEVEL=
	_OPT_TMP_API_URI=
	_OPT_TMP_USER=
	_OPT_TMP_PASS=
	_OPT_TMP_TENANT=
	_OPT_TMP_UNSCOPED_TOKEN=
	_OPT_TMP_SCOPED_TOKEN=
	_OPT_TMP_OPENSTACK_TOKEN=
	_OPT_TMP_POLICIES=
	_OPT_TMP_ALIAS=
	_OPT_TMP_HOST=
	_OPT_TMP_PORT=
	_OPT_TMP_CUK=
	_OPT_TMP_EXTRA=
	_OPT_TMP_TAG=
	_OPT_TMP_EXPIRE=
	_OPT_TMP_TYPE=
	_OPT_TMP_DATA=
	_OPT_TMP_DATAFILE=
	_OPT_TMP_KEYS=
	_OPT_TMP_SERVICE=
	_OPT_TMP_RESOURCE=
	_OPT_TMP_KEYNAMES=
	_OPT_TMP_ALIASES=
	_OPT_TMP_EFFECT=
	_OPT_TMP_ACTION=
	_OPT_TMP_CLEAR_TENANT=
	_OPT_TMP_VERIFY=
	_OPT_TMP_CIP=
	_OPT_TMP_CPORT=
	_OPT_TMP_CROLE=
	_OPT_TMP_CCUK=
	_OPT_TMP_SPORT=
	_OPT_TMP_SROLE=
	_OPT_TMP_SCUK=
	_OPT_TMP_OUTPUT=

	K2HR3CLI_OPTION_PARSER_REST=""
	while [ $# -gt 0 ]; do
		_OPTION_TMP=$(pecho -n "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')
		_OPTION_TMP=$(to_lower "${_OPTION_TMP}")

		if [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_HELP_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_HELP_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_HELP}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_HELP=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_VERSION_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_VERSION_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_VERSION}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_VERSION_LONG}(${K2HR3CLI_COMMON_OPT_VERSION_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_VERSION=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_INTERACTIVE_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_INTERACTIVE_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_INTERACTIVE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_INTERACTIVE_LONG}(${K2HR3CLI_COMMON_OPT_INTERACTIVE_SHORT}) or ${K2HR3CLI_COMMON_OPT_NOINTERACTIVE_LONG}(${K2HR3CLI_COMMON_OPT_NOINTERACTIVE_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_INTERACTIVE=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_NOINTERACTIVE_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_NOINTERACTIVE_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_INTERACTIVE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_INTERACTIVE_LONG}(${K2HR3CLI_COMMON_OPT_INTERACTIVE_SHORT}) or ${K2HR3CLI_COMMON_OPT_NOINTERACTIVE_LONG}(${K2HR3CLI_COMMON_OPT_NOINTERACTIVE_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_INTERACTIVE=0

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_NODATE_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_NODATE_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_NODATE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_NODATE_LONG}(${K2HR3CLI_COMMON_OPT_NODATE_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_NODATE=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_NOCOLOR_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_NOCOLOR_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_NOCOLOR}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_NOCOLOR_LONG}(${K2HR3CLI_COMMON_OPT_NOCOLOR_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_NOCOLOR=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_JSON_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_JSON_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_JSON}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_JSON_LONG}(${K2HR3CLI_COMMON_OPT_JSON_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_JSON=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_CURLDBG_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_CURLDBG_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_CURLDBG}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_CURLDBG_LONG}(${K2HR3CLI_COMMON_OPT_CURLDBG_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_CURLDBG=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_CURLBODY_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_CURLBODY_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_CURLBODY}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_CURLBODY_LONG}(${K2HR3CLI_COMMON_OPT_CURLBODY_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_CURLBODY=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_SAVE_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_SAVE_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_SAVE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_SAVE_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_SAVE=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_SAVE_PASS_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_SAVE_PASS_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_SAVE_PASS}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_SAVE_PASS_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_PASS_SHORT}) option."
				return 1
			fi
			K2HR3CLI_OPT_SAVE_PASS=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_MSGLEVEL_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMON_OPT_MSGLEVEL_LONG}" ]; then
			if [ -n "${_OPT_TMP_MSGLEVEL}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMON_OPT_MSGLEVEL_LONG}(${K2HR3CLI_COMMON_OPT_MSGLEVEL_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMON_OPT_MSGLEVEL_LONG}(${K2HR3CLI_COMMON_OPT_MSGLEVEL_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_MSGLEVEL=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_API_URI_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_API_URI_LONG}" ]; then
			if [ -n "${_OPT_TMP_API_URI}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_API_URI_LONG}(${K2HR3CLI_COMMAND_OPT_API_URI_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_API_URI_LONG}(${K2HR3CLI_COMMAND_OPT_API_URI_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_API_URI=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

			#
			# Check and add last teminate word("/")
			#
			_OPTION_TMP_CHAR=${#_OPTION_TMP_CHAR}
			if [ "${_OPTION_TMP_CHAR}" -gt 0 ]; then
				_OPTION_TMP_CHAR=$(pecho -n "${_OPT_TMP_API_URI}" | cut -b "${_OPTION_TMP_CHAR}" 2>/dev/null)
				if [ "X${_OPTION_TMP_CHAR}" != "X" ] && [ "X${_OPTION_TMP_CHAR}" != "X/" ]; then
					_OPT_TMP_API_URI="${_OPT_TMP_API_URI}/"
				fi
			fi

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_USER_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_USER_LONG}" ]; then
			if [ -n "${_OPT_TMP_USER}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_USER_LONG}(${K2HR3CLI_COMMAND_OPT_USER_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_USER_LONG}(${K2HR3CLI_COMMAND_OPT_USER_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_USER=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_PASS_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_PASS_LONG}" ]; then
			if [ -n "${_OPT_TMP_PASS}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_PASS_LONG}(${K2HR3CLI_COMMAND_OPT_PASS_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_PASS_LONG}(${K2HR3CLI_COMMAND_OPT_PASS_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_PASS=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_TENANT_LONG}" ]; then
			if [ -n "${_OPT_TMP_TENANT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_TENANT_LONG}(${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_TENANT_LONG}(${K2HR3CLI_COMMAND_OPT_TENANT_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_TENANT=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}" ]; then
			if [ -n "${_OPT_TMP_UNSCOPED_TOKEN}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_UNSCOPED_TOKEN_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_UNSCOPED_TOKEN=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_LONG}" ]; then
			if [ -n "${_OPT_TMP_SCOPED_TOKEN}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_SCOPED_TOKEN_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_SCOPED_TOKEN=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT}" ] || [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG}" ]; then
			if [ -n "${_OPT_TMP_OPENSTACK_TOKEN}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT}) option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_LONG}(${K2HR3CLI_COMMAND_OPT_OPENSTACK_TOKEN_SHORT}) option needs parameter."
				return 1
			fi
			_OPT_TMP_OPENSTACK_TOKEN=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_EXPAND_LONG}" ]; then
			if [ -n "${K2HR3CLI_OPT_EXPAND}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_EXPAND_LONG} option."
				return 1
			fi
			K2HR3CLI_OPT_EXPAND=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_POLICIES_LONG}" ]; then
			if [ -n "${_OPT_TMP_POLICIES}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_POLICIES_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_POLICIES_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_POLICIES=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_ALIAS_LONG}" ]; then
			if [ -n "${_OPT_TMP_ALIAS}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_ALIAS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_ALIAS_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_ALIAS=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_HOST_LONG}" ]; then
			if [ -n "${_OPT_TMP_HOST}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_HOST_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_HOST_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_HOST=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_PORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_PORT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_PORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_PORT_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_PORT=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_CUK_LONG}" ]; then
			if [ -n "${_OPT_TMP_CUK}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_CUK_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_CUK_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_CUK=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_EXTRA_LONG}" ]; then
			if [ -n "${_OPT_TMP_EXTRA}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_EXTRA_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_EXTRA_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_EXTRA=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_TAG_LONG}" ]; then
			if [ -n "${_OPT_TMP_TAG}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_TAG_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_TAG_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_TAG=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_EXPIRE_LONG}" ]; then
			if [ -n "${_OPT_TMP_EXPIRE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_EXPIRE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_EXPIRE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_EXPIRE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_TYPE_LONG}" ]; then
			if [ -n "${_OPT_TMP_TYPE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_TYPE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_TYPE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_TYPE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_DATA_LONG}" ]; then
			if [ -n "${_OPT_TMP_DATA}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DATA_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DATA_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DATA=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DATAFILE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG} option needs parameter."
				return 1
			fi
			if [ ! -f "$1" ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG} option parameter($1) file does not exist."
				return 1
			fi
			_OPT_TMP_DATAFILE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_KEYS_LONG}" ]; then
			if [ -n "${_OPT_TMP_KEYS}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_KEYS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_KEYS_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_KEYS=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_SERVICE_LONG}" ]; then
			if [ -n "${_OPT_TMP_SERVICE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_SERVICE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_SERVICE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_SERVICE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_RESOURCE_LONG}" ]; then
			if [ -n "${_OPT_TMP_RESOURCE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_RESOURCE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_RESOURCE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_RESOURCE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_KEYNAMES_LONG}" ]; then
			if [ -n "${_OPT_TMP_KEYNAMES}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_KEYNAMES_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_KEYNAMES_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_KEYNAMES=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_ALIASES_LONG}" ]; then
			if [ -n "${_OPT_TMP_ALIASES}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_ALIASES_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_ALIASES_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_ALIASES=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_EFFECT_LONG}" ]; then
			if [ -n "${_OPT_TMP_EFFECT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_EFFECT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_EFFECT_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_EFFECT=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_ACTION_LONG}" ]; then
			if [ -n "${_OPT_TMP_ACTION}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_ACTION_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_ACTION_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_ACTION=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_CLEAR_TENANT_LONG}" ]; then
			if [ -n "${_OPT_TMP_CLEAR_TENANT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_CLEAR_TENANT_LONG} option."
				return 1
			fi
			_OPT_TMP_CLEAR_TENANT=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_VERIFY_LONG}" ]; then
			if [ -n "${_OPT_TMP_VERIFY}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_VERIFY_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_VERIFY_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_VERIFY=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_CIP_LONG}" ]; then
			if [ -n "${_OPT_TMP_CIP}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_CIP_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_CIP_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_CIP=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_CPORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_CPORT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_CPORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_CPORT_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_CPORT=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_CROLE_LONG}" ]; then
			if [ -n "${_OPT_TMP_CROLE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_CROLE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_CROLE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_CROLE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_CCUK_LONG}" ]; then
			if [ -n "${_OPT_TMP_CCUK}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_CCUK_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_CCUK_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_CCUK=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_SPORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_SPORT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_SPORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_SPORT_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_SPORT=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_SROLE_LONG}" ]; then
			if [ -n "${_OPT_TMP_SROLE}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_SROLE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_SROLE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_SROLE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_SCUK_LONG}" ]; then
			if [ -n "${_OPT_TMP_SCUK}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_SCUK_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_SCUK_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_SCUK=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_COMMAND_OPT_OUTPUT_LONG}" ]; then
			if [ -n "${_OPT_TMP_OUTPUT}" ]; then
				prn_err "already specified ${K2HR3CLI_COMMAND_OPT_OUTPUT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_COMMAND_OPT_OUTPUT_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_OUTPUT_TMP=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

			#
			# Check file path
			#
			pecho -n "${_OPT_TMP_OUTPUT_TMP}" | grep -q "/"
			if [ $? -ne 0 ]; then
				_OPT_TMP_OUTPUT_TMP="./${_OPT_TMP_OUTPUT_TMP}"
			fi
			_OPT_TMP_OUTPUT_DIR_TMP=$(dirname "$0")
			_OPT_TMP_OUTPUT_DIR_TMP=$(cd "${_OPT_TMP_OUTPUT_DIR_TMP}" || exit 1; pwd)
			if [ ! -d "${_OPT_TMP_OUTPUT_DIR_TMP}" ]; then
				prn_err "Specified output file(${_OPT_TMP_OUTPUT_TMP}) path by ${K2HR3CLI_COMMAND_OPT_OUTPUT_LONG} option, but the path to that file(directory) does not exist."
				return 1
			fi
			_OPT_TMP_OUTPUT="${_OPT_TMP_OUTPUT_TMP}"

		else
			if [ "X${K2HR3CLI_OPTION_PARSER_REST}" = "X" ]; then
				K2HR3CLI_OPTION_PARSER_REST="$1"
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $1"
			fi
		fi
		shift
	done

	#
	# Set override default and global value
	#
	if [ -z "${K2HR3CLI_OPT_INTERACTIVE}" ]; then
		K2HR3CLI_OPT_INTERACTIVE=0
	fi

	if [ -n "${_OPT_TMP_MSGLEVEL}" ]; then
		#
		# Set K2HR3CLI_MSGLEVEL variable in following function.
		#
		set_msglevel "${_OPT_TMP_MSGLEVEL}"
		if [ $? -ne 0 ]; then
			prn_err "Unknown ${K2HR3CLI_COMMON_OPT_MSGLEVEL_LONG}(${K2HR3CLI_COMMON_OPT_MSGLEVEL_SHORT}) option parameter(${_OPT_TMP_MSGLEVEL}) is specified."
			return 1
		fi
	fi

	if [ -n "${_OPT_TMP_API_URI}" ]; then
		_OPT_TMP_API_URI=$(filter_null_string "${_OPT_TMP_API_URI}")

		if [ "X${_OPT_TMP_API_URI}" != "X${K2HR3CLI_API_URI}" ]; then
			add_config_update_var "K2HR3CLI_API_URI"
		fi
		K2HR3CLI_API_URI=${_OPT_TMP_API_URI}
	fi
	if [ -n "${_OPT_TMP_TENANT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_TENANT=$(filter_null_string "${_OPT_TMP_TENANT}")
	fi
	if [ -n "${_OPT_TMP_UNSCOPED_TOKEN}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_UNSCOPED_TOKEN=$(filter_null_string "${_OPT_TMP_UNSCOPED_TOKEN}")
		# shellcheck disable=SC2034
		K2HR3CLI_SCOPED_TOKEN=""
	fi
	if [ -n "${_OPT_TMP_SCOPED_TOKEN}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_SCOPED_TOKEN=$(filter_null_string "${_OPT_TMP_SCOPED_TOKEN}")
	fi
	if [ -n "${_OPT_TMP_OPENSTACK_TOKEN}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPENSTACK_TOKEN=$(filter_null_string "${_OPT_TMP_OPENSTACK_TOKEN}")
	fi
	if [ -n "${_OPT_TMP_USER}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_USER=$(filter_null_string "${_OPT_TMP_USER}")
		# shellcheck disable=SC2034
		K2HR3CLI_UNSCOPED_TOKEN=""
		# shellcheck disable=SC2034
		K2HR3CLI_SCOPED_TOKEN=""
	fi
	if [ -n "${_OPT_TMP_PASS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_PASS=$(filter_null_string "${_OPT_TMP_PASS}")
		# shellcheck disable=SC2034
		K2HR3CLI_UNSCOPED_TOKEN=""
		# shellcheck disable=SC2034
		K2HR3CLI_SCOPED_TOKEN=""
	fi
	if [ -n "${_OPT_TMP_POLICIES}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_POLICIES=$(filter_null_string "${_OPT_TMP_POLICIES}")
	fi
	if [ -n "${_OPT_TMP_ALIAS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_ALIAS=$(filter_null_string "${_OPT_TMP_ALIAS}")
	fi
	if [ -n "${_OPT_TMP_HOST}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_HOST=$(filter_null_string "${_OPT_TMP_HOST}")
	fi
	if [ -n "${_OPT_TMP_PORT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_PORT=$(filter_null_string "${_OPT_TMP_PORT}")
	fi
	if [ -n "${_OPT_TMP_CUK}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_CUK=$(filter_null_string "${_OPT_TMP_CUK}")
	fi
	if [ -n "${_OPT_TMP_EXTRA}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_EXTRA=$(filter_null_string "${_OPT_TMP_EXTRA}")
	fi
	if [ -n "${_OPT_TMP_TAG}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_TAG=$(filter_null_string "${_OPT_TMP_TAG}")
	fi
	if [ -n "${_OPT_TMP_EXPIRE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_EXPIRE=${_OPT_TMP_EXPIRE}
	fi
	if [ -n "${_OPT_TMP_TYPE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_TYPE=$(filter_null_string "${_OPT_TMP_TYPE}")
	fi
	if [ -n "${_OPT_TMP_DATA}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_DATA=$(filter_null_string "${_OPT_TMP_DATA}")
	fi
	if [ -n "${_OPT_TMP_DATAFILE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_DATAFILE=${_OPT_TMP_DATAFILE}
	fi
	if [ -n "${_OPT_TMP_KEYS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_KEYS=$(filter_null_string "${_OPT_TMP_KEYS}")
	fi
	if [ -n "${_OPT_TMP_SERVICE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_SERVICE=$(filter_null_string "${_OPT_TMP_SERVICE}")
	fi
	if [ -n "${_OPT_TMP_RESOURCE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_RESOURCE=$(filter_null_string "${_OPT_TMP_RESOURCE}")
	fi
	if [ -n "${_OPT_TMP_KEYNAMES}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_KEYNAMES=$(filter_null_string "${_OPT_TMP_KEYNAMES}")
	fi
	if [ -n "${_OPT_TMP_ALIASES}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_ALIASES=$(filter_null_string "${_OPT_TMP_ALIASES}")
	fi
	if [ -n "${_OPT_TMP_EFFECT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_EFFECT=$(filter_null_string "${_OPT_TMP_EFFECT}")
	fi
	if [ -n "${_OPT_TMP_ACTION}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_ACTION=$(filter_null_string "${_OPT_TMP_ACTION}")
	fi
	if [ -n "${_OPT_TMP_CLEAR_TENANT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_CLEAR_TENANT=${_OPT_TMP_CLEAR_TENANT}
	fi
	if [ -n "${_OPT_TMP_VERIFY}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_VERIFY=$(filter_null_string "${_OPT_TMP_VERIFY}")
	fi
	if [ -n "${_OPT_TMP_CIP}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_CIP=$(filter_null_string "${_OPT_TMP_CIP}")
	fi
	if [ -n "${_OPT_TMP_CPORT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_CPORT=$(filter_null_string "${_OPT_TMP_CPORT}")
	fi
	if [ -n "${_OPT_TMP_CROLE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_CROLE=$(filter_null_string "${_OPT_TMP_CROLE}")
	fi
	if [ -n "${_OPT_TMP_CCUK}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_CCUK=$(filter_null_string "${_OPT_TMP_CCUK}")
	fi
	if [ -n "${_OPT_TMP_SPORT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_SPORT=$(filter_null_string "${_OPT_TMP_SPORT}")
	fi
	if [ -n "${_OPT_TMP_SROLE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_SROLE=$(filter_null_string "${_OPT_TMP_SROLE}")
	fi
	if [ -n "${_OPT_TMP_SCUK}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_SCUK=$(filter_null_string "${_OPT_TMP_SCUK}")
	fi
	if [ -n "${_OPT_TMP_OUTPUT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_OPT_OUTPUT=${_OPT_TMP_OUTPUT}
	fi

	#
	# Check conflict about data and datafile options
	#
	if [ "X${K2HR3CLI_OPT_DATA}" != "X" ] && [ "X${K2HR3CLI_OPT_DATAFILE}" != "X" ]; then
		prn_err "${K2HR3CLI_COMMAND_OPT_DATA_LONG} and ${K2HR3CLI_COMMAND_OPT_DATAFILE_LONG} option cannot be specified at the same time."
		return 1
	fi

	#
	# Check passphrase save option
	#
	if [ -n "${K2HR3CLI_OPT_SAVE_PASS}" ]; then
		if [ "${K2HR3CLI_OPT_SAVE_PASS}" -eq 1 ]; then
			if [ -z "${K2HR3CLI_OPT_SAVE}" ]; then
				prn_err "${K2HR3CLI_COMMON_OPT_SAVE_PASS_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_PASS_SHORT}) option is specified, but this option must be specified with the ${K2HR3CLI_COMMON_OPT_SAVE_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_SHORT}) option."
				return 1
			elif [ "${K2HR3CLI_OPT_SAVE}" -ne 1 ]; then
				prn_err "${K2HR3CLI_COMMON_OPT_SAVE_PASS_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_PASS_SHORT}) option is specified, but this option must be specified with the ${K2HR3CLI_COMMON_OPT_SAVE_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_SHORT}) option."
				return 1
			else
				prn_warn "${K2HR3CLI_COMMON_OPT_SAVE_PASS_LONG}(${K2HR3CLI_COMMON_OPT_SAVE_PASS_SHORT}) option is specified, be aware of the DANGER of your passphrase being saved in a configuration file."
			fi
		fi
	fi

	#
	# Check special variable(K2HR3CLI_API_URI)
	#
	# Cut last word if it is '/' and space
	#
	if [ -n "${K2HR3CLI_API_URI}" ]; then
		for _OPT_TMP_URI_POS in $(seq 0 ${#K2HR3CLI_API_URI}); do
			_OPT_TMP_URI_LAST_POS=$((${#K2HR3CLI_API_URI} - _OPT_TMP_URI_POS))
			if [ "${_OPT_TMP_URI_LAST_POS}" -le 0 ]; then
				break
			fi
			_OPT_TMP_URI_LAST_CH=$(pecho -n "${K2HR3CLI_API_URI}" | cut -b "${_OPT_TMP_URI_LAST_POS}")
			if [ "X${_OPT_TMP_URI_LAST_CH}" = "X/" ] || [ "X${_OPT_TMP_URI_LAST_CH}" = "X " ] || [ "X${_OPT_TMP_URI_LAST_CH}" = "X${K2HR3CLI_TAB_WORD}" ]; then
				if [ "${_OPT_TMP_URI_LAST_POS}" -gt 1 ]; then
					_OPT_TMP_URI_LAST_POS=$((_OPT_TMP_URI_LAST_POS - 1))
					K2HR3CLI_API_URI=$(pecho -n "${K2HR3CLI_API_URI}" | cut -c 1-"${_OPT_TMP_URI_LAST_POS}")
				else
					K2HR3CLI_API_URI=""
					break;
				fi
			else
				break
			fi
		done
	fi

	return 0
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
