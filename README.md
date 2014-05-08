The Great CMake CookOff
=======================


This is a repository of usefull and less than usefull cmake recipes.  It is distributed under the
[MIT License](http://opensource.org/licenses/MIT)

Adding this repository to a cmake
=================================

The files in this repository can be added individually or as a whole to a project, as long as the
MIT copyright terms are followed. One possibility is to include this project as a [git
submodule](http://git-scm.com/docs/git-submodule).

However, the easiest method may well be to have this repository downloaded upon configuration of a
project. In that case, the file
[LookUp-GreatCMakeCookOff.cmake](https://github.com/UCL/GreatCMakeCookOff/tree/refactor/LookUp-GreatCMakeCookOff.cmake)
should be downloaded and inserted into the target project. It can then be included in the target
project's main `CMakeLists.txt` file:

```cmake
include(LookUp-GreatCMakeCookOff)
```

This will download the cook-off into the build directory right at configure time. Cook-off recipes
can then be used anywhere below that.

Another option is to point `CMake` towards the location on disk where a repo of the cook-off can be
found, or more explicitely, where the file `GreatCMakeCookOffConfig.cmake` can be found. This is
done with `cmake -DGreatCMakeCookOff_DIR=/path/to/cookoff/cmake ..`. Please note that this trick works
for any `CMake` project that defines `SomethingConfig.cmake` files.

Adding [Eigen](http://eigen.tuxfamily.org/) to a project
========================================================

Looks for the Eigen installed on system. If not found, then uses external project to download it.
Usage is as follows:

```cmake
# Optionally, tell cmake where to download eigen, if needed.
# Defaults to value below.
set(EXTERNAL_ROOT ${PROJECT_BINARY_DIR}/external)

# Now look for cmake.
find_package(Eigen)
```

**NOTE:** After building the first time, run cmake again. It will find the eigen it downloaded
previously, and it will stop checking for updates.


Adding [GTest](https://code.google.com/p/googletest/) to a project
==================================================================

For googly reasons, whether valid or 404, GTest prefers to be compiled for each an every project.
This script does two things:

- it adds GTest as an external project
- it provides a function to add gtests to ctest

This implies that GTest is downloaded the first time that make runs. Furthermore, it will be
checked each and every time that makes runs. So, make now requires a working internet connection.
Unlike Eigen above, there is currently no option avoid checking for updates.

The CMakeLists.txt file could look like this:

```cmake
option(tests          "Enable testing."                         on)

if(tests)
  find_package(GTest)
  enable_testing()
endif(tests)
```

And adding a test comes down to

```cmake
if(tests)

  add_gtest(testme testme.cc mylib)

endif(tests)
```

- first argument: name of the test
- second argument: list of source files
- other arguments: additional libraries to add during linking

The test do expect an explicit main function. See the test generated in ``tests/addgtest.cmake``.

**NOTE:** When using c++11, it is recommended to first include the c++11 flag script
``AddCPP11Flags.cmake`` (see below) so that the gtest can be compiled with ``GTEST_LANG_CXX11``.

C++11
=====

Checking for specific features
------------------------------

Look for some c++11 features. Uses a script modified from [here](http://pageant.ghulbus.eu/?p=664).
Usage is given below.

```cmake
# First need to enable c++
enable_language(CXX)

# Tell cmake to look into GreatCMakeCookOff for recipes
list(APPEND CMAKE_MODULE_PATH Path/to/cookoff)
# Adds flags to compiler to launch it into c++11 land
include(AddCPP11Flags)

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

Figuring out flags for some compilers
-------------------------------------

The script checks the existence of a few flags to enable c++11 features on different compilers.
The output is somewhat verbose, but it seems to do the job for gcc, darwin-gcc, and microsoft visual
studio. In addition, the intel compilers have to be told to use an external c++11 standard library.
This script cannot figure where this library would be (hint: g++ provides it), so that is left up to
the user. The script can be activated with a one liner.

```cmake
include("path/to/cookoff/AddCPP11Flags.cmake")
```

**NOTE:** On windows + visual studio, disables warnings 4251 and ups fake variadic templates to 10.


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

Two cmake variables are defined:

- ISNAN_HEADERS will the header(s) relevant to the local ``isnan`` definition
- ISNAN_VARIATIOPN is the fully qualified name to the local ``isnan`` definition

They can be used as follows in a the configuration file ``config.h.in``:

``cpp
@ISNAN_HEADERS@

#define not_a_number(X) @ISNAN_VARIATION@
``

One should then use the macro ``not_a_number`` in-place of any ``isnan`` flavour.

In c++11, it is also possible to define a function that takes only arithmetic type, thus obviating
the need for a macro:

```cpp
@ISNAN_HEADERS@
#include <type_traits>

template<class T>
  typename std::enable_if<std::is_arithmetic<T>::value, bool> :: type
    not_a_number(T const &_in) { return @ISNAN_VARIATION@(_in); }
```

Testing CMake scripts
=====================

The file ``TestCMake.cmake`` contains a function to test cmake scripts. It converts an input cmake
file into a project which is then configured, built, and run using ``ctest``. Unless an optional
"SOURCE" is provided as argument, the test program is an empty ``main`` function returning 0. If the
keyword is provided, then a ``main.cc`` or ``main.c`` file should provided the cmake script.

For examples, look at the tests in this package.

Aligned Allocation
==================

Not all platforms come with an aligned allocation, such as
[posix_memalign](http://linux.die.net/man/3/posix_memalign), and they certainly are not standard.
This script attempts to find one of many aligned allocation routines. It defaults to its own if it
cannot find one.

Usage requires adding bits to the cmake file:
```cmake
# Adds aligned allocation
include(AlignedAlloc)
```

Then, in a file under cmake
[configure_file](http://www.cmake.org/cmake/help/v2.8.12/cmake.html#command:configure_file),
add:

```cpp
@ALIGNED_ALLOC_HEADER@

namespace your_project {
  //! Aligned allocation variation
  inline void* aligned_alloc(size_t _size, size_t _alignment) {
    @ALIGNED_ALLOC_VARIATION@;
  }
}
```

Target for copying files
========================

It is sometimes usefull to copy files form one place to another during the compilation stage. For
instance, this makes it possible to create a python package inside the build directory and use it
during testing. The process is to create a dummy target and add files to it:

```cmake
include(TargetCopyFiles)
add_custom_target(mynewtarget)
add_copy_file(mynewtarget thisfile DESTINATION this/directory)

```

A few options are available, as described below:

```
add_copy_file(
   <target>                          -- target name
   [DESTINATION <destination>]       -- Directory where files will be copied
                                        Defaults to current binary directory
   [GLOB <glob>]                     -- A glob to find target files to copy
   [REPLACE <pattern> <replacement>] -- string(REGEX REPLACE) arguments on output filename
   [FILES <list of files>]           -- list of files to copy. Cannot be used with GLOB or ARGN.
   [<list of files>]                 -- list of files to copy. Cannot be used with GLOB or FILES.
)
```

Getting version and git hash
============================

A function is provided that will set a project's version and git hash during the *configure* step of
the cmake process.

```CMake
include(VersionAndGitRef)
set_version(0.1)
get_gitref()
```

It will set the `${PROJECT_NAME}_VERSION` and `${PROJECT_NAME}_GITREF` variables in the caller's
scope.

Adding to path-like environment variables
=========================================

```CMake
include(Utilities)
add_to_envvar(
  VARIABLE  -- Name of the environment variable
  PATH      -- Path to add
  [PREPEND] -- If path, adds at begining of list
  [OS somevariable] -- Only add path if the variable is defined.
                       Could be WIN32, or APPLE, or UNIX of anything else.
)
```

Find or install a package -- a.k.a lookup
=========================================
Adds the ability to "look-up" a package

This objective is to define a way to either find a package with find_package and/or,
depending on choices and circumstances, download and install that package.

The user should only have to include this file and add to their cmake files:

~~~cmake
include(PackageLookup)
lookup_package(<name>    # Name for find_package and lookup recipe files
   [QUIET]               # Whether to avoid making noise about the whole process
   [REQUIRED]            # Fails if package can neither be found nor installed
   [DOWNLOAD_BY_DEFAULT] # Always dowload, build, and install package locally. Does not look for
                         # pre-installed packages. This ensures the external project is always
                         # compiled specifically for this project.
   [ARGUMENTS <list>]    # Arguments specific to the look up recipe.
                         # They will be available inside the recipe under the variable
                         # ${name}_ARGUMENTS. Lookup recipes also have access to EXTERNAL_ROOT,
                         # a variable specifying a standard location for external projects in the
                         # build tree
   [...]                 # Arguments passed on to `find_package`.
)
~~~~

This will first attempt to call `find_package(name [...])` (with `QUIET` and without `REQUIRED`). If
the package is not found, then it will attempt to find a lookup recipe for the package. This recipe
should configure an external project that will install the missing package during the building
process.

All external lookup targets are dependees of the custom cmake target `lookup_dependencies`. It is
recommended that targets that depend on the external packages should be made to depend on
`lookup_dependencies`. This is made a bit easier via the macro:

```CMake
# Makes sure TARGET is built after the looked up projects.
depends_on_lookups(TARGET)
```

The name should match that of an existing `find_package(<name>)` file. The lookup_package function
depends on files in directories in the cmake prefixes paths that have
the name of the package:

- ${CMAKE_MODULE_PATH}/${package}/${package}-lookup.cmake
- ${CMAKE_MODULE_PATH}/${package}/LookUp${package}.cmake
- ${CMAKE_MODULE_PATH}/${package}/lookup.cmake
- ${CMAKE_MODULE_PATH}/${package}-lookup.cmake
- ${CMAKE_MODULE_PATH}/LookUp${package}.cmake
- ${CMAKE_MODULE_PATH}/${package}-lookup.cmake
- ${CMAKE_LOOKUP_PATH}/${package}-lookup.cmake
- ${CMAKE_LOOKUP_PATH}/LookUp${package}.cmake

These files are included when the function lookup_package is called.
The files will generally have the structure:

~~~cmake
# Parses arguments specific to the lookup recipe
# Optional step. Below, only a URL single-valued argument is specified.
if(package_ARGUMENTS)
    cmake_parse_arguments(package "" "URL" "" ${package_ARGUMENTS})
else()
    set(package_URL https://gaggledoo.doogaggle.com)
endif()
# The external project name `<package>` must match the package name exactly
ExternalProject_Add(package
  URL ${URL_
)
# Reincludes cmake so newly installed external can be found via find_package.
# Optional step.
add_recursive_cmake_step(...)
~~~

This pattern will first attempt to find the package on the system. If it is not found, an external
project to create it is added, with an extra step to rerun cmake and find the newly installed
package.

If a package is not found on the first call to configure, and then subsequently installed during the
make process, it can be interesting to have the package found on a second automatic pass of
configure. This is what the function `add_recursive_cmake_step` does. It adds a call to cmake as the
last step of downloading, building, and *installing* an external project.

~~~~cmake
# Adds a custom step to the external project that calls cmake recusively
# This makes it possible for the newly built package to be installed.
add_recursive_cmake_step(<name> # Still the same package name
   <${name}_FOUND> # Variable set to true if package is found
   [...]           # Passed on to ExternalProject_Add_Step
                   # in general, it will be `DEPENDEES install`,
                   # making this step the last.
)
~~~

Extra FindSomething
===================

* [FFTW](http://www.fftw.org/)
* [MKL](http://software.intel.com/en-us/intel-mkl)
* [Julia](http://julialang.org/)
* [Mako](http://www.makotemplates.org/). Installs it to ${PROJECT_BINARY_DIR}/external/python if it
  is not found.
* [CFitsIO](http://heasarc.gsfc.nasa.gov/fitsio/fitsio.html)
* [Numpy](www.numpy.org), also tests whether
    - `PyArray_ENABLEFLAGS` exists
    - `NPY_ARRAY_C_CONTIGUOUS` vs `NPY_C_CONTIGUOUS` macros
    - `npy_long_double` exists and is different from `npy_double`
    - `npy_bool` exists and is different from `npy_ubyte`
* CoherentPython: Looks for a *consistent* set of python interpreter and libraries.
