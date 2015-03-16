if(Eigen3_ARGUMENTS)
    cmake_parse_arguments(Eigen3
        ""
        "HG_REPOSITORY;HG_TAG;URL;MD5;TIMEOUT"
        ""
        ${Eigen3_ARGUMENTS}
    )
endif()

if(NOT Eigen3_URL)
    set(Eigen3_URL http://bitbucket.org/eigen/eigen/get/3.2.4.tar.gz)
    set(Eigen3_MD5 4d0d77e06fef87b4fcd2c9b72cc8dc55)
endif()
if(NOT Eigen3_HG_REPOSITORY)
    set(Eigen3_HG_REPOSITORY https://bitbucket.org/eigen/eigen/)
endif()
if(NOT Eigen3_BUILD_TYPE)
    set(Eigen3_BUILD_TYPE Release)
endif()
if(NOT Eigen3_TIMEOUT)
    set(Eigen3_TIMEOUT 10)
endif()

if(NOT "${Eigen3_URL}" STREQUAL "")
    if("${Eigen3_MD5}" STREQUAL "")
        message(FATAL_ERROR "Downloading from an URL requires an MD5 hash")
    endif()
    set(arguments URL "${Eigen3_URL}" URL_MD5 ${Eigen3_MD5})
elseif("${CMAKE_VERSION}" VERSION_GREATER 2.8.9 )
    set(arguments HG_REPOSITORY "${Eigen3_HG_REPOSITORY}")
    if(NOT Eigen3_HG_TAG)
        list(APPEND arguments HG_TAG ${Eigen3_HG_TAG})
    endif()
else()
    message(FATAL_ERROR "Requires cmake >= 2.8.10 to download Eigen from mercurial")
endif()
list(APPEND arguments TIMEOUT ${Eigen3_TIMEOUT})

# write subset of variables to cache for eigen3 to use
include(PassonVariables)
passon_variables(Eigen3
    FILENAME "${EXTERNAL_ROOT}/src/Eigen3Variables.cmake"
    PATTERNS
        "CMAKE_[^_]*_R?PATH"
        "CMAKE_C_.*"
        "CMAKE_CXX_.*"
        "BLAS_.*" "FFTW3_.*"
        ".*_INCLUDE_DIRS?"
    ALSOADD
        "\nset(CMAKE_INSTALL_PREFIX \"${EXTERNAL_ROOT}\" CACHE STRING \"\")\n"
)

# Finally add project
ExternalProject_Add(
    Eigen3
    PREFIX ${EXTERNAL_ROOT}
    ${arguments}
    CMAKE_ARGS
        -C "${EXTERNAL_ROOT}/src/Eigen3Variables.cmake"
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_BUILD_TYPE=${Eigen3_BUILD_TYPE}
    # Wrap download, configure and build steps in a script to log output
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
)

add_recursive_cmake_step(Eigen3 DEPENDEES install)
