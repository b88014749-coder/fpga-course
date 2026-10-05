# 2026-10-05T19:06:45.059189625
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "platform_ila",hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="platform_ila")
status = platform.build()

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_ila/export/platform_ila/platform_ila.xpfm",domain = "standalone_microblaze_0")

comp = client.get_component(name="led_snake")
status = comp.import_files(from_loc="", files=["/home/andy/opt/Xilinx/Projects/FPGA-Course/Lesson10/assignment10_2/vitis/led_snake/led_snake.c"], is_skip_copy_sources = False)

status = platform.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

status = platform.build()

comp.build()

vitis.dispose()

