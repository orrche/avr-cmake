avr-cmake
=========

Attempt at cmake file to use for avr projects.





Example of CMakeLists.txt
=========================
```
cmake_minimum_required(VERSION 2.8)
project ( usbtool )

include ( avr-cmake/avr.cmake )

add_executable(${TARGET_ELF}
        usbtool.c
)
```
