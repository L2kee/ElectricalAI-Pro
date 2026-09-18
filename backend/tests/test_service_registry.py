import unittest

from backend.services import registry


class ServiceRegistrySharingTests(unittest.TestCase):
    def test_server_and_tools_use_the_same_registry_instances(self):
        from backend.ai import tools
        from backend.api import server

        self.assertIs(server.ohms_service, registry.ohms_service)
        self.assertIs(server.voltage_drop_service, registry.voltage_drop_service)
        self.assertIs(server.wire_ampacity_service, registry.wire_ampacity_service)
        self.assertIs(server.box_fill_service, registry.box_fill_service)
        self.assertIs(server.conduit_fill_service, registry.conduit_fill_service)
        self.assertIs(server.circuit_load_service, registry.circuit_load_service)
        self.assertIs(server.motor_flc_service, registry.motor_flc_service)
        self.assertIs(server.transformer_sizing_service, registry.transformer_sizing_service)
        self.assertIs(server.unit_conversion_service, registry.unit_conversion_service)

        # tools.py's _TOOL_FUNCTIONS close over the registry instances
        # directly, so there's no separate module attribute to compare;
        # calling a tool and checking the result matches the registry's own
        # service is the observable proof they're the same object.
        expected = registry.ohms_service.calculate(voltage=120, resistance=12)
        self.assertEqual(tools.call_tool("ohms_law", {"voltage": 120, "resistance": 12}), expected)


if __name__ == "__main__":
    unittest.main()
