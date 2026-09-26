# 2026-09-25T16:22:15.445360612
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="platform_blaze")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

client.delete_component(name="led_snake")

client.delete_component(name="componentName")

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_blaze/export/platform_blaze/platform_blaze.xpfm",domain = "standalone_microblaze_0")

client.delete_component(name="led_snake")

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_blaze/export/platform_blaze/platform_blaze.xpfm",domain = "standalone_microblaze_0")

comp = client.get_component(name="led_snake")
status = comp.import_files(from_loc="", files=["/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/led_snake/src/led_snake.c"], is_skip_copy_sources = False)

status = platform.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

client.delete_component(name="led_snake")

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_blaze/export/platform_blaze/platform_blaze.xpfm",domain = "standalone_microblaze_0")

status = comp.import_files(from_loc="", files=["/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/led_snake/src/led_snake.c"], is_skip_copy_sources = False)

vitis.dispose()

