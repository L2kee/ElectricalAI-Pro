"""
ElectricalAI Pro

Voltage Drop Service
"""


class VoltageDropService:

    def calculate(self, current: float, resistance: float):

        voltage_drop = current * resistance

        return {
            "voltage_drop": round(voltage_drop, 2)
        }