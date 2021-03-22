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
# [INPUT]
# K2HR3CLI_MSGLEVEL			:	message level
#
# [Local value in this file]
# K2HR3CLI_MSGLEVEL_VALUE	:	Message output level
#								0	:	Silent
#								1	:	Error
#								2	:	Warning
#								3	:	Information
#								4	:	debug
#

if [ -z "${K2HR3CLI_MSGLEVEL_VALUE}" ]; then
	K2HR3CLI_MSGLEVEL_VALUE=2
else
	# shellcheck disable=SC2003
	expr "${K2HR3CLI_MSGLEVEL_VALUE}" + 1 >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		#
		# Wrong value -> overwrite default value
		#
		K2HR3CLI_MSGLEVEL_VALUE=2
	fi
fi

#---------------------------------------------------------------------
# Utilities
#---------------------------------------------------------------------
#
# Set message level
#
# $1	Message level: string or number
#
set_msglevel()
{
	if [ "X$1" = "X0" ] || [ "X$1" = "Xslt" ] || [ "X$1" = "XSLT" ] || [ "X$1" = "Xsilent" ] || [ "X$1" = "XSILENT" ]; then
		K2HR3CLI_MSGLEVEL_VALUE=0
	elif [ "X$1" = "X1" ] || [ "X$1" = "Xerr" ] || [ "X$1" = "XERR" ] || [ "X$1" = "Xerror" ] || [ "X$1" = "XERROR" ]; then
		K2HR3CLI_MSGLEVEL_VALUE=1
	elif [ "X$1" = "X2" ] || [ "X$1" = "Xwan" ] || [ "X$1" = "XWAN" ] || [ "X$1" = "Xwarn" ] || [ "X$1" = "XWARN" ] || [ "X$1" = "Xwarning" ] || [ "X$1" = "XWARNING" ]; then
		K2HR3CLI_MSGLEVEL_VALUE=2
	elif [ "X$1" = "X3" ] || [ "X$1" = "Xinf" ] || [ "X$1" = "XINF" ] || [ "X$1" = "Xinfo" ] || [ "X$1" = "XINFO" ] || [ "X$1" = "Xinformation" ] || [ "X$1" = "XINFORMATION" ]; then
		K2HR3CLI_MSGLEVEL_VALUE=3
	elif [ "X$1" = "X4" ] || [ "X$1" = "Xdbg" ] || [ "X$1" = "XDBG" ] || [ "X$1" = "Xdebug" ] || [ "X$1" = "XDEBUG" ]; then
		K2HR3CLI_MSGLEVEL_VALUE=4
	else
		return 1
	fi
	return 0
}

#---------------------------------------------------------------------
# Logging functions
#---------------------------------------------------------------------
#
# Base Message Function
#
# $1	:	date(print date), other does not print date
# $2 	:	1(stdout) or 2(stderr)
# $3 	:	Level
# $4... :	Messages
#
print_message()
{
	if [ "X$1" = "Xdate" ]; then
		if [ -z "${K2HR3CLI_OPT_NODATE}" ]; then
			_PRINT_DATE=$(date +%FT%T%z)
			_PRINT_DATE="${_PRINT_DATE} "
		else
			_PRINT_DATE=""
		fi
	else
		_PRINT_DATE=""
	fi
	if [ "$2" -eq 2 ]; then
		_PRINT_STDERR=1
	else
		_PRINT_STDERR=0
	fi
	if [ "X$3" = "X" ]; then
		_PRINT_LEVEL=""
	else
		_PRINT_LEVEL="$3 "
	fi
	shift 3

	if [ ${_PRINT_STDERR} -eq 1 ]; then
		echo "${_PRINT_DATE}${_PRINT_LEVEL}$*" 1>&2
	else
		echo "${_PRINT_DATE}${_PRINT_LEVEL}$*"
	fi
}

#
# Message Function(print stdout)
#
# $@ 	:	Messages
#
prn_msg()
{
	if [ ${K2HR3CLI_MSGLEVEL_VALUE} -gt 0 ]; then
		print_message "" 1 "" "$@"
	fi
}

#
# Message Function(print stderr)
#
# $@ 	:	Messages
#
prn_msg_stderr()
{
	if [ ${K2HR3CLI_MSGLEVEL_VALUE} -gt 0 ]; then
		print_message "" 2 "" "$@"
	fi
}

#
# Debug Function(print stdout)
#
# $@ 	:	Messages
#
prn_dbg()
{
	if [ "${K2HR3CLI_MSGLEVEL_VALUE}" -ge 4 ]; then
		if [ -z "${K2HR3CLI_OPT_NOCOLOR}" ]; then
			_TITLE_COLOR_PREFIX="${CREV}"
			_BODY_COLOR_PREFIX=""
			_COLOR_SUFFIX="${CDEF}"
		else
			_TITLE_COLOR_PREFIX=""
			_BODY_COLOR_PREFIX=""
			_COLOR_SUFFIX=""
		fi
		print_message "date" 2 "${_TITLE_COLOR_PREFIX}[DEBUG]${_COLOR_SUFFIX}" "${_BODY_COLOR_PREFIX}${*}${_COLOR_SUFFIX}"
	fi
}

#
# Error/Warning/Information Function(print stderr)
#
# $@ 	:	Messages
#
prn_err()
{
	if [ "${K2HR3CLI_MSGLEVEL_VALUE}" -ge 1 ]; then
		if [ -z "${K2HR3CLI_OPT_NOCOLOR}" ]; then
			_TITLE_COLOR_PREFIX="${CRED}${CREV}"
			_BODY_COLOR_PREFIX="${CRED}"
			_COLOR_SUFFIX="${CDEF}"
		else
			_TITLE_COLOR_PREFIX=""
			_BODY_COLOR_PREFIX=""
			_COLOR_SUFFIX=""
		fi
		print_message "date" 2 "${_TITLE_COLOR_PREFIX}[ERROR]${_COLOR_SUFFIX}" "${_BODY_COLOR_PREFIX}${*}${_COLOR_SUFFIX}"
	fi
}

prn_warn()
{
	if [ "${K2HR3CLI_MSGLEVEL_VALUE}" -ge 2 ]; then
		if [ -z "${K2HR3CLI_OPT_NOCOLOR}" ]; then
			_TITLE_COLOR_PREFIX="${CYEL}${CREV}"
			_BODY_COLOR_PREFIX="${CYEL}"
			_COLOR_SUFFIX="${CDEF}"
		else
			_TITLE_COLOR_PREFIX=""
			_BODY_COLOR_PREFIX=""
			_COLOR_SUFFIX=""
		fi
		print_message "date" 2 "${_TITLE_COLOR_PREFIX}[WARNING]${_COLOR_SUFFIX}" "${_BODY_COLOR_PREFIX}${*}${_COLOR_SUFFIX}"
	fi
}

prn_info()
{
	if [ "${K2HR3CLI_MSGLEVEL_VALUE}" -ge 3 ]; then
		if [ -z "${K2HR3CLI_OPT_NOCOLOR}" ]; then
			_TITLE_COLOR_PREFIX="${CGRN}${CREV}"
			_BODY_COLOR_PREFIX="${CGRN}"
			_COLOR_SUFFIX="${CDEF}"
		else
			_TITLE_COLOR_PREFIX=""
			_BODY_COLOR_PREFIX=""
			_COLOR_SUFFIX=""
		fi
		print_message "date" 2 "${_TITLE_COLOR_PREFIX}[INFO]${_COLOR_SUFFIX}" "${_BODY_COLOR_PREFIX}${*}${_COLOR_SUFFIX}"
	fi
}

#---------------------------------------------------------------------
# Main
#---------------------------------------------------------------------
#
# Escape sequence
#
if [ -t 1 ]; then
	# shellcheck disable=SC2034
	CBLD=$(printf '\033[1m')
	CREV=$(printf '\033[7m')
	CRED=$(printf '\033[31m')
	CYEL=$(printf '\033[33m')
	CGRN=$(printf '\033[32m')
	CDEF=$(printf '\033[0m')
elif [ "X${K2HR3CLI_FORCE_COLOR}" = "X1" ]; then
	# shellcheck disable=SC2034
	CBLD=$(printf '\033[1m')
	CREV=$(printf '\033[7m')
	CRED=$(printf '\033[31m')
	CYEL=$(printf '\033[33m')
	CGRN=$(printf '\033[32m')
	CDEF=$(printf '\033[0m')
else
	# shellcheck disable=SC2034
	CBLD=""
	CREV=""
	CRED=""
	CYEL=""
	CGRN=""
	CDEF=""
fi

#
# Check environments
#
if [ "X${K2HR3CLI_MSGLEVEL}" != "X" ]; then
	set_msglevel "${K2HR3CLI_MSGLEVEL}"
	if [ $? -ne 0 ]; then
		prn_warn "K2HR3CLI_MSGLEVEL environment has unknown value : ${K2HR3CLI_MSGLEVEL}"
	fi
fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
