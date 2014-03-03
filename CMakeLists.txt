cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(GreatCMakeCookOff)

option(tests          "Enable testing."                         on)

file(GLOB scripts *.cmake)
file(GLOB cpp_files RELATIVE cpp11 *.cpp)

set(INSTALL_DIRECTORY share/GreatCMakeCookOff )
install(
  FILES ${scripts}
  DESTINATION ${INSTALL_DIRECTORY}
)

install(
  FILES ${cpp_files}
  DESTINATION ${INSTALL_DIRECTPORY}/cpp11
)

install(
  FILES GreatCMakeCookOffConfig.cmake
  DESTINATION ${INSTALL_DIRECTORY}/cmake COMPONENT dev
)

if(tests)
  enable_testing()
  list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
  include(TestCMake)
  add_subdirectory(tests)
endif()
