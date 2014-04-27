# First attempts using pkg-config. It is not unlikely to work and should be
# quite reliable on linuxes.
include(FindPkgConfig)
pkg_search_module(CBLAS cblas)
if(NOT CBLAS_FOUND AND PKG_CONFIG_FOUND)
	pkg_search_module(ATLAS atlas)
else()
	set(BLAS_LIBRARIES ${CBLAS_LIBRARIES})
	set(BLAS_INCLUDE_DIR ${CBLAS_INCLUDE_DIRS})
endif()

# Corrects for deficiencies in cmake find_package(BLAS)
find_package(BLAS QUIET)

# Adds pthread if necessary
if("${BLAS_LIBRARIES}" MATCHES "mkl" AND "${BLAS_LIBRARIES}" MATCHES "thread")
    list(APPEND BLAS_LIBRARIES "-lpthread")
endif()

# Figures out atlas if necessary
if(BLAS_atlas_LIBRARY)
    get_filename_component(atlas_dir "${BLAS_atlas_LIBRARY}" PATH)
    get_filename_component(atlas_ext "${BLAS_atlas_LIBRARY}" EXT)
    find_library(BLAS_atlas_cblas_LIBRARY NAMES libcblas${atlas_ext}
        HINTS "${atlas_dir}"
    )
    if(BLAS_atlas_cblas_LIBRARY)
        set(BLAS_FOUND TRUE)
        set(BLAS_LIBRARIES
            "${BLAS_atlas_cblas_LIBRARY}"
            "${BLAS_atlas_LIBRARY}"
        )
    endif()
endif()


# Adds BLAS_INCLUDE_DIR
function(include_directories_from_library_paths OUTVAR)
    set(results)
    foreach(path ${ARGN})
		string(REGEX REPLACE "(.*)/lib(64)?/.*" "\\1/include" current "${path}")
        if(NOT "${current}" STREQUAL "/include" AND IS_DIRECTORY "${current}")
            list(APPEND results "${current}")
        endif()
    endforeach()
	if(NOT "${results}" STREQUAL "")
        list(REMOVE_DUPLICATES results)
        set(${OUTVAR} ${results} PARENT_SCOPE)
	endif()
endfunction()
# find_package blas does not look for cblas.h
if(NOT BLAS_INCLUDE_DIR AND BLAS_LIBRARIES)
    include_directories_from_library_paths(directories ${BLAS_LIBRARIES})
    find_path(BLAS_INCLUDE_DIR NAMES cblas.h mkl.h HINTS ${directories})
endif()

if(NOT CBLAS_FIND_QUIETLY)
    if(BLAS_LIBRARIES)
        list(GET BLAS_LIBRARIES 0 first_blas)
        message(STATUS "Found blas libraries ${first_blas}")
    endif()
    if(BLAS_INCLUDE_DIR)
        message(STATUS "Found blas include ${BLAS_INCLUDE_DIR}")
    endif()
endif()
if(CBLAS_FIND_REQUIRED)
  if(NOT BLAS_LIBRARIES AND NOT BLAS_INCLUDE_DIR)
      message(FATAL_ERROR "Could not find a blas library")
  elseif(NOT BLAS_INCLUDE_DIR)
      message(FATAL_ERROR "Could not figure out blas include dir")
  elseif(NOT BLAS_LIBRARIES)
      message(FATAL_ERROR "Could not figure out blas library")
  endif()
endif()
