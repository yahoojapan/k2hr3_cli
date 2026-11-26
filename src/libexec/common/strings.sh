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
# Environments and Variables
#---------------------------------------------------------------------
# [NOTE]
# The portability of the echo command (built-in /bin/sh, /bin/echo) is
# an issue.
# So we substitute printf and imitate BSD type echo  in this script.
# But this alternative echo has an option to call the echo command
# itself, so it is here to determine whether the -e option can be
# implemented.
#
_K2HR3_CLI_ECHO_EXP=1
# shellcheck disable=SC2039,SC3037
_K2HR3_CLI_ECHO_TMP=$(echo -e "" | tr -d ' ')
if [ -n "${_K2HR3_CLI_ECHO_TMP}" ] && [ "${_K2HR3_CLI_ECHO_TMP}" = "-e" ]; then
	_K2HR3_CLI_ECHO_EXP=0
fi

#---------------------------------------------------------------------
# Utilities
#---------------------------------------------------------------------
#
# Pseudo echo
#
# $@	: first argument is allowed option('-n' or '-e') and parameters
# $?	: result
#
# [NOTE]
# To avoid portability due to differences in echo commands(/bin/sh built-in,
# /bin/echo, etc.), imitate BSD echo with printf.
#
pecho()
{
	if [ -n "$1" ] && [ "$1" = "-e" ]; then
		shift
		if [ "${_K2HR3_CLI_ECHO_EXP}" -eq 1 ]; then
			# shellcheck disable=SC2039,SC3037
			echo -e "$*"
		else
			echo "$*"
		fi
	elif [ -n "$1" ] && [ "$1" = "-n" ]; then
		shift
		if [ $# -lt 1 ]; then
			printf ''
		else
			printf '%s' "$*"
		fi
	else
		if [ $# -lt 1 ]; then
			printf '\n'
		else
			printf '%s\n' "$*"
		fi
	fi
}

#
# Check string for config variable name
#
# $1		: string(allow empty)
# $?		: result
#
is_safe_config_var_name()
{
	case "$1" in
		'' | [!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_]* | *[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_]*)
			return 1
			;;
		*)
			return 0
			;;
	esac
}

#
# Check string for config variables
#
# $1		: string(allow empty)
# $?		: result
#
is_safe_config_var_value()
{
	case "$1" in
		*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_./:@=+\ -]*)
			return 1
			;;
		*)
			return 0
			;;
	esac
}

#
# Check invalid key and value format(and comment) in configuration file
#
# $1	: file
# $?	: result
#
is_safe_config_file()
{
	if [ -z "$1" ]; then
		# wrong parameter
		return 1
	fi
	if [ ! -e "$1" ] && [ ! -L "$1" ]; then
		# file is not existed
		return 0
	fi
	if [ ! -f "$1" ] || [ -L "$1" ]; then
		# file is not regular file
		return 1
	fi
	_TARGET_CONF_FILE="$1"

	# Loop
	while IFS= read -r _one_line || [ -n "${_one_line}" ]; do
		# trim
		_one_line=$(printf '%s\n' "${_one_line}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

		# skip empty and comment line
		case "${_one_line}" in
			'' | '#'*)	continue ;;
		esac

		# check "=" keyword
		case "${_one_line}" in
			*'='*)	;;
			*)		return 1 ;;
		esac

		# parse key and value
		_key_in_line=$(printf '%s\n' "${_one_line}" | sed 's/=.*$//')
		_val_in_line=$(printf '%s\n' "${_one_line}" | sed 's/^[^=]*=//')

		# check key name
		if ! is_safe_config_var_name "${_key_in_line}"; then
			return 1
		fi

		# cut quate in value
		case "${_val_in_line}" in
			\"*\")
				# cut both edge double quate
				_val_in_line=$(printf '%s\n' "${_val_in_line}" | sed 's/^"//; s/"$//')
				# check double quate in rest value
				case "${_val_in_line}" in
					*\"*) return 1 ;;
				esac
				;;

			\'*\')
				# cut both edge single quate
				_val_in_line=$(printf '%s\n' "${_val_in_line}" | sed "s/^'//; s/'$//")
				# check single quate in rest value
				case "${_val_in_line}" in
					*\'*) return 1 ;;
				esac
				;;
			\"* | *\" | \'* | *\')
				# one quate in value
				return 1
				;;
		esac

		# check rest value
		if ! is_safe_config_var_value "${_val_in_line}"; then
			return 1
		fi
	done < "${_TARGET_CONF_FILE}"

	return 0
}

#
# Cut special words
#
# $1		: string
# Output	: string without back quote
#
cut_special_words()
{
	if [ $# -lt 1 ]; then
		pecho -n ""
	fi
	pecho -n "$@" | sed -e "s/\`//g" -e "s/\!//g" -e "s/\\\$//g" 2>/dev/null
}

#
# String to Upper
#
# $1		: string
# Output	: upper string
#
to_upper()
{
	if [ $# -lt 1 ]; then
		pecho -n ""
	fi
	pecho -n "$@" | tr '[:lower:]' '[:upper:]'
}

#
# String to Lower
#
# $1		: string
# Output	: lower string
#
to_lower()
{
	if [ $# -lt 1 ]; then
		pecho -n ""
	fi
	pecho -n "$@" | tr '[:upper:]' '[:lower:]'
}

#
# Check positive number(with 0)
#
# $1		: string
# $?		: result
#
is_positive_number()
{
	if [ $# -lt 1 ]; then
		return 1
	fi
	_CHECK_NUMBER_TMP=$(pecho -n "$1" | sed -e 's/[.]//g')
	if [ -z "${_CHECK_NUMBER_TMP}" ]; then
		return 0
	fi

	# shellcheck disable=SC2003
	if ! expr "${_CHECK_NUMBER_TMP}" + 1 >/dev/null 2>&1; then
		return 1
	fi
	return 0
}

#
# Check negative number(with 0)
#
# $1		: string
# $?		: result
#
is_negative_number()
{
	if [ $# -lt 1 ]; then
		return 1
	fi
	_CHECK_NUMBER_TMP=$(pecho -n "$1" | sed -e 's/[.]//g')
	if [ -z "${_CHECK_NUMBER_TMP}" ]; then
		return 0
	fi

	#shellcheck disable=SC2003
	if ! expr "${_CHECK_NUMBER_TMP}" - 1 >/dev/null 2>&1; then
		return 1
	fi
	return 0
}

#
# Check null string
#
# $1		: string
# Output	: filter string
#
# [NOTE]
# This function only returns the code of the execution result.
# Note that the caller does not expect to receive the result of
# the data(ex. "pecho -n xxxxx").
#
filter_null_string()
{
	if [ $# -lt 1 ]; then
		pecho -n ""
	fi
	_FILTER_NULL_TMP=$(to_upper "$1")
	if [ -n "${_FILTER_NULL_TMP}" ] && [ "${_FILTER_NULL_TMP}" = "NULL" ]; then
		pecho -n ""
	fi
	pecho -n "$1"
}

#
# Compare Part of String
#
# $1		: string
# $2		: check string
# $3		: no case compareing(1)
# $?		: result
#
# [NOTE]
# This function only returns the code of the execution result.
# Note that the caller does not expect to receive the result of
# the data(ex. "pecho -n xxxxx").
#
compare_part_string()
{
	if [ $# -lt 1 ]; then
		return 1
	fi
	if [ $# -gt 2 ]; then
		if [ -n "$3" ] && [ "$3" = "1" ]; then
			_COMP_PART_STR_TMP=$(to_upper "$1")
			_COMP_PART_STR_CHECK_TMP=$(to_upper "$2")
		else
			_COMP_PART_STR_TMP="$1"
			_COMP_PART_STR_CHECK_TMP="$2"
		fi
	else
		_COMP_PART_STR_TMP="$1"
		_COMP_PART_STR_CHECK_TMP="$2"
	fi
	pecho -n "${_COMP_PART_STR_TMP}" | grep -q "^${_COMP_PART_STR_CHECK_TMP}"
	return $?
}

#
# Url Encode
#
# $1		: string
# Output	: content string
#
k2hr3cli_urlencode()
{
	pecho -n "$1" | sed \
		-e 's:%:%25:g'  \
		-e 's: :%20:g'  \
		-e 's:\!:%21:g' \
		-e 's:":%22:g'  \
		-e 's:#:%23:g'  \
		-e 's:\$:%24:g' \
		-e 's:&:%26:g'  \
		-e "s:':%27:g"  \
		-e 's:(:%28:g'  \
		-e 's:):%29:g'  \
		-e 's:\*:%2A:g' \
		-e 's:+:%2B:g'  \
		-e 's:,:%2C:g'  \
		-e 's:/:%2F:g'  \
		-e 's#:#%3A#g'  \
		-e 's:;:%3B:g'  \
		-e 's:<:%3C:g'  \
		-e 's:=:%3D:g'  \
		-e 's:>:%3E:g'  \
		-e 's:?:%3F:g'  \
		-e 's:@:%40:g'  \
		-e 's:\[:%5B:g' \
		-e 's:\\:%5C:g' \
		-e 's:\]:%5D:g' \
		-e 's:\^:%5E:g' \
		-e 's:`:%60:g'  \
		-e 's:{:%7B:g'  \
		-e 's:|:%7C:g'  \
		-e 's:}:%7D:g'  \
		-e 's:~:%7E:g'  2>/dev/null
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
