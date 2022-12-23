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
# About parser json
#---------------------------------------------------------------------
#
# About JSON analysis result file
#
# This original JSON parser expects a JSON response body returned
# by the API.
# Pass a file containing a common-sense JSON character string(a
# character string is also possible) and create an original
# analysis result file.
# You can use this file to search for keys, dump data, and more.
#
# For example, if there is the following JSON(expanded for easy
# viewing), an example of the output result file is shown:
#
# [Input JSON]
#	{
#		"key1": "val2",
#		"key2": null,
#		"key3": true,
#		"key4": false,
#		"key5": 1234,
#		"key6": {
#			"sub1": "objval1",
#			"sub2": "objval2"
#		},
#		"key7": [
#			"arrval1",
#			"arrval2"
#		]
#	}
#
# [Output JSON analysis result file]
#	%				%OBJ%
#	%"key1"%		%STR%"val2"
#	%"key2"%		%NULL%
#	%"key3"%		%TRUE%
#	%"key4"%		%FALSE%
#	%"key5"%		%NUM%1234
#	%"key6"%		%OBJ%
#	%"key6"%"sub1"%	%STR%"objval1"
#	%"key6"%"sub2"%	%STR%"objval2"
#	%"key7"%		%ARR%
#	%"key7"%1%		%STR%"arrval1"
#	%"key7"%2%		%STR%"arrval2"
#

#---------------------------------------------------------------------
# Environments and Variables
#---------------------------------------------------------------------
#
# Special Environment for debugging
#
JP_LEAVE_PARSED_FILE=0

#
# Variables used in the analysis result file
#
JP_TYPE_OBJ="%OBJ%"
JP_TYPE_ARR="%ARR%"
JP_TYPE_STR="%STR%"
JP_TYPE_NUM="%NUM%"
JP_TYPE_NULL="%NULL%"
JP_TYPE_TRUE="%TRUE%"
JP_TYPE_FALSE="%FALSE%"

#
# The suffix of the file name of the analysis result.
#
_JP_PAERSED_FILE_SUFFIX=0
_JP_PAERSED_FORM_FILE_SUFFIX=0

#---------------------------------------------------------------------
# Low level function
#---------------------------------------------------------------------
# jsonparser_parse_json_element()
#	Parses the passed JSON string and outputs it as a file in the
#	original format.
#	This function is reentrant.
#
# jsonparser_get_json_part()
#	This function gets the JSON string of a specific key from the
#	original format file after JSON parsing.
#
#---------------------------------------------------------------------
# Global function
#---------------------------------------------------------------------
# jsonparser_parse_json_string()
#	Parses the passed JSON string, outputs it as a file in the
#	original format, and returns the file name.
#
# jsonparser_parse_json_file()
#	Parses the JSON file, outputs it as a file in the original format,
#	and returns the file name.
#
# jsonparser_get_key_value()
#	Search for the key from the file in the original format after
#	parsing the JSON.
#	If the searched key is an object, all the key names that the
#	object has are returned. If the searched key is an array, all
#	the subscripts(keys) of that array are returned. Otherwise(number,
#	string, null, Boolean), that value is returned.
#	The character string (key name, value) returns the value enclosed
#	in double quotes.
#	When searching, specify the key from the root in the path format
#	with '%' as the separator. The character strings included in the
#	path are enclosed in double quotes.
#	ex) In the case of "catalog"(object) -> "url"(stging)
#		Search key: '%"catalog"%"url"%' 
#
# jsonparser_dump_parsed_file()
#	Specify the original format file after JSON parsing and Dump
#	the contents.
#
# jsonparser_dump_string()
#	Specify a JSON string to Dump the content.
#

#---------------------------------------------------------------------
# Low Level Functions
#---------------------------------------------------------------------
#
# Parse json string to originnal analysis result file
#
# $1		: json string
# $2		: element path suffix("%...%...%")
# $3		: output file
# $?		: result
# Output	: remaining string
#
# [NOTE]
# See the comments above for the format of the analysis result file.
#
jsonparser_parse_json_element()
{
	if [ $# -lt 3 ]; then
		prn_dbg "(jsonparser_parse_json_element) Parameter is wrong."
		return 1
	fi
	if [ -z "$2" ]; then
		_JP_ELEMENT_PATH="%"
	else
		_JP_ELEMENT_PATH="$2"
	fi
	if [ -z "$3" ]; then
		prn_dbg "(jsonparser_parse_json_element) Output file parameter is empty."
		return 1
	fi
	_JP_ELEMENT_OUTPUT_FILE="$3"

	#
	# Trim left
	#
	_JP_ELEMENT_REMAINING=$(pecho -n "$1" | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g')

	#
	# Check first word for key string
	#
	_JP_ELEMENT_START_WORD=$(pecho -n "${_JP_ELEMENT_REMAINING}" | cut -b 1)
	_JP_ELEMENT_REMAINING=$(pecho -n "${_JP_ELEMENT_REMAINING}" | cut -c 2-)
	if [ -n "${_JP_ELEMENT_START_WORD}" ] && [ "${_JP_ELEMENT_START_WORD}" = "{" ]; then
		#--------------------------------------------------
		# Start Object
		#--------------------------------------------------
		_JP_ELEMENT_CONTENT_STR=""
		_JP_ELEMENT_DOUBLE_QUOTE=0
		_JP_ELEMENT_SQUARE_BRACKETS=1
		_JP_ELEMENT_CURLY_BRACKETS=0

		#
		# Search square brackets for end of object
		#
		while [ -n "${_JP_ELEMENT_REMAINING}" ]; do
			#
			# Search key word("{}[])
			#
			# [NOTE]
			#	awk result : '<key found position> <found key> <string before key> <string after key>'
			#
			_JP_ELEMENT_PARSED_TMP=$(pecho -n "${_JP_ELEMENT_REMAINING}" | awk 'match($0, /[{}\[\]"]/){print RSTART, substr($0, RSTART, 1), "\"" substr($0, 1, RSTART - 1) "\"", "\"" substr($0, RSTART + 1) "\""}')
			if [ -z "${_JP_ELEMENT_PARSED_TMP}" ]; then
				prn_dbg "(jsonparser_parse_json_element) ${_JP_ELEMENT_PATH} path is object, but end word of it is not found."
				return 1
			fi

			_JP_ELEMENT_SEPARATOR_WORD=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $2}')
			_JP_ELEMENT_CONTENT_TMP=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $3}' | sed -e 's/^"//g' -e 's/\"$//g')
			_JP_ELEMENT_REMAINING=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $4}' | sed -e 's/^"//g' -e 's/\"$//g')

			if [ "${_JP_ELEMENT_DOUBLE_QUOTE}" -eq 1 ]; then
				if [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "\"" ]; then
					_JP_ELEMENT_DOUBLE_QUOTE=0
				fi
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "\"" ]; then
				_JP_ELEMENT_DOUBLE_QUOTE=1
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "{" ]; then
				_JP_ELEMENT_SQUARE_BRACKETS=$((_JP_ELEMENT_SQUARE_BRACKETS + 1))
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "}" ]; then
				_JP_ELEMENT_SQUARE_BRACKETS=$((_JP_ELEMENT_SQUARE_BRACKETS - 1))
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "[" ]; then
				_JP_ELEMENT_CURLY_BRACKETS=$((_JP_ELEMENT_CURLY_BRACKETS + 1))
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "]" ]; then
				_JP_ELEMENT_CURLY_BRACKETS=$((_JP_ELEMENT_CURLY_BRACKETS - 1))
			fi

			_JP_ELEMENT_CONTENT_STR="${_JP_ELEMENT_CONTENT_STR}${_JP_ELEMENT_CONTENT_TMP}"

			if [ "${_JP_ELEMENT_DOUBLE_QUOTE}" -eq 0 ] && [ "${_JP_ELEMENT_SQUARE_BRACKETS}" -eq 0 ] && [ "${_JP_ELEMENT_CURLY_BRACKETS}" -eq 0 ]; then
				#
				# Found end of object
				#
				break
			fi
			_JP_ELEMENT_CONTENT_STR="${_JP_ELEMENT_CONTENT_STR}${_JP_ELEMENT_SEPARATOR_WORD}"

		done

		#
		# Put file
		#
		if ! pecho "${_JP_ELEMENT_PATH}	${JP_TYPE_OBJ}" >> "${_JP_ELEMENT_OUTPUT_FILE}"; then
			prn_dbg "(jsonparser_parse_json_element) Failed to put ${_JP_ELEMENT_PATH} path to file(${_JP_ELEMENT_OUTPUT_FILE})."
			return 1
		fi

		#
		# Children elements( "key":value, ... )
		#
		_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g')
		while [ -n "${_JP_ELEMENT_CONTENT_STR}" ]; do
			#
			# key must be string
			#
			_JP_ELEMENT_START_WORD=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | cut -b 1)
			if [ -z "${_JP_ELEMENT_START_WORD}" ] || [ "${_JP_ELEMENT_START_WORD}" != "\"" ]; then
				prn_dbg "(jsonparser_parse_json_element) The key of ${_JP_ELEMENT_PATH} path object child is wrong."
				return 1
			fi

			#
			# Search separator(") for end of key
			#
			# [NOTE]
			#	_JP_ELEMENT_KEY_STR	: 		'"<string of before separator>"'			<--- with double quote
			#	_JP_ELEMENT_CONTENT_STR	:	'<remaining string(after separator)>'
			#
			_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | cut -c 2-)
			_JP_ELEMENT_KEY_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | awk 'match($0, /["]/){print "\"" substr($0, 1, RSTART)}')
			if [ -z "${_JP_ELEMENT_KEY_STR}" ]; then
				prn_dbg "(jsonparser_parse_json_element) The key of ${_JP_ELEMENT_PATH} path object child is wrong."
				return 1
			fi
			_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | awk 'match($0, /["]/){print substr($0, RSTART + 1)}' | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g')

			#
			# Check separator between key and value
			#
			_JP_ELEMENT_START_WORD=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | cut -b 1)
			if [ -z "${_JP_ELEMENT_START_WORD}" ] || [ "${_JP_ELEMENT_START_WORD}" != ":" ]; then
				prn_dbg "(jsonparser_parse_json_element) The key of ${_JP_ELEMENT_PATH} path object child has wrong separator(:)."
				return 1
			fi

			_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | cut -c 2- | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g')
			if [ -z "${_JP_ELEMENT_CONTENT_STR}" ]; then
				prn_dbg "(jsonparser_parse_json_element) The key of ${_JP_ELEMENT_PATH} path object child has empty value."
				return 1
			fi

			#
			# Make element path for child
			#
			_JP_ELEMENT_CHILD_PATH="${_JP_ELEMENT_PATH}${_JP_ELEMENT_KEY_STR}%"

			#
			# Call ownself as a Reentrant for child element
			#
			# [NOTE]
			# Call as a subshell to keep local variables unchanged.
			#
			if ! _JP_ELEMENT_CONTENT_STR=$(jsonparser_parse_json_element "${_JP_ELEMENT_CONTENT_STR}" "${_JP_ELEMENT_CHILD_PATH}" "${_JP_ELEMENT_OUTPUT_FILE}"); then
				prn_dbg "(jsonparser_parse_json_element) Failed to parse ${_JP_ELEMENT_CHILD_PATH} value."
				return 1
			fi

			#
			# Trim left
			#
			_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | sed -e 's/^[[:space:]]*[,][[:space:]]*//g' -e 's/^\(%20\)*[,]\(%20\)*//g' -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g')
		done

	elif [ -n "${_JP_ELEMENT_START_WORD}" ] && [ "${_JP_ELEMENT_START_WORD}" = "[" ]; then
		#--------------------------------------------------
		# Start Array
		#--------------------------------------------------
		_JP_ELEMENT_CONTENT_STR=""
		_JP_ELEMENT_DOUBLE_QUOTE=0
		_JP_ELEMENT_SQUARE_BRACKETS=0
		_JP_ELEMENT_CURLY_BRACKETS=1

		#
		# Search square brackets for end of array
		#
		while [ -n "${_JP_ELEMENT_REMAINING}" ]; do
			#
			# Search key word("{}[])
			#
			# [NOTE]
			#	awk result : '<key found position> <found key> <string before key> <string after key>'
			#
			_JP_ELEMENT_PARSED_TMP=$(pecho -n "${_JP_ELEMENT_REMAINING}" | awk 'match($0, /[{}\[\]"]/){print RSTART, substr($0, RSTART, 1), "\"" substr($0, 1, RSTART - 1) "\"", "\"" substr($0, RSTART + 1) "\""}')
			if [ -z "${_JP_ELEMENT_PARSED_TMP}" ]; then
				prn_dbg "(jsonparser_parse_json_element) ${_JP_ELEMENT_PATH} path is array, but end word of it is not found."
				return 1
			fi

			_JP_ELEMENT_SEPARATOR_WORD=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $2}')
			_JP_ELEMENT_CONTENT_TMP=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $3}' | sed -e 's/^"//g' -e 's/\"$//g')
			_JP_ELEMENT_REMAINING=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $4}' | sed -e 's/^"//g' -e 's/\"$//g')

			if [ "${_JP_ELEMENT_DOUBLE_QUOTE}" -eq 1 ]; then
				if [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "\"" ]; then
					_JP_ELEMENT_DOUBLE_QUOTE=0
				fi
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "\"" ]; then
				_JP_ELEMENT_DOUBLE_QUOTE=1
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "{" ]; then
				_JP_ELEMENT_SQUARE_BRACKETS=$((_JP_ELEMENT_SQUARE_BRACKETS + 1))
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "}" ]; then
				_JP_ELEMENT_SQUARE_BRACKETS=$((_JP_ELEMENT_SQUARE_BRACKETS - 1))
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "[" ]; then
				_JP_ELEMENT_CURLY_BRACKETS=$((_JP_ELEMENT_CURLY_BRACKETS + 1))
			elif [ -n "${_JP_ELEMENT_SEPARATOR_WORD}" ] && [ "${_JP_ELEMENT_SEPARATOR_WORD}" = "]" ]; then
				_JP_ELEMENT_CURLY_BRACKETS=$((_JP_ELEMENT_CURLY_BRACKETS - 1))
			fi

			_JP_ELEMENT_CONTENT_STR="${_JP_ELEMENT_CONTENT_STR}${_JP_ELEMENT_CONTENT_TMP}"

			if [ "${_JP_ELEMENT_DOUBLE_QUOTE}" -eq 0 ] && [ "${_JP_ELEMENT_SQUARE_BRACKETS}" -eq 0 ] && [ "${_JP_ELEMENT_CURLY_BRACKETS}" -eq 0 ]; then
				#
				# Found end of array
				#
				break
			fi

			_JP_ELEMENT_CONTENT_STR="${_JP_ELEMENT_CONTENT_STR}${_JP_ELEMENT_SEPARATOR_WORD}"
		done

		#
		# Put file
		#
		if ! pecho "${_JP_ELEMENT_PATH}	${JP_TYPE_ARR}" >> "${_JP_ELEMENT_OUTPUT_FILE}"; then
			prn_dbg "(jsonparser_parse_json_element) Failed to put ${_JP_ELEMENT_PATH} path to file(${_JP_ELEMENT_OUTPUT_FILE})."
			return 1
		fi

		#
		# Children elements( value, ... )
		#
		_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g')
		_JP_ELEMENT_CONTENT_ARR_NUM=1
		while [ -n "${_JP_ELEMENT_CONTENT_STR}" ]; do
			#
			# Make element path for child
			#
			_JP_ELEMENT_CHILD_PATH="${_JP_ELEMENT_PATH}${_JP_ELEMENT_CONTENT_ARR_NUM}%"

			#
			# Call ownself as a Reentrant for child element
			#
			# [NOTE]
			# Call as a subshell to keep local variables unchanged.
			#
			if ! _JP_ELEMENT_CONTENT_STR=$(jsonparser_parse_json_element "${_JP_ELEMENT_CONTENT_STR}" "${_JP_ELEMENT_CHILD_PATH}" "${_JP_ELEMENT_OUTPUT_FILE}"); then
				prn_dbg "(jsonparser_parse_json_element) Failed to parse ${_JP_ELEMENT_CHILD_PATH} value."
				return 1
			fi

			#
			# Trim left / Counter up
			#
			_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_CONTENT_STR}" | sed -e 's/^[[:space:]]*[,][[:space:]]*//g' -e 's/^\(%20\)*[,]\(%20\)*//g' -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g')
			_JP_ELEMENT_CONTENT_ARR_NUM=$((_JP_ELEMENT_CONTENT_ARR_NUM + 1))
		done

	elif [ -n "${_JP_ELEMENT_START_WORD}" ] && [ "${_JP_ELEMENT_START_WORD}" = "\"" ]; then
		#--------------------------------------------------
		# Start String
		#--------------------------------------------------
		#
		# Search separator(") for end of variable
		#
		# [NOTE]
		#	_JP_ELEMENT_CONTENT_STR	: '"<string of before separator>"'			<--- with double quote
		#	_JP_ELEMENT_REMAINING	: '<remaining string(after separator)>'
		#
		_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_REMAINING}" | awk 'match($0, /["]/){print "\"" substr($0, 1, RSTART)}')
		if [ -z "${_JP_ELEMENT_CONTENT_STR}" ]; then
			prn_dbg "(jsonparser_parse_json_element) ${_JP_ELEMENT_PATH} path is string, but end word of it is not found."
			return 1
		fi
		_JP_ELEMENT_REMAINING=$(pecho -n "${_JP_ELEMENT_REMAINING}" | awk 'match($0, /["]/){print substr($0, RSTART + 1)}')

		#
		# Put file
		#
		if ! pecho "${_JP_ELEMENT_PATH}	${JP_TYPE_STR}${_JP_ELEMENT_CONTENT_STR}" >> "${_JP_ELEMENT_OUTPUT_FILE}"; then
			prn_dbg "(jsonparser_parse_json_element) Failed to put ${_JP_ELEMENT_PATH} path to file(${_JP_ELEMENT_OUTPUT_FILE})."
			return 1
		fi

	else
		#--------------------------------------------------
		# Start null / boolean(true/false) / number
		#--------------------------------------------------
		#
		# Search separator(, or ] or }) for end of variable
		#
		# [NOTE]
		#	result of following awk comand : "<found word position> <found separator word> <string of before separator> <string of after separator>"
		#
		_JP_ELEMENT_PARSED_TMP=$(pecho -n "${_JP_ELEMENT_REMAINING}" | awk 'match($0, /[,}\]]/){print RSTART, substr($0, RSTART, 1), "\"" substr($0, 1, RSTART - 1) "\"", "\"" substr($0, RSTART + 1) "\""}')
		if [ -z "${_JP_ELEMENT_PARSED_TMP}" ]; then
			_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_START_WORD}${_JP_ELEMENT_REMAINING}" | tr '[:upper:]' '[:lower:]')
			_JP_ELEMENT_REMAINING=""
		else
			_JP_ELEMENT_REMAINING=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $4}' | sed -e 's/^"//g' -e 's/\"$//g')
			_JP_ELEMENT_PARSED_TMP=$(pecho -n "${_JP_ELEMENT_PARSED_TMP}" | awk '{print $3}' | sed -e 's/^"//g' -e 's/\"$//g')
			_JP_ELEMENT_CONTENT_STR=$(pecho -n "${_JP_ELEMENT_START_WORD}${_JP_ELEMENT_PARSED_TMP}" | tr '[:upper:]' '[:lower:]')
		fi

		#
		# Check and Put file
		#
		if [ -n "${_JP_ELEMENT_CONTENT_STR}" ] && [ "${_JP_ELEMENT_CONTENT_STR}" = "null" ]; then
			if ! pecho "${_JP_ELEMENT_PATH}	${JP_TYPE_NULL}" >> "${_JP_ELEMENT_OUTPUT_FILE}"; then
				prn_dbg "(jsonparser_parse_json_element) Failed to put ${_JP_ELEMENT_PATH} path to file(${_JP_ELEMENT_OUTPUT_FILE})."
				return 1
			fi

		elif [ -n "${_JP_ELEMENT_CONTENT_STR}" ] && [ "${_JP_ELEMENT_CONTENT_STR}" = "true" ]; then
			if ! pecho "${_JP_ELEMENT_PATH}	${JP_TYPE_TRUE}" >> "${_JP_ELEMENT_OUTPUT_FILE}"; then
				prn_dbg "(jsonparser_parse_json_element) Failed to put ${_JP_ELEMENT_PATH} path to file(${_JP_ELEMENT_OUTPUT_FILE})."
				return 1
			fi

		elif [ -n "${_JP_ELEMENT_CONTENT_STR}" ] && [ "${_JP_ELEMENT_CONTENT_STR}" = "false" ]; then
			if ! pecho "${_JP_ELEMENT_PATH}	${JP_TYPE_FALSE}" >> "${_JP_ELEMENT_OUTPUT_FILE}"; then
				prn_dbg "(jsonparser_parse_json_element) Failed to put ${_JP_ELEMENT_PATH} path to file(${_JP_ELEMENT_OUTPUT_FILE})."
				return 1
			fi

		else
			#
			# Check number
			#
			if [ -n "${_JP_ELEMENT_START_WORD}" ] && [ "${_JP_ELEMENT_START_WORD}" = "-" ]; then
				#
				# Check negative word
				#
				if ! is_negative_number "${_JP_ELEMENT_CONTENT_STR}"; then
					prn_dbg "(jsonparser_parse_json_element) ${_JP_ELEMENT_PATH} path is unknown value."
					return 1
				fi
			else
				#
				# Check positive word
				#
				if ! is_positive_number "${_JP_ELEMENT_CONTENT_STR}"; then
					prn_dbg "(jsonparser_parse_json_element) ${_JP_ELEMENT_PATH} path is unknown value."
					return 1
				fi
			fi

			#
			# Put file
			#
			if ! pecho "${_JP_ELEMENT_PATH}	${JP_TYPE_NUM}${_JP_ELEMENT_CONTENT_STR}" >> "${_JP_ELEMENT_OUTPUT_FILE}"; then
				prn_dbg "(jsonparser_parse_json_element) Failed to put ${_JP_ELEMENT_PATH} path to file(${_JP_ELEMENT_OUTPUT_FILE})."
				return 1
			fi
		fi
	fi

	#
	# Put remaning string
	#
	pecho -n "${_JP_ELEMENT_REMAINING}"

	return 0
}

#
# Get json part
#
# $1	: key path
# $2	: key name
# $3	: parsed json file
# $4	: nest level(0...)
# $5	: single line(1)
# $6	: output file
# $?	: result
#
jsonparser_get_json_part()
{
	if [ $# -lt 6 ]; then
		prn_dbg "(jsonparser_get_json_part) Parameter is wrong."
		return 1
	fi

	#
	# Check key path and name parameter
	#
	if [ -z "$1" ]; then
		_JP_GET_JSON_PATH=""
	else
		_JP_GET_JSON_PATH="$1"
	fi
	if [ -z "$2" ]; then
		_JP_GET_JSON_KEY=""
	else
		_JP_GET_JSON_KEY="$2"
	fi
	_JP_GET_JSON_OWN_PATH="${_JP_GET_JSON_PATH}${_JP_GET_JSON_KEY}%"

	#
	# Check parsed file
	#
	if [ -z "$3" ]; then
		prn_dbg "(jsonparser_get_json_part) Json parsed file path is empty."
		return 1
	fi
	if [ ! -f "$3" ]; then
		prn_dbg "(jsonparser_get_json_part) Json parsed file is not existed."
		return 1
	fi
	_JP_GET_JSON_PARSED_FILE="$3"

	#
	# Check nest parameter
	#
	if [ -n "$4" ]; then
		_JP_GET_JSON_NEST="$4"
		_JP_GET_JSON_CHILD_NEST=$((_JP_GET_JSON_NEST + 1))
	else
		_JP_GET_JSON_NEST=0
		_JP_GET_JSON_CHILD_NEST=1
	fi

	#
	# Check mutiline
	#
	if [ -n "$5" ] && [ "$5" = "1" ]; then
		_JP_GET_JSON_SINGLE_LINE=1
		_JP_GET_JSON_KEYVAL_SEP=""
		_JP_GET_JSON_NEST_WORDS=""
		_JP_GET_JSON_CHILD_NEST_WORDS=""
	elif [ -z "${K2HR3CLI_OPT_JSON}" ] || [ "${K2HR3CLI_OPT_JSON}" != "1" ]; then
		_JP_GET_JSON_SINGLE_LINE=1
		_JP_GET_JSON_KEYVAL_SEP=""
		_JP_GET_JSON_NEST_WORDS=""
		_JP_GET_JSON_CHILD_NEST_WORDS=""
	else
		_JP_GET_JSON_SINGLE_LINE=0
		_JP_GET_JSON_KEYVAL_SEP=" "
		_JP_GET_JSON_NEST_WORDS=""
		for _JP_GET_JSON_NEST_CNT in $(seq 1 "${_JP_GET_JSON_NEST}"); do
			_JP_GET_JSON_NEST_WORDS="${_JP_GET_JSON_NEST_WORDS}    "
		done
		_JP_GET_JSON_CHILD_NEST_WORDS="${_JP_GET_JSON_NEST_WORDS}    "
	fi

	#
	# Check output file path
	#
	if [ -z "$6" ]; then
		prn_dbg "(jsonparser_get_json_part) Output file parameter is empty."
		return 1
	fi

	#
	# Get key value
	#
	if ! jsonparser_get_key_value "${_JP_GET_JSON_OWN_PATH}" "${_JP_GET_JSON_PARSED_FILE}"; then
		prn_dbg "(jsonparser_get_json_part) Could not get key($1)."
		return 1
	fi

	#
	# Dump
	#
	if [ -z "${JSONPARSER_FIND_VAL_TYPE}" ]; then
		prn_dbg "(jsonparser_get_json_part) Json parsed file($2) is something wrong(empty)."
		return 1

	elif [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_OBJ}" ]; then
		#
		# Object
		#
		pecho -n "{" >> "$6"

		_JP_GET_JSON_HAS_CHILD=0
		for _JP_GET_JSON_CHILD_OBJ_NAME in ${JSONPARSER_FIND_KEY_VAL}; do
			if [ "${_JP_GET_JSON_HAS_CHILD}" -eq 0 ]; then
				_JP_GET_JSON_HAS_CHILD=1
			else
				pecho -n ',' >> "$6"
			fi
			if [ "${_JP_GET_JSON_SINGLE_LINE}" -ne 1 ]; then
				pecho "" >> "$6"
			fi
			_JP_GET_JSON_CHILD_OBJ_NAME_RAW=$(pecho -n "${_JP_GET_JSON_CHILD_OBJ_NAME}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
			pecho -n "${_JP_GET_JSON_CHILD_NEST_WORDS}${_JP_GET_JSON_CHILD_OBJ_NAME_RAW}:${_JP_GET_JSON_KEYVAL_SEP}" >> "$6"

			#
			# Call ownself as a Reentrant for child element
			#
			(jsonparser_get_json_part "${_JP_GET_JSON_OWN_PATH}" "${_JP_GET_JSON_CHILD_OBJ_NAME_RAW}" "${_JP_GET_JSON_PARSED_FILE}" "${_JP_GET_JSON_CHILD_NEST}" "$5" "$6")

		done

		if [ "${_JP_GET_JSON_HAS_CHILD}" -ne 0 ]; then
			if [ "${_JP_GET_JSON_SINGLE_LINE}" -ne 1 ]; then
				pecho "" >> "$6"
			fi
			pecho -n "${_JP_GET_JSON_NEST_WORDS}" >> "$6"
		fi
		pecho -n "}" >> "$6"

	elif [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_ARR}" ]; then
		#
		# Array
		#
		pecho -n "[" >> "$6"

		_JP_GET_JSON_HAS_CHILD=0
		for _JP_GET_JSON_CHILD_ARR_NAME in ${JSONPARSER_FIND_KEY_VAL}; do
			if [ "${_JP_GET_JSON_HAS_CHILD}" -eq 0 ]; then
				_JP_GET_JSON_HAS_CHILD=1
			else
				pecho -n ',' >> "$6"
			fi
			if [ "${_JP_GET_JSON_SINGLE_LINE}" -ne 1 ]; then
				pecho "" >> "$6"
			fi

			_JP_GET_JSON_CHILD_ARR_NAME_RAW=$(pecho -n "${_JP_GET_JSON_CHILD_ARR_NAME}" | sed -e 's/\([^\\]\)\\s/\1 /g' -e 's/\\\\/\\/g')
			pecho -n "${_JP_GET_JSON_CHILD_NEST_WORDS}" >> "$6"

			#
			# Call ownself as a Reentrant for child element
			#
			(jsonparser_get_json_part "${_JP_GET_JSON_OWN_PATH}" "${_JP_GET_JSON_CHILD_ARR_NAME_RAW}" "${_JP_GET_JSON_PARSED_FILE}" "${_JP_GET_JSON_CHILD_NEST}" "$5" "$6")

		done

		if [ "${_JP_GET_JSON_HAS_CHILD}" -ne 0 ]; then
			if [ "${_JP_GET_JSON_SINGLE_LINE}" -ne 1 ]; then
				pecho "" >> "$6"
			fi
			pecho -n "${_JP_GET_JSON_NEST_WORDS}" >> "$6"
		fi
		pecho -n "]" >> "$6"

	elif [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_STR}" ] || [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_NUM}" ] || [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_NULL}" ] || [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_TRUE}" ] || [ "${JSONPARSER_FIND_VAL_TYPE}" = "${JP_TYPE_FALSE}" ]; then
		#
		# String / Number / null / boolean(true/false)
		#
		pecho -n "${JSONPARSER_FIND_VAL}" >> "$6"

	else
		prn_dbg "(jsonparser_get_json_part) Json parsed file($2) is something wrong(unknown value type)."
		return 1
	fi

	return 0
}

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------
#
# Parse json string
#
# $1				: json string
# $?				: result
# Output
#	JP_PAERSED_FILE	: the result file path
#
jsonparser_parse_json_string()
{
	JP_PAERSED_FILE=""

	if [ $# -lt 1 ]; then
		prn_dbg "(jsonparser_parse_json_string) Parameter is wrong."
		return 1
	fi

	#
	# Make file path
	#
	_JP_PAERSED_FILE_TMP=""
	while [ -z "${_JP_PAERSED_FILE_TMP}" ]; do
		_JP_PAERSED_FILE_SUFFIX=$((_JP_PAERSED_FILE_SUFFIX + 1))
		_JP_PAERSED_FILE_TMP="/tmp/.k2hr3_parse_json_$$_${_JP_PAERSED_FILE_SUFFIX}.tmp"
		if [ -f "${_JP_PAERSED_FILE_TMP}" ]; then
			_JP_PAERSED_FILE_TMP=""
		fi
	done

	# Escape JSON
	#
	# Converts certain characters like urlencode when loading.
	# This is a challenge character when parsing a JSON string.
	# The converted characters will be restored when parsing is completed.
	#
	# [NOTE]
	# Follow the steps below to convert characters and load like urlencode.
	# (It is assumed that line feed code('\n', '\r') have already been eliminated)
	#	1) '%'				<-> '%25'
	#	2) ' '				<-> '%20'
	#	3) '\n'(two words)	<-> '%25%6e'
	#	4) '\"'(two words)	<-> '%25%22'
	#	5) '\\'(two words)	<-> '%25%5c'
	#
	_JP_PAERSED_ESCAPED_JSON=$(pecho -n "$1" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/\\n/%25%6e/g' -e 's/\\"/%25%22/g' -e 's/\\\\/%25%5c/g')

	#
	# Case for Empty string
	#
	if [ -z "${_JP_PAERSED_ESCAPED_JSON}" ]; then
		touch "${_JP_PAERSED_FILE_TMP}"
		JP_PAERSED_FILE=${_JP_PAERSED_FILE_TMP}
		return 0
	fi

	if ! _JP_PARSE_REMAINING_STR=$(jsonparser_parse_json_element "${_JP_PAERSED_ESCAPED_JSON}" "%" "${_JP_PAERSED_FILE_TMP}"); then
		prn_dbg "(jsonparser_parse_json_string) Failed to parse json string."
		rm -f "${_JP_PAERSED_FILE_TMP}"
		return 1
	fi
	if [ -n "${_JP_PARSE_REMAINING_STR}" ]; then
		_JP_PARSE_REMAINING_STR=$(pecho -n "${_JP_PARSE_REMAINING_STR}" | tr -d '\n' | sed 's/[[:space:]]//g')
		if [ -n "${_JP_PARSE_REMAINING_STR}" ]; then
			prn_dbg "(jsonparser_parse_json_string) After the JSON string has been parsed. It still remains(${_JP_PARSE_REMAINING_STR})"
			rm -f "${_JP_PAERSED_FILE_TMP}"
			return 1
		fi
	fi

	JP_PAERSED_FILE=${_JP_PAERSED_FILE_TMP}
	return 0
}

#
# Parse json file
#
# $1				: input file(json file)
# $?				: result
# Output
#	JP_PAERSED_FILE	: the result file path
#
jsonparser_parse_json_file()
{
	JP_PAERSED_FILE=""

	if [ $# -lt 1 ]; then
		prn_dbg "(jsonparser_parse_json_file) Parameter is wrong."
		return 1
	fi
	if [ ! -f "$1" ]; then
		prn_dbg "(jsonparser_parse_json_file) Input file($1) is not existed."
		return 1
	fi

	# Load JSON file
	#
	# Cut '\n' and '\r'
	#
	_JP_PAERSED_BASE_ALL=$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g' -e 's/\r//g' "$1")

	jsonparser_parse_json_string "${_JP_PAERSED_BASE_ALL}"
	return $?
}

#
# Search key and get value in parsed json file
#
# $1	: key string(key path)
# $2	: parsed json file
# $?	: result
# Output Variable
#	JSONPARSER_FIND_VAL			: in the case of object and array, the subkey name (partial path) is returned, otherwise the value is returned.
#								  For strings, returns the value enclosed in double quotes.
#	JSONPARSER_FIND_STR_VAL		: This value is set only for strings, and the value is set without double quotes.
#	JSONPARSER_FIND_KEY_VAL		: For objects and arrays, what is found is the key name of the element, and the value of which is set in JSONPARSER_FIND_VAL.
#								  However, to avoid the problem of keynames containing spaces, then the words in it are converted  '\' ->'\\' and ' ' -> '\s' in this buffer.
#	JSONPARSER_FIND_VAL_TYPE	: 
#
# [NOTE]
# Check the above description for the path.
# Search with a hierarchical key string using the '%' character as a separator.
#
jsonparser_get_key_value()
{
	JSONPARSER_FIND_VAL=
	JSONPARSER_FIND_STR_VAL=
	JSONPARSER_FIND_KEY_VAL=
	JSONPARSER_FIND_VAL_TYPE=

	if [ $# -lt 2 ]; then
		prn_dbg "(jsonparser_get_key_value) Parameter is wrong."
		return 1
	fi
	if [ ! -f "$2" ]; then
		prn_dbg "(jsonparser_get_key_value) Json parsed file is not existed."
		return 1
	fi
	_JP_FIND_ESCAPED_KEY=$(pecho -n "$1" | sed -e 's#/#\\/#g')

	#
	# Search key
	#
	_JP_FIND_VAL_TMP=$(sed -e 's/%25%5c/\\\\/g' -e 's/%25%22/\\"/g' -e 's/%25%6e/\\n/g' -e 's/%20/ /g' -e 's/%25/%/g' "$2" | grep "^$1[[:space:]]" | sed -e "s/^${_JP_FIND_ESCAPED_KEY}[[:space:]]\+//g" | tr -d '\n')
	if [ -z "${_JP_FIND_VAL_TMP}" ]; then
		prn_dbg "(jsonparser_get_key_value) Not found \"$1\" key in Json parsed file($2)."
		return 1
	fi

	#
	# Parse type and value
	#
	_JP_FIND_VAL_TYPE_TMP=$(pecho -n "${_JP_FIND_VAL_TMP}" | sed 's/^%\([^%]*\)%.*$/%\1%/g')

	if [ -z "${_JP_FIND_VAL_TYPE_TMP}" ]; then
		prn_dbg "(jsonparser_get_key_value) Json parsed file($2) is something wrong(empty)."
		return 1

	elif [ "${_JP_FIND_VAL_TYPE_TMP}" = "${JP_TYPE_OBJ}" ]; then
		#
		# Return key name(after search key) list
		#
		# Each string is in a double-quoted state and the sparator is space charactor between strings.
		#
		_JP_FIND_VAL_TMP=$(sed -e 's/%25%5c/\\\\/g' -e 's/%25%22/\\"/g' -e 's/%25%6e/\\n/g' -e 's/%20/ /g' -e 's/%25/%/g' "$2" | grep "^$1\"[^%]*\"%[[:space:]]\+" | sed -e "s/^${_JP_FIND_ESCAPED_KEY}\"\([^%]*\)\"%.*$/\"\1\"/g" | tr '\n' ' ' | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g' -e 's/[[:space:]]*$//g' -e 's/\(%20\)*$//g')
		JSONPARSER_FIND_KEY_VAL=$(sed -e 's/%25%5c/\\\\/g' -e 's/%25%22/\\"/g' -e 's/%25%6e/\\n/g' -e 's/%20/ /g' -e 's/%25/%/g' "$2" | grep "^$1\"[^%]*\"%[[:space:]]\+" | sed -e "s/^${_JP_FIND_ESCAPED_KEY}\"\([^%]*\)\"%.*$/\"\1\"/g" -e 's/\\/\\\\/g' -e 's/ /\\s/g' | tr '\n' ' ' | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g' -e 's/[[:space:]]*$//g' -e 's/\(%20\)*$//g')

	elif [ "${_JP_FIND_VAL_TYPE_TMP}" = "${JP_TYPE_ARR}" ]; then
		#
		# Return all array key name(after search key) list
		#
		# Each key name is number
		#
		_JP_FIND_VAL_TMP=$(sed -e 's/%25%5c/\\\\/g' -e 's/%25%22/\\"/g' -e 's/%25%6e/\\n/g' -e 's/%20/ /g' -e 's/%25/%/g' "$2" | grep "^$1[0-9]\+%[[:space:]]\+" | sed -e "s/^${_JP_FIND_ESCAPED_KEY}\([0-9]\+\)%.*$/\1/g" | tr '\n' ' ' | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g' -e 's/[[:space:]]*$//g' -e 's/\(%20\)*$//g')
		JSONPARSER_FIND_KEY_VAL=$(sed -e 's/%25%5c/\\\\/g' -e 's/%25%22/\\"/g' -e 's/%25%6e/\\n/g' -e 's/%20/ /g' -e 's/%25/%/g' "$2" | grep "^$1[0-9]\+%[[:space:]]\+" | sed -e "s/^${_JP_FIND_ESCAPED_KEY}\([0-9]\+\)%.*$/\1/g" -e 's/\\/\\\\/g' -e 's/ /\\s/g' | tr '\n' ' ' | sed -e 's/^[[:space:]]*//g' -e 's/^\(%20\)*//g' -e 's/[[:space:]]*$//g' -e 's/\(%20\)*$//g')

	elif [ "${_JP_FIND_VAL_TYPE_TMP}" = "${JP_TYPE_STR}" ]; then
		# [NOTE]
		# The string is returned in a double-quoted state. It is needed space charactor at head and tail.
		#
		_JP_FIND_VAL_TMP=$(pecho -n "${_JP_FIND_VAL_TMP}" | sed -e "s/^${JP_TYPE_STR}//g" )
		JSONPARSER_FIND_STR_VAL=$(pecho -n "${_JP_FIND_VAL_TMP}" | sed -e 's/^"//g' -e 's/"$//g')
	elif [ "${_JP_FIND_VAL_TYPE_TMP}" = "${JP_TYPE_NUM}" ]; then
		_JP_FIND_VAL_TMP=$(pecho -n "${_JP_FIND_VAL_TMP}" | sed -e "s/^${JP_TYPE_NUM}//g" )
	elif [ "${_JP_FIND_VAL_TYPE_TMP}" = "${JP_TYPE_NULL}" ]; then
		_JP_FIND_VAL_TMP="null"
	elif [ "${_JP_FIND_VAL_TYPE_TMP}" = "${JP_TYPE_TRUE}" ]; then
		_JP_FIND_VAL_TMP="true"
	elif [ "${_JP_FIND_VAL_TYPE_TMP}" = "${JP_TYPE_FALSE}" ]; then
		_JP_FIND_VAL_TMP="false"
	else
		prn_dbg "(jsonparser_get_key_value) Json parsed file($2) is something wrong(unknown value type)."
		return 1
	fi

	JSONPARSER_FIND_VAL=${_JP_FIND_VAL_TMP}
	JSONPARSER_FIND_VAL_TYPE=${_JP_FIND_VAL_TYPE_TMP}

	return 0
}

#
# Dump parsed file
#
# $1	: json parsed file
# $2	: single line(1)
# $?	: result
#
jsonparser_dump_parsed_file()
{
	if [ $# -lt 1 ]; then
		prn_dbg "(jsonparser_dump_parsed_file) Paramter is wrong."
		return 1
	fi
	if [ ! -f "$1" ]; then
		prn_dbg "(jsonparser_dump_parsed_file) File paramter is wrong."
		return 1
	fi
	if [ -n "$2" ] && [ "$2" = "1" ]; then
		_JP_DUMP_SINGLE_LINE=1
	else
		_JP_DUMP_SINGLE_LINE=0
	fi

	#
	# Make temporary file
	#
	_JP_PAERSED_FORM_FILE=""
	while [ -z "${_JP_PAERSED_FORM_FILE}" ]; do
		_JP_PAERSED_FORM_FILE_SUFFIX=$((_JP_PAERSED_FORM_FILE_SUFFIX + 1))
		_JP_PAERSED_FORM_FILE="/tmp/.k2hr3_parse_json_sub_$$_${_JP_PAERSED_FORM_FILE_SUFFIX}.tmp"
		if [ -f "${_JP_PAERSED_FORM_FILE}" ]; then
			_JP_PAERSED_FORM_FILE=""
		fi
	done

	#
	# Dump from top level
	#
	if ! jsonparser_get_json_part "" "" "$1" 0 "${_JP_DUMP_SINGLE_LINE}" "${_JP_PAERSED_FORM_FILE}"; then
		prn_dbg "(jsonparser_dump_parsed_file) Failed to dump parse json file."
		rm -f "${_JP_PAERSED_FORM_FILE}"
		return 1
	fi
	if [ -z "${_JP_DUMP_SINGLE_LINE}" ] || [ "${_JP_DUMP_SINGLE_LINE}" != "1" ]; then
		if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
			pecho '' >> "${_JP_PAERSED_FORM_FILE}"
		fi
	fi
	cat "${_JP_PAERSED_FORM_FILE}"
	rm -f "${_JP_PAERSED_FORM_FILE}"

	return 0
}

#
# Dump key in parsed file 
#
# $1	: key path
# $2	: key name
# $3	: parsed json file
# $4	: single line(1)
# $?	: result
#
jsonparser_dump_key_parsed_file()
{
	if [ $# -lt 2 ]; then
		prn_dbg "(jsonparser_dump_key_parsed_file) Paramter is wrong."
		return 1
	fi
	if [ ! -f "$3" ]; then
		prn_dbg "(jsonparser_dump_key_parsed_file) File paramter is wrong."
		return 1
	fi
	if [ -n "$4" ] && [ "$4" = "1" ]; then
		_JP_DUMP_SINGLE_LINE=1
	else
		_JP_DUMP_SINGLE_LINE=0
	fi

	#
	# Make temporary file
	#
	_JP_PAERSED_FORM_FILE=""
	while [ -z "${_JP_PAERSED_FORM_FILE}" ]; do
		_JP_PAERSED_FORM_FILE_SUFFIX=$((_JP_PAERSED_FORM_FILE_SUFFIX + 1))
		_JP_PAERSED_FORM_FILE="/tmp/.k2hr3_parse_json_sub_$$_${_JP_PAERSED_FORM_FILE_SUFFIX}.tmp"
		if [ -f "${_JP_PAERSED_FORM_FILE}" ]; then
			_JP_PAERSED_FORM_FILE=""
		fi
	done

	#
	# Dump from top level
	#
	if ! jsonparser_get_json_part "$1" "$2" "$3" 0 "${_JP_DUMP_SINGLE_LINE}" "${_JP_PAERSED_FORM_FILE}"; then
		prn_dbg "(jsonparser_dump_key_parsed_file) Failed to dump parse json file."
		rm -f "${_JP_PAERSED_FORM_FILE}"
		return 1
	fi
	# [NOTE]
	# Since the condition becomes complicated, use "X"(temporary word).
	#
	if [ "X${_JP_DUMP_SINGLE_LINE}" != "X1" ] && [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
		pecho '' >> "${_JP_PAERSED_FORM_FILE}"
	fi
	cat "${_JP_PAERSED_FORM_FILE}"
	rm -f "${_JP_PAERSED_FORM_FILE}"

	return 0
}

#
# Dump json string
#
# $1	: json string
# $2	: single line(1)
# $?	: result
#
jsonparser_dump_string()
{
	if [ $# -lt 1 ]; then
		prn_dbg "(jsonparser_dump_string) Paramter is wrong."
		return 1
	fi
	if [ -n "$2" ] && [ "$2" = "1" ]; then
		_JP_DUMP_SINGLE_LINE=1
	else
		_JP_DUMP_SINGLE_LINE=0
	fi

	#
	# Parse Json
	#
	if ! jsonparser_parse_json_string "$1"; then
		prn_dbg "(jsonparser_dump_string) Failed to parse json string."
		return 1
	fi

	#
	# Dump from top level
	#
	if ! jsonparser_dump_parsed_file "${JP_PAERSED_FILE}" "${_JP_DUMP_SINGLE_LINE}"; then
		prn_dbg "(jsonparser_dump_string) Failed to dump parse json string."
		if [ -z "${JP_LEAVE_PARSED_FILE}" ] || [ "${JP_LEAVE_PARSED_FILE}" != "1" ]; then
			rm -f "${JP_PAERSED_FILE}"
		fi
		return 1
	fi
	if [ -z "${JP_LEAVE_PARSED_FILE}" ] || [ "${JP_LEAVE_PARSED_FILE}" != "1" ]; then
		rm -f "${JP_PAERSED_FILE}"
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
