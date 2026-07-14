import 'package:flutter/material.dart';

import '../services/calculator_service.dart';

class WireAmpacityScreen extends StatefulWidget {
  const WireAmpacityScreen({super.key});

  @override
  State<WireAmpacityScreen> createState() => _WireAmpacityScreenState();
}

class _WireAmpacityScreenState extends State<WireAmpacityScreen> {
  final CalculatorService _calculatorService = CalculatorService();

  bool _loading = false;

  String _statusMessage = "";

  int? _ampacity;

  String _selectedWireSize = "14 AWG";

  String _selectedTemperature = "90";

  final List<String> _wireSizes = [
    "14 AWG",
    "12 AWG",
    "10 AWG",
    "8 AWG",
    "6 AWG",
    "4 AWG",
    "3 AWG",
    "2 AWG",
    "1 AWG",
    "1/0 AWG",
    "2/0 AWG",
    "3/0 AWG",
    "4/0 AWG",
  ];

  final List<Map<String, String>> _temperatureRatings = [
    {"label": "60°C", "value": "60"},
    {"label": "75°C", "value": "75"},
    {"label": "90°C", "value": "90"},
  ];

  Future<void> _calculate() async {
    setState(() {
      _loading = true;

      _statusMessage = "";

      _ampacity = null;
    });

    try {
      final result = await _calculatorService.calculateWireAmpacity(
        wireSize: _selectedWireSize,

        temperatureRating: _selectedTemperature,
      );

      if (result.containsKey("ampacity")) {
        setState(() {
          _ampacity = (result["ampacity"] as num).toInt();

          _statusMessage = "✓ Ampacity calculated successfully";
        });
      } else {
        setState(() {
          _statusMessage = result["error"] ?? "Unexpected server response.";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wire Ampacity Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.cable, size: 70, color: Colors.red),

            const SizedBox(height: 20),

            const Text(
              "Wire Ampacity Calculator",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Select a wire size and\n"
              "temperature rating.",
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
                    const Text(
                      "Wire Size",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedWireSize,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _wireSizes.map((wire) {
                        return DropdownMenuItem(value: wire, child: Text(wire));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWireSize = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Temperature Rating",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedTemperature,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _temperatureRatings.map((temp) {
                        return DropdownMenuItem(
                          value: temp["value"],
                          child: Text(temp["label"]!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTemperature = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

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

                      if (_ampacity != null) ...[
                        const SizedBox(height: 18),

                        const Divider(),

                        const SizedBox(height: 12),

                        const Text(
                          "Allowable Ampacity",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "$_ampacity A",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          _selectedWireSize,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          "$_selectedTemperature°C",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
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
}
