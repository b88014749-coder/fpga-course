# 2026-10-04T11:55:48.195144643
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="microblaze_platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

vitis.dispose()

