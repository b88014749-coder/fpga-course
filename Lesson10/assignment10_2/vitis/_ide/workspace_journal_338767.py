# 2026-09-25T15:21:55.421037657
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "platform_blaze",hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="platform_blaze")
status = platform.build()

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_blaze/export/platform_blaze/platform_blaze.xpfm",domain = "standalone_microblaze_0")

comp = client.get_component(name="led_snake")
status = comp.import_files(from_loc="", files=["/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_1/vitis/led_snake/src/led_snake.c"], is_skip_copy_sources = False)

status = platform.build()

comp.build()

client.delete_component(name="led_snake")

client.delete_component(name="componentName")

client.delete_component(name="componentName")

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_blaze/export/platform_blaze/platform_blaze.xpfm",domain = "standalone_microblaze_0")

vitis.dispose()

