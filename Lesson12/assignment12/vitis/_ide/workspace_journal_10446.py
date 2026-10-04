# 2026-10-02T19:15:16.275858783
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="microblaze_platform")
status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

status = platform.build()

comp.build()

vitis.dispose()

