file(GLOB scripts *.cmake *.in.sh *.py)
file(GLOB cpp_files RELATIVE cpp11 *.cpp)

install(
  FILES ${scripts}
  DESTINATION ${INSTALL_DIRECTORY}/scripts
)

install(
  FILES ${cpp_files}
  DESTINATION ${INSTALL_DIRECTPORY}/scripts/cpp11
)

