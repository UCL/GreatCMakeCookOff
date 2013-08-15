# Add files for calculation
set(FAKE_PROJECT_DIR ${outdir}/${testname})
set(BUILD_DIR ${outdir}/build/${testname})

configure_file(${indir}/${testname}.cmake 
               ${FAKE_PROJECT_DIR}/CMakeData.txt @ONLY)
file(WRITE ${FAKE_PROJECT_DIR}/CMakeData.txt
     "cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)\n"
     "project(allfeatures)\n"
     "include(\"${outdir}/${testname}/CMakeData.txt\")\n"
     "enable_language(C)\n"
     "add_executable(${testname} main.cc)\n")
file(WRITE ${FAKE_PROJECT_DIR}/main.c "int main() { return 0; }" )


if(EXISTS ${BUILD_DIR})
  file(REMOVE_RECURSE ${BUILD_DIR})
endif(EXISTS ${BUILD_DIR})

file(MAKE_DIRECTORY ${BUILD_DIR})

add_test(COMMAND ${CMAKE_CTEST_COMMAND} --build-and-test ${FAKE_PROJECT_DIR} ${BUILD_DIR})
