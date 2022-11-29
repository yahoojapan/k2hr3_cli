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
# [OUTPUT]
#	K2HR3CLI_INTERACTIVE_INPUT	: variables that allow the entered value
#

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------
#
# Input from command line
#
# $1	: prompt string
# $2	: hide input(1)
#
# $?	: result
# Set global values
#	K2HR3CLI_INTERACTIVE_INPUT	: variables that allow the entered value
#
line_input()
{
	_INTERACTIVE_PROMPT=" > "
	_INTERACTIVE_HIDE_INPUT=0

	if [ $# -gt 0 ]; then
		if [ -n "$1" ]; then
			_INTERACTIVE_PROMPT="$1"
		fi
	fi
	shift
	if [ $# -gt 0 ]; then
		if [ -n "$1" ] && [ "$1" = "1" ]; then
			_INTERACTIVE_HIDE_INPUT=1
		fi
	fi

	pecho -n "${_INTERACTIVE_PROMPT}"
	if [ "${_INTERACTIVE_HIDE_INPUT}" -eq 1 ]; then
		stty -echo
	fi

	read -r K2HR3CLI_INTERACTIVE_INPUT

	if [ "${_INTERACTIVE_HIDE_INPUT}" -eq 1 ]; then
		stty echo
		for _INTERACTIVE_TMP_POS in $(seq 1 ${#K2HR3CLI_INTERACTIVE_INPUT}); do
			pecho -n "*"
		done
		pecho ""
	fi
	return 0
}

#
# Input for passphrase
#
# $1	: prompt string
#
# $?	: result
# Set global values
#	K2HR3CLI_INTERACTIVE_INPUT	: variables that allow the entered value
#
pass_input()
{
	_INTERACTIVE_PROMPT_PASS="Input passphrase: "
	if [ $# -gt 0 ]; then
		if [ -n "$1" ]; then
			_INTERACTIVE_PROMPT_PASS="$1"
		fi
	fi
	line_input "${_INTERACTIVE_PROMPT_PASS}" 1

	return $?
}

#
# Input for normal
#
# $1	: prompt string
#
# $?	: result
# Set global values
#	K2HR3CLI_INTERACTIVE_INPUT	: variables that allow the entered value
#
normal_input()
{
	_INTERACTIVE_PROMPT_NORMAL="Input: "
	if [ $# -gt 0 ]; then
		if [ -n "$1" ]; then
			_INTERACTIVE_PROMPT_NORMAL="$1"
		fi
	fi
	line_input "${_INTERACTIVE_PROMPT_NORMAL}"

	return $?
}

#
# check and input variable
#
# $1	: variable name
# $2	: prompt
# $3	: do not allow no input(1)
# $4	: hide input(1)
#
# $?	: result
# Set global values
#	[input variable($1)]	: variables that allow the entered value
#
completion_variable()
{
	if [ $# -lt 0 ]; then
		return 1
	fi
	_INTERACTIVE_COMPLETE_VARNAME="$1"
	shift
	_INTERACTIVE_COMPLETE_PROMPT="Input variable(${_INTERACTIVE_COMPLETE_VARNAME}): "
	_INTERACTIVE_COMPLETE_LOOP=0
	_INTERACTIVE_COMPLETE_HIDE=0
	if [ $# -gt 0 ]; then
		if [ -n "$1" ]; then
			_INTERACTIVE_COMPLETE_PROMPT="$1"
		fi
	fi
	shift
	if [ $# -gt 0 ]; then
		if [ -n "$1" ] && [ "$1" = "1" ]; then
			_INTERACTIVE_COMPLETE_LOOP=1
		fi
	fi
	shift
	if [ $# -gt 0 ]; then
		if [ -n "$1" ] && [ "$1" = "1" ]; then
			_INTERACTIVE_COMPLETE_HIDE=1
		fi
	fi

	#
	# Check current variable
	#
	_INTERACTIVE_COMPLETE_VALUE=$(eval pecho -n '$'"${_INTERACTIVE_COMPLETE_VARNAME}")
	if [ -n "${_INTERACTIVE_COMPLETE_VALUE}" ]; then
		return 0
	fi

	#
	# Input
	#
	_INTERACTIVE_COMPLETE_FIRST=1
	while [ "${_INTERACTIVE_COMPLETE_LOOP}" -eq 1 ] || [ "${_INTERACTIVE_COMPLETE_FIRST}" -eq 1 ]; do
		_INTERACTIVE_COMPLETE_FIRST=0

		pecho -n "${_INTERACTIVE_COMPLETE_PROMPT}"
		if [ "${_INTERACTIVE_COMPLETE_HIDE}" -eq 1 ]; then
			stty -echo
		fi

		# shellcheck disable=SC2229
		read -r "${_INTERACTIVE_COMPLETE_VARNAME}"

		_INTERACTIVE_COMPLETE_VALUE=$(eval pecho -n '$'"${_INTERACTIVE_COMPLETE_VARNAME}")
		if [ "${_INTERACTIVE_COMPLETE_HIDE}" -eq 1 ]; then
			stty echo
			for _INTERACTIVE_TMP_POS in $(seq 1 ${#_INTERACTIVE_COMPLETE_VALUE}); do
				pecho -n "*"
			done
			pecho ""
		fi

		if [ -n "${_INTERACTIVE_COMPLETE_VALUE}" ]; then
			#
			# Check back quote for shell executable charactor
			#
			if pecho -n "${_INTERACTIVE_COMPLETE_VALUE}" | grep -q '`'; then
				prn_err "Contains a character('\`') that cannot be specified."
				_INTERACTIVE_COMPLETE_VALUE=""
			else
				break
			fi
		fi
	done

	if [ -z "${_INTERACTIVE_COMPLETE_VALUE}" ]; then
		return 1
	fi
	return 0
}

#
# check and input variable with interactive mode
#
# $1	: variable name
# $2	: prompt
# $3	: do not allow no input(1)
# $4	: hide input(1)
#
# $?	: result
# Set global values
#	[input variable($1)]	: variables that allow the entered value
#
completion_variable_auto()
{
	if [ $# -lt 0 ]; then
		return 1
	fi

	#
	# Check variable
	#
	_INTERACTIVE_AUTO_COMPLETE_VARNAME="$1"
	_INTERACTIVE_AUTO_COMPLETE_VALUE=$(eval pecho -n '$'"${_INTERACTIVE_AUTO_COMPLETE_VARNAME}")
	if [ -z "${_INTERACTIVE_AUTO_COMPLETE_VALUE}" ]; then
		#
		# Not found variable
		#
		if [ -z "${K2HR3CLI_OPT_INTERACTIVE}" ] || [ "${K2HR3CLI_OPT_INTERACTIVE}" != "1" ]; then
			return 1
		fi

		#
		# Interactive mode
		#
		if ! completion_variable "$1" "$2" "$3" "$4"; then
			return 1
		fi
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
