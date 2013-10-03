enable_testing()
include(${cookoff_path}/AddFUnit.cmake)
if(NOT FOUND_funit)
  message(FATAL_ERROR "funit not found and not installed")
endif()
file(WRITE ${PROJECT_BINARY_DIR}/source/gas_physics.f90
"module gas_physics
 contains
   function viscosity(temperature)
     real :: viscosity, temperature
     viscosity = 2.0e-3 * temperature**1.5
   end function
end module
")
file(WRITE ${PROJECT_BINARY_DIR}/tests/gas_physics.fun
"test_suite gas_physics

   test viscosity_varies_as_temperature
    assert_real_equal(      0.0, viscosity(0.0) )
    assert_equal_within( 0.7071, viscosity(50.0), 1e-3 )
   end test

end test_suite
")
add_fctest(gas_phisycs ${PROJECT_BINARY_DIR}/tests/gas_physics.fun ${PROJECT_BINARY_DIR}/source)
