file(GLOB scripts *.cmake *.py *.cc)
file(GLOB numpy numpy/*.cc numpy/*.c)
file(GLOB arch arch/*.c)

install(FILES ${scripts} DESTINATION ${INSTALL_DIRECTORY}/modules)
install(FILES ${numpy} DESTINATION ${INSTALL_DIRECTORY}/modules/numpy)
install(FILES ${arch} DESTINATION ${INSTALL_DIRECTORY}/modules/arch)
