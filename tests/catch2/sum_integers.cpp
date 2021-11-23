#include "sum_integers.hpp"
#include <vector>

int sum_integers(const std::vector<int> integers) {
    auto sum = 0;
    for (const auto &item : integers) {
        sum += item;
    }
    return sum;
}