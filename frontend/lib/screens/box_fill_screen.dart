import 'package:flutter/material.dart';

import '../services/calculator_service.dart';

class BoxFillScreen extends StatefulWidget {
  const BoxFillScreen({super.key});

  @override
  State<BoxFillScreen> createState() =>
      _BoxFillScreenState();
}

class _BoxFillScreenState
    extends State<BoxFillScreen> {

  final CalculatorService _calculatorService =
      CalculatorService();

  final TextEditingController _boxVolumeController =
      TextEditingController();

  final TextEditingController _conductorCountController =
      TextEditingController();

  final TextEditingController _conductorAllowanceController =
      TextEditingController();

  bool _loading = false;

  String _statusMessage = "";

  double? _requiredVolume;

  double? _remainingVolume;

  bool? _boxIsLargeEnough;

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

    final boxVolume =
        _parseDouble(_boxVolumeController.text);

    final conductorCount =
        _parseInt(_conductorCountController.text);

    final conductorAllowance =
        _parseDouble(
            _conductorAllowanceController.text);

    if (boxVolume == null ||
        conductorCount == null ||
        conductorAllowance == null) {

      setState(() {

        _statusMessage =
            "Please enter all values.";

        _requiredVolume = null;

        _remainingVolume = null;

        _boxIsLargeEnough = null;

      });

      return;
    }

    setState(() {

      _loading = true;

      _statusMessage = "";

      _requiredVolume = null;

      _remainingVolume = null;

      _boxIsLargeEnough = null;

    });

    try {

      final result =
          await _calculatorService.calculateBoxFill(

        boxVolume: boxVolume,

        conductorCount: conductorCount,

        conductorAllowance:
            conductorAllowance,

      );

      setState(() {

        _requiredVolume =
            (result["required_volume"] as num)
                .toDouble();

        _remainingVolume =
            (result["remaining_volume"] as num)
                .toDouble();

        _boxIsLargeEnough =
            result["box_is_large_enough"];

        _statusMessage =
            "✓ Box Fill calculated successfully";

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
        title: const Text("Box Fill Calculator"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const Icon(
              Icons.inventory_2,
              size: 70,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            const Text(
              "Box Fill Calculator",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter the box information\n"
              "to calculate box fill.",
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
                      label: "Box Volume (cu. in.)",
                      hint: "Enter box volume",
                      controller: _boxVolumeController,
                    ),

                    buildField(
                      label: "Conductor Count",
                      hint: "Enter conductor count",
                      controller: _conductorCountController,
                    ),

                    buildField(
                      label: "Conductor Allowance (cu. in.)",
                      hint: "Enter conductor allowance",
                      controller:
                          _conductorAllowanceController,
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
                                child:
                                    CircularProgressIndicator(
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

                      if (_requiredVolume != null &&
                          _remainingVolume != null &&
                          _boxIsLargeEnough != null) ...[

                        const SizedBox(height: 18),

                        const Divider(),

                        const SizedBox(height: 12),

                        const Text(
                          "Required Volume",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "${_requiredVolume!.toStringAsFixed(2)} cu. in.",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Remaining Volume",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "${_remainingVolume!.toStringAsFixed(2)} cu. in.",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          _boxIsLargeEnough!
                              ? "✔ Box is large enough"
                              : "✖ Box is NOT large enough",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _boxIsLargeEnough!
                                ? Colors.green
                                : Colors.red,
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
    _boxVolumeController.dispose();
    _conductorCountController.dispose();
    _conductorAllowanceController.dispose();
    super.dispose();
  }
}