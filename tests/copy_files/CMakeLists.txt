file(WRITE ${PROJECT_BINARY_DIR}/original/hello "hello")
file(WRITE ${PROJECT_BINARY_DIR}/original/world "world")
file(WRITE ${PROJECT_BINARY_DIR}/original/something.c "world")
file(WRITE ${PROJECT_BINARY_DIR}/original/andthis.c "world")
file(WRITE ${PROJECT_BINARY_DIR}/original/notthis.h "world")

include(TargetCopyFiles)
include(TestCMake)

add_custom_target(copy ALL)
add_copy_files(copy
    DESTINATION ${PROJECT_BINARY_DIR}/here
    ${PROJECT_BINARY_DIR}/original/hello
    ${PROJECT_BINARY_DIR}/original/world
)
add_copy_files(copy
    GLOB ${PROJECT_BINARY_DIR}/original/*.c
    DESTINATION ${PROJECT_BINARY_DIR}/here
)

cmake_test(copy_files)
