
SET(F_CPU "12000000" CACHE STRING "Running speed of AVR")
SET(MCU "atmega328p" CACHE STRING "Selected chip")
SET(AVRDUDE_PROGRAMMER "arduino" CACHE STRING "Programmer that is used" )
SET(AVRDUDE_PORT "/dev/ttyUSB0" CACHE STRING "Port that avrdude uses" )


if ( MCU STREQUAL "atmega328p" )
	SET(A_MCU "m328p")
elseif ( MCU STREQUAL "atmega8" )
	SET(A_MCU "m8")
endif ()

SET(AVRDUDE_MCU ${A_MCU} CACHE STRING "Avrdude selected chip")



find_program(AVR_CC avr-gcc)
find_program(AVR_CXX avr-g++)
find_program(AVR_OBJCOPY avr-objcopy)
find_program(AVR_SIZE_TOOL avr-size)
find_program(AVRDUDE avrdude)

SET(CMAKE_SYSTEM_NAME generic) 
set(CMAKE_C_COMPILER   ${AVR_CC})
set(CMAKE_CXX_COMPILER ${AVR_CXX})

# search for programs in the build host directories 
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER) 
# for libraries and headers in the target directories 
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY) 
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY) 

SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")

SET(CSTANDARD "") 
SET(CDEBUG "")
SET(CWARN "") 
SET(CTUNING "") 
SET(COPT "-O3") 
SET(CMCU "-mmcu=${MCU}") 
SET(CDEFS "-DF_CPU=${F_CPU}") 

SET(CFLAGS "${CMCU} ${CDEBUG} ${CDEFS} ${CINCS} ${COPT} ${CWARN} ${CSTANDARD} ${CEXTRA}") 
SET(CXXFLAGS "${CMCU} ${CDEFS} ${CINCS} ${COPT}") 

SET(CMAKE_C_FLAGS  ${CFLAGS}) 
SET(CMAKE_CXX_FLAGS ${CXXFLAGS}) 

set(CMAKE_CROSSCOMPILING 1) 
set(CMAKE_EXE_LINKER_FLAGS "") 

set(TARGET_ELF ${PROJECT_NAME}.elf)

set(FORMAT "ihex")

#| Convert the .ELF into a .HEX to load onto the Teensy
set( TARGET_HEX ${PROJECT_NAME}.hex )
add_custom_target( ${TARGET_HEX} ${AVR_OBJCOPY} -v -j.data -j.text -O${FORMAT} ${TARGET_ELF} ${TARGET_HEX}
	DEPENDS ${TARGET_ELF}
	COMMENT "Creating load file for Flash:  ${TARGET_HEX}"
)



#| After Changes Size Information
add_custom_target( SizeAfter ${AVR_SIZE_TOOL} --target=${FORMAT} ${TARGET_HEX} ${TARGET_ELF}
	DEPENDS ${TARGET_ELF}
	COMMENT "Size after generation:"
) 

if ( AVRDUDE )
	MESSAGE ("Generating avrdude command")

	add_custom_target( avrdude ${AVRDUDE} -B 5 -v -c ${AVRDUDE_PROGRAMMER} -p ${AVRDUDE_MCU} -P ${AVRDUDE_PORT} -e -U flash:w:${TARGET_HEX}
		DEPENDS ${TARGET_HEX}
		COMMENT "Installing using avrdude"
	) 

endif ()

