The Great CMake CookOff
=======================


This is a repository of usefull and less than usefull cmake recipes.  It is distributed under the
[MIT License](http://opensource.org/licenses/MIT)


FindEigen
=========

Looks for the Eigen installed on system. If not found, then uses external project to download it.
Usage is as follows:

```cmake
# Tell cmake to look into GreatCMakeCookOff for recipes
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/GreatCMakeCookOff) 

# Optionally, tell cmake where to download eigen, if needed.
# Defaults to value below.
set(EXTERNAL_ROOT ${PROJECT_BINARY_DIR}/external)

# Now look for cmake.
find_package(Eigen)
```

Check c++11 feature sets
========================

Look for some c++11 features. Uses a script modified from [here](http://pageant.ghulbus.eu/?p=664).
Usage is given below.

```cmake
# First need to enable c++
enable_language(CXX)

# The following will print out all available features.
cxx11_find_all_features(ALL_FEATURES)
message(STATUS "[c++11] features we can check for: ${ALL_FEATURES}")

# The following checks for all features
cxx11_feature_check()

# An internal value is set if a particular feature exists.
if(HAS_CXX11_AUTO)
  message(STATUS "[c++11] has auto.")
endif()
if(HAS_CXX11_LAMBDA)
  message(STATUS "[c++11] has lambda.")
endif()
```

Alternatively, only a subset of features can be checked for, and some can be required:
```cmake
cxx11_feature_check(auto lambda REQUIRED long_long share_ptr variadic_templates)
```
The previous statement will fail if ``long long``, ``std::shared_ptr<...>``, and variadic templates
are not available. It will also check for the availability of ``auto`` and ``lambda``, but without
failing.

Figure out ``isnan``
====================

Each and every vendor provides a different ``isnan``. There is a script to help define a portable
c++ macro. It is meant to be used within a configuration file as follows:

```cmake
include("path/to/cookoff/CheckIsNaN.cmake")
if(NOT ISNAN_VARIATION)
  message(STATUS "Could not find working isnan.")
endif(NOT ISNAN_VARIATION)

configure_file(/path/to/config.h.in /path/to/config.h)
```

The configuration file ``config.h.in`` should include a line near the top with
``@ISNAN_VARIATION@``.  It will expand to:

```cpp
#include <cmath>
#define not_a_number(X) std::isnan(X)
```
One should then use the macro ``not_a_number`` in-place of any ``isnan`` flavour.


Testing CMake scripts
=====================

The file ``TestCMake.cmake`` contains a function to test cmake scripts. It converts an input cmake
file into a project which is then configured, built, and run using ``ctest``. Unless an optional
"SOURCE" is provided as argument, the test program is an empty ``main`` function returning 0. If the
keyword is provided, then a ``main.cc`` or ``main.c`` file should provided the cmake script.

For examples, look at the tests in this package.
