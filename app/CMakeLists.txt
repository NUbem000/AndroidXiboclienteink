# CMake configuration for E-ink native library

cmake_minimum_required(VERSION 3.22.1)

project("eink_controller")

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add source files
add_library(
        eink_controller
        SHARED
        src/main/cpp/eink_controller.cpp
        src/main/cpp/eink_jni.cpp
)

# Include directories
target_include_directories(
        eink_controller
        PRIVATE
        src/main/cpp/include
)

# Link libraries
target_link_libraries(
        eink_controller
        android
        log
)

# Compiler flags
target_compile_options(
        eink_controller
        PRIVATE
        -Wall
        -Wextra
        -O3
        -ffast-math
        -funroll-loops
)
