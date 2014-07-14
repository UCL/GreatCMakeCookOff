find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()

set(EXTERNAL_ROOT "${PROJECT_BINARY_DIR}/../lookup_eigen/external")
include(PackageLookup)
lookup_package(Eigen3 DOWNLOAD_BY_DEFAULT CHECK_EXTERNAL)

if(TARGET Eigen3)
    message(FATAL_ERROR "Did not expect eigen3 target")
endif()
if(NOT Eigen3_FOUND)
    message(FATAL_ERROR "Expected eigen to be in external area ${EXTERNAL_ROOT}")
endif()
