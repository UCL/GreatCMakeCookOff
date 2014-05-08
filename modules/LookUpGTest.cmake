# Installs GTest into build directory
if(GTest_ARGUMENTS)
    cmake_parse_arguments(GTest
        "SVN_REPOSITORY;TIMEOUT"
        ""
        ${GTest_ARGUMENTS}
    )
endif()

set(arguments SVN_REPOSITORY)
if(GTest_SVN_REPOSITORY)
    list(APPEND arguments ${GTest_SVN_REPOSITORY})
else()
    list(APPEND arguments http://googletest.googlecode.com/svn/trunk/)
endif()
if(GTest_TIMEOUT)
    list(APPEND arguments TIMEOUT ${GTest_TIMEOUT})
else()
    list(APPEND arguments TIMEOUT 10)
endif()

# write subset of variables to cache for gtest to use
include(PassonVariables)
passon_variables(GTest
    FILENAME "${EXTERNAL_ROOT}/src/GTestVariables.cmake"
    PATTERNS
        "CMAKE_[^_]*_R?PATH"
        "CMAKE_C_.*"
        "CMAKE_CXX_.*"
)

set(cmake_args -DBUILD_SHARED_LIBS=OFF -Dgtest_force_shared_crt=ON)
if(MINGW)
  list(APPEND cmake_args -Dgtest_disable_pthreads=ON)
endif()

ExternalProject_Add(
    GTest
    PREFIX "${EXTERNAL_ROOT}"
    ${arguments}
    # Force separate output paths for debug and release builds to allow easy
    # identification of correct lib in subsequent TARGET_LINK_LIBRARIES commands
    CMAKE_ARGS
        -C "${EXTERNAL_ROOT}/src/GTestVariables.cmake"
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        ${cmake_args}

    # Wrap download, configure and build steps in a script to log output
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
)

add_recursive_cmake_step(GTest DEPENDEES build)
# Required by FindGTest
set(GTEST_ROOT "${EXTERNAL_ROOT}/src/GTest-build" CACHE
    PATH "Path to gtest root install directory")
