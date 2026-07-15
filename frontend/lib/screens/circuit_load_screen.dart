import 'package:flutter/material.dart';

import '../services/calculator_service.dart';

class CircuitLoadScreen extends StatefulWidget {
  const CircuitLoadScreen({super.key});

  @override
  State<CircuitLoadScreen> createState() => _CircuitLoadScreenState();
}

class _CircuitLoadScreenState extends State<CircuitLoadScreen> {
  final CalculatorService _calculatorService = CalculatorService();

  final TextEditingController _powerController = TextEditingController();
  final TextEditingController _voltageController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();

  bool _loading = false;
  String _statusMessage = "";
  String? _resultLabel;
  String? _resultValue;

  double? _parseValue(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim());
  }

  Future<void> _calculate() async {
    final power = _parseValue(_powerController.text);
    final voltage = _parseValue(_voltageController.text);
    final current = _parseValue(_currentController.text);

    int count = 0;
    if (power != null) count++;
    if (voltage != null) count++;
    if (current != null) count++;

    if (count != 2) {
      setState(() {
        _statusMessage = "Enter any TWO values.\nLeave the value you want calculated blank.";
        _resultLabel = null;
        _resultValue = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = "";
      _resultLabel = null;
      _resultValue = null;
    });

    try {
      final result = await _calculatorService.calculateCircuitLoad(
        power: power,
        voltage: voltage,
        current: current,
      );

      if (result.containsKey("error")) {
        setState(() {
          _statusMessage = result["error"].toString();
        });
      } else if (result.containsKey("power")) {
        setState(() {
          _resultLabel = "Power";
          _resultValue = "${(result["power"] as num).toDouble().toStringAsFixed(2)} W";
          _statusMessage = "✓ Power calculated successfully";
        });
      } else if (result.containsKey("voltage")) {
        setState(() {
          _resultLabel = "Voltage";
          _resultValue = "${(result["voltage"] as num).toDouble().toStringAsFixed(2)} V";
          _statusMessage = "✓ Voltage calculated successfully";
        });
      } else if (result.containsKey("current")) {
        setState(() {
          _resultLabel = "Current";
          _resultValue = "${(result["current"] as num).toDouble().toStringAsFixed(2)} A";
          _statusMessage = "✓ Current calculated successfully";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error\n$e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Widget buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Circuit Load Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.calculate, size: 70, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Circuit Load Calculator",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter any TWO values.\nLeave the value you want calculated blank.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 35),
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildField(
                      label: "Power (W)",
                      hint: "Enter power",
                      controller: _powerController,
                    ),
                    buildField(
                      label: "Voltage (V)",
                      hint: "Enter voltage",
                      controller: _voltageController,
                    ),
                    buildField(
                      label: "Current (A)",
                      hint: "Enter current",
                      controller: _currentController,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _calculate,
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "CALCULATE",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_statusMessage.isNotEmpty)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_resultLabel != null) ...[
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          _resultLabel!,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _resultValue!,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _powerController.dispose();
    _voltageController.dispose();
    _currentController.dispose();
    super.dispose();
  }
}
