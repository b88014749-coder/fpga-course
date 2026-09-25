# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/diskio.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/ff.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/ffconf.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/sleep.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/xilffs.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/xilffs_config.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/xilrsa.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/xiltimer.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/include/xtimer_config.h"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/lib/libxilffs.a"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/lib/libxilrsa.a"
  "/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/platform_zynq/zynq_fsbl/zynq_fsbl_bsp/lib/libxiltimer.a"
  )
endif()
