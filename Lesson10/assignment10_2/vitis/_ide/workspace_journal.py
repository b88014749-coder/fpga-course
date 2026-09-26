# 2026-09-26T10:30:06.552805601
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="platform_blaze")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../vivado/design_microblaze_wrapper.xsa")

status = platform.build()

status = platform.build()

comp = client.get_component(name="led_snake")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

