cmake_minimum_required(VERSION 3.0)
project(mkl_sgemm C)

find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()

find_package(MKL REQUIRED)

add_definitions(${MKL_DEFINITIONS})
include_directories(${MKL_INCLUDE_DIRS})

message(STATUS "MKL_DEFINITIONS = ${MKL_DEFINITIONS}")
message(STATUS "MKL_INCLUDE_DIRS = ${MKL_INCLUDE_DIRS}")
message(STATUS "MKL_LIBRARIES = ${MKL_LIBRARIES}")

file(WRITE "${CMAKE_SOURCE_DIR}/mkl_sgemm.c"
    "#include <mkl.h>\n"
    "int main() {\n"
    "  const float alpha = 1.0f;\n"
    "  const float A[16] = { 1.0f, 0.0f, 0.0f, 0.0f,\n"
    "                        0.0f, 1.0f, 0.0f, 0.0f,\n"
    "                        0.0f, 0.0f, 1.0f, 0.0f,\n"
    "                        0.0f, 0.0f, 0.0f, 1.0f };\n"
    "  const float B[16] = { 1.0f, 0.0f, 0.0f, 0.0f,\n"
    "                        0.0f, 1.0f, 0.0f, 0.0f,\n"
    "                        0.0f, 0.0f, 1.0f, 0.0f,\n"
    "                        0.0f, 0.0f, 0.0f, 1.0f };\n"
    "  const float beta = 0.0f;\n"
    "  float C[16];\n"
    "  cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasTrans, 4, 4, 4,\n"
    "              alpha, A, 4, B, 4, beta, C, 4);\n"
    "  return 0;\n"
    "}\n"
)

add_executable(mkl_sgemm mkl_sgemm.c)
target_link_libraries(mkl_sgemm ${MKL_LIBRARIES})
