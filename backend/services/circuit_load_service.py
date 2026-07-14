"""
ElectricalAI Pro

Circuit Load Service
"""


class CircuitLoadService:

    def calculate(self, power=None, voltage=None, current=None):

        values_provided = sum(
            value is not None
            for value in [power, voltage, current]
        )

        if values_provided != 2:
            return {
                "error": "Please provide exactly two values."
            }

        if power is None:
            return {
                "power": round(voltage * current, 2)
            }

        if voltage is None:
            return {
                "voltage": round(power / current, 2)
            }

        return {
            "current": round(power / voltage, 2)
        }
