import 'package:flutter/material.dart';

import '../services/calculator_service.dart';

class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({super.key});

  @override
  State<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends State<OhmsLawScreen> {
  final CalculatorService _calculatorService = CalculatorService();

  final TextEditingController _voltageController =
      TextEditingController();

  final TextEditingController _currentController =
      TextEditingController();

  final TextEditingController _resistanceController =
      TextEditingController();

  bool _loading = false;

  String _statusMessage = "";

  double? _parseValue(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim());
  }

  Future<void> _calculate() async {
    final voltage =
        _parseValue(_voltageController.text);

    final current =
        _parseValue(_currentController.text);

    final resistance =
        _parseValue(_resistanceController.text);

    int count = 0;

    if (voltage != null) count++;
    if (current != null) count++;
    if (resistance != null) count++;

    if (count != 2) {
      setState(() {
        _statusMessage =
            "Enter any TWO values.\nLeave the value you want calculated blank.";
      });

      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = "";
    });

    try {
      final result =
          await _calculatorService.calculateOhmsLaw(
        voltage: voltage,
        current: current,
        resistance: resistance,
      );

      if (result.containsKey("error")) {
        setState(() {
          _statusMessage = result["error"];
        });
      }

      else if (result.containsKey("voltage")) {

        _voltageController.text =
            result["voltage"].toStringAsFixed(2);

        setState(() {
          _statusMessage =
              "✓ Voltage calculated successfully";
        });
      }

      else if (result.containsKey("current")) {

        _currentController.text =
            result["current"].toStringAsFixed(2);

        setState(() {
          _statusMessage =
              "✓ Current calculated successfully";
        });
      }

      else if (result.containsKey("resistance")) {

        _resistanceController.text =
            result["resistance"].toStringAsFixed(2);

        setState(() {
          _statusMessage =
              "✓ Resistance calculated successfully";
        });
      }
    }

    catch (e) {

      setState(() {

        _statusMessage =
            "Error\n$e";

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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
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
          appBar: AppBar(
            title: const Text("Ohm's Law Calculator"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.bolt,
                  size: 70,
                  color: Colors.red,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Ohm's Law Calculator",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Enter any TWO values.\nLeave the value you want calculated blank.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 35),

                buildField(
                  label: "Voltage (V)",
                  hint: "120",
                  controller: _voltageController,
                ),

                buildField(
                  label: "Current (A)",
                  hint: "10",
                  controller: _currentController,
                ),

                buildField(
                  label: "Resistance (Ω)",
                  hint: "12",
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

                const SizedBox(height: 30),

                if (_statusMessage.isNotEmpty)
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
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
        _voltageController.dispose();
        _currentController.dispose();
        _resistanceController.dispose();

        super.dispose();
      }
    }