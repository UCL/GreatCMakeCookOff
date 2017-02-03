#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include <exception>

unsigned int Factorial( unsigned int number ) {
    return number <= 1 ? number : Factorial(number-1)*number;
}

void do_throw_stuff() {
  throw std::out_of_range("s");
}

TEST_CASE( "Factorials are computed", "[factorial]" ) {
    REQUIRE( Factorial(1) == 1 );
    REQUIRE( Factorial(2) == 2 );
    REQUIRE( Factorial(3) == 6 );
    REQUIRE( Factorial(10) == 3628800 );
    CHECK_THROWS_AS(do_throw_stuff(), std::out_of_range);
}

