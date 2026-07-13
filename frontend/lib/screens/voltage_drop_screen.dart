import 'package:flutter/material.dart';

import '../services/calculator_service.dart';

class VoltageDropScreen extends StatefulWidget {
  const VoltageDropScreen({super.key});

  @override
  State<VoltageDropScreen> createState() => _VoltageDropScreenState();
}

class _VoltageDropScreenState extends State<VoltageDropScreen> {
  final CalculatorService _calculatorService = CalculatorService();

  final TextEditingController _currentController = TextEditingController();

  final TextEditingController _resistanceController = TextEditingController();

  bool _loading = false;

  String _statusMessage = "";

  double? _voltageDrop;

  double? _parseValue(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim());
  }

  Future<void> _calculate() async {
    final current = _parseValue(_currentController.text);

    final resistance = _parseValue(_resistanceController.text);

    if (current == null || resistance == null) {
      setState(() {
        _statusMessage = "Enter both Current and Resistance.";

        _voltageDrop = null;
      });

      return;
    }

    setState(() {
      _loading = true;

      _statusMessage = "";

      _voltageDrop = null;
    });

    try {
      final result = await _calculatorService.calculateVoltageDrop(
        current: current,

        resistance: resistance,
      );

      if (result.containsKey("voltage_drop")) {
        setState(() {
          _voltageDrop = (result["voltage_drop"] as num).toDouble();

          _statusMessage = "✓ Voltage Drop calculated successfully";
        });
      } else {
        setState(() {
          _statusMessage = "Unexpected response from server.";
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
      appBar: AppBar(title: const Text("Voltage Drop Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.electric_bolt, size: 70, color: Colors.red),

            const SizedBox(height: 20),

            const Text(
              "Voltage Drop Calculator",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter current and resistance\n"
              "to calculate voltage drop.",
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
                      label: "Current (A)",
                      hint: "Enter current",
                      controller: _currentController,
                    ),

                    buildField(
                      label: "Resistance (Ω)",
                      hint: "Enter resistance",
                      controller: _resistanceController,
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

                      if (_voltageDrop != null) ...[
                        const SizedBox(height: 18),

                        const Divider(),

                        const SizedBox(height: 12),

                        const Text(
                          "Voltage Drop",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "${_voltageDrop!.toStringAsFixed(2)} V",
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
    _currentController.dispose();
    _resistanceController.dispose();
    super.dispose();
  }
}
