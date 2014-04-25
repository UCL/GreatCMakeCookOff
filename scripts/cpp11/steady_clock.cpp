#include <chrono>

int main(int argc, char const * argv[]) {
    auto const start = std::chrono::steady_clock::now();
    auto const end = std::chrono::steady_clock::now();
    return start < end;
}
