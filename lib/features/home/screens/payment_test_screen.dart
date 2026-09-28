import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../theme/app_theme.dart';

String buildReceiptSummary({
  required double amount,
  required String provider,
  required String phoneNumber,
  required String listingType,
  required String transactionId,
}) {
  final typeLabel =
      listingType.toLowerCase() == 'purchase' ? 'Purchase' : 'Rental';
  return 'Payment confirmed\n\n'
      'Transaction ID: $transactionId\n'
      'Type: $typeLabel\n'
      'Amount: TSh ${amount.toStringAsFixed(0)}\n'
      'Provider: $provider\n'
      'Phone: $phoneNumber\n\n'
      'Please keep this receipt for your records.';
}

class PaymentTestScreen extends StatefulWidget {
  final String? initialAmount;
  final String? initialDealerId;
  final String? initialCustomerId;
  final String? initialListingType;

  const PaymentTestScreen({
    super.key,
    this.initialAmount,
    this.initialDealerId,
    this.initialCustomerId,
    this.initialListingType,
  });

  @override
  State<PaymentTestScreen> createState() => _PaymentTestScreenState();
}

class _PaymentTestScreenState extends State<PaymentTestScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _dealerController;
  late final TextEditingController _customerController;
  late final TextEditingController _phoneController;
  String _listingType = 'rental';
  String _selectedProvider = 'Airtel';
  String _paymentStatus = 'Pending';
  String _paymentNote = '';
  bool _isLoading = false;

  late final String backendBase;

  double get _enteredAmount {
    return double.tryParse(_amountController.text.trim()) ?? 0.0;
  }

  double get _commissionAmount {
    final rate = _listingType == 'purchase' ? 0.08 : 0.05;
    return _enteredAmount * rate;
  }

  String get _commissionLabel {
    return _listingType == 'purchase' ? '8%' : '5%';
  }

  double get _dealerAmount {
    return _enteredAmount - _commissionAmount;
  }

  @override
  void initState() {
    super.initState();
    backendBase = AppConstants.getPaymentApiBase(Theme.of(context).platform);
    _amountController = TextEditingController(
      text: widget.initialAmount ?? '50000',
    );
    _dealerController = TextEditingController(
      text: widget.initialDealerId ?? 'dealer1',
    );
    _customerController = TextEditingController(
      text: widget.initialCustomerId ?? 'cust1',
    );
    _phoneController = TextEditingController(text: '0755123456');
    _listingType = widget.initialListingType ?? 'rental';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dealerController.dispose();
    _customerController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    if (_phoneController.text.trim().length < 8) {
      _showResult('Please enter a valid phone number for the payment.');
      return;
    }

    setState(() => _isLoading = true);
    final url = Uri.parse('$backendBase/create');
    final body = {
      'amount': _amountController.text.trim(),
      'dealerId': _dealerController.text.trim(),
      'customerId': _customerController.text.trim(),
      'listingType': _listingType,
    };
    try {
      final resp = await http.post(url, body: jsonEncode(body), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final paymentUrl = data['paymentUrl'] as String?;
        setState(() {
          _paymentStatus = 'Processing';
        });
        if (paymentUrl != null) {
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _showResult('Cannot open payment URL: $paymentUrl');
          }
        } else {
          _showResult('No paymentUrl in response');
        }
        setState(() {
          _paymentStatus = 'Confirmed';
        });
        _showResult(buildReceiptSummary(
          amount: _enteredAmount,
          provider: _selectedProvider,
          phoneNumber: _phoneController.text.trim(),
          listingType: _listingType,
          transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        ));
      } else {
        _showResult('Failed to create session: ${resp.statusCode}');
      }
    } catch (e) {
      _showResult('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResult(String msg) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Azam Pay Checkout'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Azam Pay Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Secure payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Status: $_paymentStatus'),
                  const SizedBox(height: 4),
                  Text(
                      'Complete the payment details below to confirm your ${_listingType == 'purchase' ? 'purchase' : 'rental'} request.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (TSh)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dealerController,
              decoration: const InputDecoration(labelText: 'Dealer ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(labelText: 'Customer ID'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _listingType,
              decoration: const InputDecoration(labelText: 'Transaction type'),
              items: const [
                DropdownMenuItem(value: 'rental', child: Text('Rental')),
                DropdownMenuItem(value: 'purchase', child: Text('Purchase'))
              ],
              onChanged: (v) => setState(() => _listingType = v ?? 'rental'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              decoration: const InputDecoration(labelText: 'Payment provider'),
              items: const [
                DropdownMenuItem(value: 'Airtel', child: Text('Airtel Money')),
                DropdownMenuItem(value: 'Vodacom', child: Text('Vodacom')),
              ],
              onChanged: (v) =>
                  setState(() => _selectedProvider = v ?? 'Airtel'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Payment note (optional)'),
              onChanged: (value) => _paymentNote = value,
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Commission rate: $_commissionLabel'),
                        ),
                        Expanded(
                          child: Text(
                            'Dealer share: TZS ${_dealerAmount.toStringAsFixed(0)}',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin commission: TZS ${_commissionAmount.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total amount: TZS ${_enteredAmount.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    Text('Provider: $_selectedProvider'),
                    const SizedBox(height: 8),
                    Text('Phone: ${_phoneController.text.trim()}'),
                    if (_paymentNote.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Note: $_paymentNote'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createSession,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Pay now with Azam Pay'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
                'This creates a realistic checkout flow and shows a payment receipt after the session is created.'),
          ],
        ),
      ),
    );
  }
}
