# Installs GBenchmark into build directory
ExternalProject_Add(
    Lookup-spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog
    PREFIX "${EXTERNAL_ROOT}"
    # Force separate output paths for debug and release builds to allow easy
    # identification of correct lib in subsequent TARGET_LINK_LIBRARIES commands
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E copy_directory ${EXTERNAL_ROOT}/src/spdlog/include ${EXTERNAL_ROOT}/include

    # Wrap download, configure and build steps in a script to log output
    UPDATE_COMMAND ""
    LOG_DOWNLOAD ON LOG_CONFIGURE ON LOG_BUILD ON LOG_INSTALL ON
)

add_recursive_cmake_step(Lookup-spdlog DEPENDEES install)
