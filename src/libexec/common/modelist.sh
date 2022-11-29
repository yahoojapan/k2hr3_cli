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
#	LIBEXECDIR		:	indicates the root directory where the K2HR3 CLI
#						subscript is located.
#	COMMON_DIRNAME	:	"common" directory name under libexec
#
# [OUTPUT]
#	K2HR3CLI_MODES	:	k2hr3 mode(command) list
#						this is sub-directory name in libexec.
#

#---------------------------------------------------------------------
# Utilities
#---------------------------------------------------------------------
#
# Find mode string in list
#
# $1:	Mode string
#
check_mode_string()
{
	if [ -z "$1" ]; then
		return 1
	fi

	for _MODELIST_ONE in ${K2HR3CLI_MODES}; do
		if [ -n "${_MODELIST_ONE}" ] && [ "${_MODELIST_ONE}" = "$1" ]; then
			#
			# Found
			#
			return 0
		fi
	done

	#
	# Not Found
	#
	return 1
}

#---------------------------------------------------------------------
# Main
#---------------------------------------------------------------------
K2HR3CLI_MODES=""

if [ ! -d "${LIBEXECDIR}" ]; then
	prn_err "${LIBEXECDIR} is not directory."
	exit 1
fi

#
# Get list of libexec sub-directories
#
_MODELIST_TMP=""
for _MODELIST_ONEDIR in "${LIBEXECDIR}"/*; do
	_MODELIST_ONEDIR=$(pecho -n "${_MODELIST_ONEDIR}" | sed "s#^${LIBEXECDIR}/##g")
	case ${_MODELIST_ONEDIR} in
		"${COMMON_DIRNAME}")
			;;
		*)
			if [ -z "${_MODELIST_TMP}" ]; then
				_MODELIST_TMP=${_MODELIST_ONEDIR}
			else
				_MODELIST_TMP="${_MODELIST_TMP} ${_MODELIST_ONEDIR}"
			fi
			;;
	esac
done

for _MODELIST_ONEDIR in ${_MODELIST_TMP}; do
	if [ ! -d "${LIBEXECDIR}/${_MODELIST_ONEDIR}" ]; then
		#
		# not directory
		#
		continue
	fi

	#
	# Set
	#
	if [ -z "${K2HR3CLI_MODES}" ]; then
		K2HR3CLI_MODES=${_MODELIST_ONEDIR}
	else
		K2HR3CLI_MODES="${K2HR3CLI_MODES} ${_MODELIST_ONEDIR}"
	fi
done

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
