#include <chrono>

int main(int argc, char const * argv[]) {
    auto const start = std::chrono::monotonic_clock::now();
    auto const end = std::chrono::monotonic_clock::now();
    return start < end;
}
