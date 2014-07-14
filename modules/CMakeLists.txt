file(GLOB scripts *.cmake)

install(
  FILES ${scripts}
  DESTINATION ${INSTALL_DIRECTORY}/modules
)
