import 'package:flutter/material.dart';

import '../services/calculator_service.dart';

class ConduitFillScreen extends StatefulWidget {
  const ConduitFillScreen({super.key});

  @override
  State<ConduitFillScreen> createState() =>
      _ConduitFillScreenState();
}

class _ConduitFillScreenState
    extends State<ConduitFillScreen> {

  final CalculatorService _calculatorService =
      CalculatorService();

  final TextEditingController _conduitAreaController =
      TextEditingController();

  final TextEditingController _wireAreaController =
      TextEditingController();

  final TextEditingController _wireCountController =
      TextEditingController();

  bool _loading = false;

  String _statusMessage = "";

  double? _totalWireArea;

  double? _percentFill;

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim());
  }

  int? _parseInt(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return int.tryParse(value.trim());
  }

  Future<void> _calculate() async {

    final conduitArea =
        _parseDouble(_conduitAreaController.text);

    final wireArea =
        _parseDouble(_wireAreaController.text);

    final wireCount =
        _parseInt(_wireCountController.text);

    if (conduitArea == null ||
        wireArea == null ||
        wireCount == null) {

      setState(() {

        _statusMessage =
            "Please enter all values.";

        _totalWireArea = null;

        _percentFill = null;

      });

      return;
    }

    setState(() {

      _loading = true;

      _statusMessage = "";

      _totalWireArea = null;

      _percentFill = null;

    });

    try {

      final result =
          await _calculatorService.calculateConduitFill(

        conduitArea: conduitArea,

        wireArea: wireArea,

        wireCount: wireCount,

      );

      setState(() {

        _totalWireArea =
            (result["total_wire_area"] as num)
                .toDouble();

        _percentFill =
            (result["percent_fill"] as num)
                .toDouble();

        _statusMessage =
            "✓ Conduit Fill calculated successfully";

      });

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
        title: const Text("Conduit Fill Calculator"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const Icon(
              Icons.view_in_ar,
              size: 70,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            const Text(
              "Conduit Fill Calculator",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter conduit and wire information\n"
              "to calculate conduit fill.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [

                    buildField(
                      label: "Conduit Area",
                      hint: "Enter conduit area",
                      controller: _conduitAreaController,
                    ),

                    buildField(
                      label: "Wire Area",
                      hint: "Enter wire area",
                      controller: _wireAreaController,
                    ),

                    buildField(
                      label: "Wire Count",
                      hint: "Enter wire count",
                      controller: _wireCountController,
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            _loading ? null : _calculate,
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
                                  fontWeight:
                                      FontWeight.bold,
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

                      if (_totalWireArea != null &&
                          _percentFill != null) ...[
                        const SizedBox(height: 18),

                        const Divider(),

                        const SizedBox(height: 12),

                        const Text(
                          "Total Wire Area",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "${_totalWireArea!.toStringAsFixed(4)} sq. in.",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Conduit Fill",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "${_percentFill!.toStringAsFixed(2)}%",
                          style: const TextStyle(
                            fontSize: 32,
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
    _conduitAreaController.dispose();
    _wireAreaController.dispose();
    _wireCountController.dispose();
    super.dispose();
  }
}