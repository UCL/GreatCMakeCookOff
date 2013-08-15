cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(CPP11_TEST)

enable_testing()

function(cmake_test testname)

  set(FAKE_PROJECT_DIR ${CMAKE_CURRENT_BINARY_DIR}/${testname})
  set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/fake_project_builds/${testname})
  message(STATUS "[${testname}] project in ${FAKE_PROJECT_DIR}")

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${testname}.cmake 
                 ${FAKE_PROJECT_DIR}/CMakeData.txt @ONLY)

  file(WRITE ${FAKE_PROJECT_DIR}/CMakeLists.txt
       "cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)\n"
       "project(allfeatures)\n"
       "include(\"${FAKE_PROJECT_DIR}/CMakeData.txt\")\n"
       "enable_language(C)\n"
       "add_executable(${testname} main.c)\n")
  file(WRITE ${FAKE_PROJECT_DIR}/main.c "int main() { return 0; }" )


  if(EXISTS ${BUILD_DIR})
    file(REMOVE_RECURSE ${BUILD_DIR})
  endif(EXISTS ${BUILD_DIR})

  file(MAKE_DIRECTORY ${BUILD_DIR})

  add_test(cmake_test_${testname}
             ${CMAKE_CTEST_COMMAND} --build-and-test ${FAKE_PROJECT_DIR} ${BUILD_DIR}
                                    --build-generator ${CMAKE_GENERATOR}
                                    --build-makeprogram ${CMAKE_MAKE_PROGRAM}
                                    --build-project ${testname}
                                    --build-options -Dcookoff_path=${CMAKE_SOURCE_DIR}/..)

endfunction(cmake_test)

add_subdirectory(cpp11)
