# This is a C++ feature
enable_language(CXX)

# Include check feature.
include(${cookoff_path}/CheckCXX11Features.cmake)

# Now call function to test.
cxx11_find_all_features(ALL_CPP11_FEATURES)

# Make sure there are some features.
LIST(LENGTH ALL_CPP11_FEATURES LIST_LENGTH)
if(${LIST_LENGTH} EQUAL 0)
  message(FATAL_ERROR "No c++11 features found")
endif(${LIST_LENGTH} EQUAL 0)
