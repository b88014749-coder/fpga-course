# 2026-09-25T20:39:16.506071688
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

comp = client.create_app_component(name="peripheral_tests",platform = "$COMPONENT_LOCATION/../platform_blaze/export/platform_blaze/platform_blaze.xpfm",domain = "standalone_microblaze_0",template = "peripheral_tests")

platform = client.get_component(name="platform_blaze")
status = platform.build()

comp = client.get_component(name="peripheral_tests")
comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

status = platform.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp = client.get_component(name="led_snake")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp = client.get_component(name="peripheral_tests")
comp.build()

client.delete_component(name="led_snake")

client.delete_component(name="componentName")

client.delete_component(name="componentName")

status = platform.build()

comp.build()

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_blaze/export/platform_blaze/platform_blaze.xpfm",domain = "standalone_microblaze_0")

comp = client.get_component(name="led_snake")
status = comp.import_files(from_loc="", files=["/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/led_snake/src/led_snake.c"], is_skip_copy_sources = False)

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

status = platform.build()

comp = client.get_component(name="peripheral_tests")
comp.build()

status = platform.build()

comp = client.get_component(name="led_snake")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp = client.get_component(name="peripheral_tests")
comp.build()

status = platform.build()

comp.build()

component = client.get_component(name="peripheral_tests")

lscript = component.get_ld_script(path="/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_2/vitis/peripheral_tests/src/lscript.ld")

lscript.add_memory_region("new_memory_0", "0x0000", "0x8000")

lscript.update_memory_region("microblaze_0_local_memory_dlmb_bram_if_cntlr_memory_0", "0x50", "0x7fb0")

status = platform.build()

comp.build()

status = platform.build()

comp = client.get_component(name="led_snake")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

status = platform.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

status = platform.build()

comp.build()

client.delete_component(name="peripheral_tests")

client.delete_component(name="componentName")

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

