# 2026-10-11T11:31:01.701082837
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="platform_microblaze")
status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

status = platform.build()

comp.build()

vitis.dispose()

