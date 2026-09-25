# 2026-09-22T21:32:31.352404956
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "platform_zynq",hw_design = "$COMPONENT_LOCATION/../../vivado/zynq_ps_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

platform = client.get_component(name="platform_zynq")
status = platform.build()

comp = client.create_app_component(name="led_snake",platform = "$COMPONENT_LOCATION/../platform_zynq/export/platform_zynq/platform_zynq.xpfm",domain = "standalone_ps7_cortexa9_0")

status = platform.build()

comp = client.get_component(name="led_snake")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

