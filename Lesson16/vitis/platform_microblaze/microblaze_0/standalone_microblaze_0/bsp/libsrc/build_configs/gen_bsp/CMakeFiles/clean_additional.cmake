# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson16/vitis/platform_microblaze/microblaze_0/standalone_microblaze_0/bsp/include/sleep.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson16/vitis/platform_microblaze/microblaze_0/standalone_microblaze_0/bsp/include/xiltimer.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson16/vitis/platform_microblaze/microblaze_0/standalone_microblaze_0/bsp/include/xtimer_config.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson16/vitis/platform_microblaze/microblaze_0/standalone_microblaze_0/bsp/lib/libxiltimer.a"
  )
endif()
