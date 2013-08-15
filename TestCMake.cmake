function(cmake_test testname)

  # Parse further arguments
  if(${ARGN} MATCHES SOURCE)
      set(SOURCE True)
  endif()

  # set source and build dir.
  set(FAKE_PROJECT_DIR ${CMAKE_CURRENT_BINARY_DIR}/${testname})
  set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/fake_project_builds/${testname})
  message(STATUS "[${testname}] project in ${FAKE_PROJECT_DIR}")

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${testname}.cmake 
                 ${FAKE_PROJECT_DIR}/CMakeData.cmake @ONLY)

  if(NOT SOURCE)
    file(WRITE ${FAKE_PROJECT_DIR}/main.c "int main() { return 0; }" )
  endif(NOT SOURCE)
  file(WRITE ${FAKE_PROJECT_DIR}/CMakeLists.txt
       "cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)\n"
       "project(allfeatures)\n"
       "include(\"${FAKE_PROJECT_DIR}/CMakeData.cmake\")\n"
       "enable_language(C)\n"
       "file(GLOB ALLFILES \${PROJECT_SOURCE_DIR}/*.c \${PROJECT_SOURCE_DIR}/*.cc)\n"
       "add_executable(${testname} \${ALLFILES})\n")


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
