# Checks for C++11 features
#  HAS_CXX11_AUTO               - auto keyword
#  HAS_CXX11_NULLPTR            - nullptr
#  HAS_CXX11_LAMBDA             - lambdas
#  HAS_CXX11_STATIC_ASSERT      - static_assert()
#  HAS_CXX11_RVALUE_REFERENCES  - rvalue references
#  HAS_CXX11_DECLTYPE           - decltype keyword
#  HAS_CXX11_CSTDINT_H          - cstdint header
#  HAS_CXX11_LONG_LONG          - long long signed & unsigned types
#  HAS_CXX11_VARIADIC_TEMPLATES - variadic templates
#  HAS_CXX11_CONSTEXPR          - constexpr keyword
#  HAS_CXX11_SIZEOF_MEMBER      - sizeof() non-static members
#  HAS_CXX11_FUNC               - __func__ preprocessor constant
#
# Original script by Rolf Eike Beer
# Modifications by Andreas Weis
# Further Modifications by RSDT@UCL
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

set(CPP11_FEATURE_CHECK_DIR ${CMAKE_CURRENT_LIST_DIR}/cpp11)

MACRO(cxx11_check_single_feature FEATURE_NAME FEATURE_NUMBER RESULT_VAR)
	IF (NOT DEFINED ${RESULT_VAR})
    SET(_bindir "${CMAKE_BINARY_DIR}/cxx11_feature_tests/cxx11_${FEATURE_NAME}")

		IF (${FEATURE_NUMBER})
      SET(_SRCFILE_BASE ${CPP11_FEATURE_CHECK_DIR}/${FEATURE_NAME}-N${FEATURE_NUMBER})
			SET(_LOG_NAME "\"${FEATURE_NAME}\" (N${FEATURE_NUMBER})")
		ELSE (${FEATURE_NUMBER})
      SET(_SRCFILE_BASE ${CPP11_FEATURE_CHECK_DIR}/${FEATURE_NAME})
			SET(_LOG_NAME "\"${FEATURE_NAME}\"")
		ENDIF (${FEATURE_NUMBER})
		MESSAGE(STATUS "Checking C++11 support for ${_LOG_NAME}")

		SET(_SRCFILE "${_SRCFILE_BASE}.cpp")
		SET(_SRCFILE_FAIL "${_SRCFILE_BASE}_fail.cpp")
		SET(_SRCFILE_FAIL_COMPILE "${_SRCFILE_BASE}_fail_compile.cpp")

		IF (CROSS_COMPILING)
			try_compile(${RESULT_VAR} "${_bindir}" "${_SRCFILE}")
			IF (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
				try_compile(${RESULT_VAR} "${_bindir}_fail" "${_SRCFILE_FAIL}")
			ENDIF (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
		ELSE (CROSS_COMPILING)
			try_run(_RUN_RESULT_VAR _COMPILE_RESULT_VAR
					"${_bindir}" "${_SRCFILE}")
			IF (_COMPILE_RESULT_VAR AND NOT _RUN_RESULT_VAR)
				SET(${RESULT_VAR} TRUE)
			ELSE (_COMPILE_RESULT_VAR AND NOT _RUN_RESULT_VAR)
				SET(${RESULT_VAR} FALSE)
			ENDIF (_COMPILE_RESULT_VAR AND NOT _RUN_RESULT_VAR)
			IF (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
				try_run(_RUN_RESULT_VAR _COMPILE_RESULT_VAR
						"${_bindir}_fail" "${_SRCFILE_FAIL}")
				IF (_COMPILE_RESULT_VAR AND _RUN_RESULT_VAR)
					SET(${RESULT_VAR} TRUE)
				ELSE (_COMPILE_RESULT_VAR AND _RUN_RESULT_VAR)
					SET(${RESULT_VAR} FALSE)
				ENDIF (_COMPILE_RESULT_VAR AND _RUN_RESULT_VAR)
			ENDIF (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
		ENDIF (CROSS_COMPILING)
		IF (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL_COMPILE})
			try_compile(_TMP_RESULT "${_bindir}_fail_compile" "${_SRCFILE_FAIL_COMPILE}")
			IF (_TMP_RESULT)
				SET(${RESULT_VAR} FALSE)
			ELSE (_TMP_RESULT)
				SET(${RESULT_VAR} TRUE)
			ENDIF (_TMP_RESULT)
		ENDIF (${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL_COMPILE})

		IF (${RESULT_VAR})
			MESSAGE(STATUS "Checking C++11 support for ${_LOG_NAME} -- works")
		ELSE (${RESULT_VAR})
			MESSAGE(STATUS "Checking C++11 support for ${_LOG_NAME} -- not supported")
		ENDIF (${RESULT_VAR})
		SET(${RESULT_VAR} ${${RESULT_VAR}} CACHE INTERNAL "C++11 support for ${_LOG_NAME}")
	ENDIF (NOT DEFINED ${RESULT_VAR})
ENDMACRO(cxx11_check_single_feature)

# Find list of all features
function(cxx11_find_all_features outvar)
  FILE(GLOB ALL_CPP11_FEATURE_FILES "${CPP11_FEATURE_CHECK_DIR}/*.cpp")
  set(OUTPUT_VARIABLES)
  foreach(filename ${ALL_CPP11_FEATURE_FILES})
    get_filename_component(filename ${filename} NAME_WE)
    string(REGEX REPLACE "-N[0-9]*" "" filename "${filename}")
    set(OUTPUT_VARIABLES ${OUTPUT_VARIABLES} ${filename})
  endforeach()
  set(${outvar} ${OUTPUT_VARIABLES} PARENT_SCOPE)
endfunction()

# Parses input and separates into arguments before REQUIRED and after REQUIRED.
# Arguments before REQUIRED are OPTIONALS.
# Arguments after REQUIRED are REQUIRED.
# If no arguments, then sets output OPTIONALS to ALLFEATURES.
function(parse_input_features ALLFEATURES OPTIONALS ERRORS REQUIRED)

  if("${ARGN}" STREQUAL "")
    set(${OPTIONALS} ${ALLFEATURES} PARENT_SCOPE)
    set(${REQUIRED} "" PARENT_SCOPE)
  else()
    set(REQUIRED_FEATURES)
    set(OPTIONAL_FEATURES)
    set(UNKNOWN_FEATURES)
    set(result_type OPTIONAL_FEATURES)
    foreach(feature ${ARGN})
      if(${feature} STREQUAL "REQUIRED")
        set(result_type REQUIRED_FEATURES)
      else()
        list(FIND ALLFEATURES ${feature} feature_was_found)

        if(feature_was_found EQUAL "-1")
          list(APPEND UNKNOWN_FEATURES ${feature})
        else()
          list(APPEND ${result_type} ${feature})
        endif()

      endif(${feature} STREQUAL "REQUIRED")
    endforeach()

    set(${OPTIONALS} ${OPTIONAL_FEATURES} PARENT_SCOPE)
    set(${REQUIRED} ${REQUIRED_FEATURES} PARENT_SCOPE)
    set(${ERRORS} ${UNKNOWN_FEATURES} PARENT_SCOPE)
  endif("${ARGN}" STREQUAL "")
endfunction(parse_input_features)


function(cxx11_feature_check)

  # find all features
  cxx11_find_all_features(ALL_CPP11_FEATURES)



endfunction(cxx11_feature_check)


# CXX11_CHECK_FEATURE("auto"                  2546 HAS_CXX11_AUTO)
# CXX11_CHECK_FEATURE("lambda"                2927 HAS_CXX11_LAMBDA)
# CXX11_CHECK_FEATURE("static_assert"         1720 HAS_CXX11_STATIC_ASSERT)
# CXX11_CHECK_FEATURE("rvalue_references"     2118 HAS_CXX11_RVALUE_REFERENCES)
# CXX11_CHECK_FEATURE("decltype"              2343 HAS_CXX11_DECLTYPE)
# CXX11_CHECK_FEATURE("type_traits"           ""   HAS_CXX11_TYPETRAITS)
# CXX11_CHECK_FEATURE("trivial_type_traits"   ""   HAS_CXX11_TRIVIALTYPETRAITS)
# CXX11_CHECK_FEATURE("noexcept"              ""   HAS_CXX11_NOEXCEPT)
# CXX11_CHECK_FEATURE("constexpr"             2235 HAS_CXX11_CONSTEXPR)
# CXX11_CHECK_FEATURE("unique_ptr"            ""   HAS_CXX11_UNIQUE_PTR)
# CXX11_CHECK_FEATURE("shared_ptr"            ""   HAS_CXX11_SHARED_PTR)
# CXX11_CHECK_FEATURE("constructor_delegate"  ""   HAS_CXX11_CONSTRUCTOR_DELEGATE)
# CXX11_CHECK_FEATURE("initialization"        ""   HAS_CXX11_UNIQUE_INITIALIZATION)
# # MinGW has not implemented std::random_device fully yet. Unfortunately, this can only be detected
# # by running a program which tries to call std::random_device. However that generates an error that
# # is *not* caught by CMake's try_run. 
# if(NOT MSYS)
#   CXX11_CHECK_FEATURE("random_device"       ""   HAS_CXX11_RANDOM_DEVICE)
# endif(NOT MSYS)
# CXX11_CHECK_FEATURE("nullptr"            2431 HAS_CXX11_NULLPTR)
# CXX11_CHECK_FEATURE("cstdint"            ""   HAS_CXX11_CSTDINT_H)
# CXX11_CHECK_FEATURE("long_long"          1811 HAS_CXX11_LONG_LONG)
# CXX11_CHECK_FEATURE("variadic_templates" 2555 HAS_CXX11_VARIADIC_TEMPLATES)
# CXX11_CHECK_FEATURE("sizeof_member"      2253 HAS_CXX11_SIZEOF_MEMBER)
# CXX11_CHECK_FEATURE("__func__"           2340 HAS_CXX11_FUNC)
