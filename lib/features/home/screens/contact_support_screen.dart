import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/support_service.dart';
import '../../../core/services/auth_service.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    final user = await AuthService.getCurrentUser();
    final ticket = {
      'id': const Uuid().v4(),
      'userId': user?['id'] ?? 'anonymous',
      'subject': _subjectController.text.trim(),
      'message': _messageController.text.trim(),
      'status': 'open',
      'createdAt': DateTime.now().toIso8601String(),
    };

    await SupportService.submitTicket(ticket);

    if (!mounted) return;
    setState(() => _isSending = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Support request sent — our admin will review it.'),
    ));
    _subjectController.clear();
    _messageController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Describe the issue you are facing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please add a short subject'
                    : null,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message / Steps to reproduce',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please describe the issue'
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isSending ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor),
                child: _isSending
                    ? const CircularProgressIndicator()
                    : const Text('Send to Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
