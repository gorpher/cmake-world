#include <cstdlib>
#include <iostream>
#include <string>

std::string say_hello() {
    std::string arch_info("x86_64");
    arch_info += std::string(" architecture. ");
    return arch_info + std::string("Compiled on a 64 bit host processor.");
}

int main() {
    std::cout << say_hello() << std::endl;
    return EXIT_SUCCESS;
}