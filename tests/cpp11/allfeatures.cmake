cmake_minimum_required(VERSION 2.8.3 FATAL_ERROR)
project(allfeatures)

enable_language(CXX)
include(${cookoff_path}/CheckCXX11Features.cmake)
cxx11_find_all_features(ALL_CPP11_FEATURES)
message(STATUS "[cpp11] ${ALL_CPP11_FEATURES}")
