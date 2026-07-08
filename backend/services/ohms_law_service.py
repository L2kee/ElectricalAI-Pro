"""
ElectricalAI Pro

Ohm's Law Service
"""


class OhmsLawService:

    def calculate(self, voltage=None, current=None, resistance=None):

        values_provided = sum(
            value is not None
            for value in [voltage, current, resistance]
        )

        if values_provided != 2:
            return {
                "error": "Please provide exactly two values."
            }

        if voltage is None:
            return {
                "voltage": current * resistance
            }

        if current is None:
            return {
                "current": voltage / resistance
            }

        return {
            "resistance": voltage / current
        }