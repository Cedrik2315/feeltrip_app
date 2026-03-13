import 'package:flutter/material.dart';
import '../../services/destination_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'CLP';
  final TextEditingController _amountController = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  double? _lastAmount;

  final List<DropdownMenuItem<String>> _currencies = [
    const DropdownMenuItem(value: 'USD', child: Text('USD 🇺🇸')),
    const DropdownMenuItem(value: 'EUR', child: Text('EUR 🇪🇺')),
    const DropdownMenuItem(value: 'ARS', child: Text('ARS 🇦🇷')),
    const DropdownMenuItem(value: 'CLP', child: Text('CLP 🇨🇱')),
    const DropdownMenuItem(value: 'BRL', child: Text('BRL 🇧🇷')),
    const DropdownMenuItem(value: 'MXN', child: Text('MXN 🇲🇽')),
    const DropdownMenuItem(value: 'COP', child: Text('COP 🇨🇴')),
    const DropdownMenuItem(value: 'PEN', child: Text('PEN 🇵🇪')),
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_convertCurrency);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _result = '';
    });
    _convertCurrency();
  }

  Future<void> _convertCurrency() async {
    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      setState(() => _result = '');
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      setState(() => _result = 'Monto inválido');
      return;
    }

    if (_lastAmount == amount && _fromCurrency == _toCurrency) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final conversion = await DestinationService.convertCurrency(
        _fromCurrency,
        _toCurrency,
        amount,
      );

      if (mounted) {
        setState(() {
          if (conversion != null) {
            _result = '${amount.toStringAsFixed(2)} $_fromCurrency\n'
                '= ${conversion.convertedAmount.toStringAsFixed(2)} $_toCurrency\n'
                '(Tasa: 1 $_fromCurrency = ${conversion.exchangeRate.toStringAsFixed(4)} $_toCurrency)';
            _lastAmount = amount;
          } else {
            _result = 'Error en la conversión. Verifica conexión.';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertidor de Monedas'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Color(0xFF4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _fromCurrency,
              decoration: InputDecoration(
                labelText: 'De',
                filled: true,
                fillColor: Colors.grey[50],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _currencies,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _fromCurrency = value);
                  _convertCurrency();
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: Colors.grey[50],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _swapCurrencies,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.swap_horiz, size: 30),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _toCurrency,
              decoration: InputDecoration(
                labelText: 'A',
                filled: true,
                fillColor: Colors.grey[50],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _currencies,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _toCurrency = value);
                  _convertCurrency();
                }
              },
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Color(0xFF4A148C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text('Convirtiendo...',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    )
                  else if (_result.isNotEmpty)
                    Text(
                      _result,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    const Text(
                      'Ingresa monto y selecciona monedas',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
