# 2026-10-10T21:36:45.533924516
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "platform_microblaze",hw_design = "$COMPONENT_LOCATION/../../vivado/freq_meter/design_1_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="platform_microblaze")
status = platform.build()

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../platform_microblaze/export/platform_microblaze/platform_microblaze.xpfm",domain = "standalone_microblaze_0")

status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

status = platform.build()

status = platform.build()

comp.build()

vitis.dispose()

