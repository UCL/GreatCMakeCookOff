# Copyright (c) 2015, Damien Buhl 
# All rights reserved.
include(hunter_add_version)
include(hunter_download)
include(hunter_pick_scheme)
include(hunter_add_package)
include(hunter_configuration_types)

# Makes it possible to use syste cfitsio
hunter_add_version(
    PACKAGE_NAME
    MPFR
    VERSION
    "3.1.4"
    URL
    "http://www.mpfr.org/mpfr-current/mpfr-3.1.4.tar.gz"
    SHA1
    272212c889d0ad6775ab6f315d668f3d01d1eaa3
)

hunter_pick_scheme(DEFAULT MPFR)
hunter_configuration_types(MPFR CONFIGURATION_TYPES Release)
hunter_download(PACKAGE_NAME MPFR)
