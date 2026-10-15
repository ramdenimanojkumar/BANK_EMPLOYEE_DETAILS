import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';

class BackendConfigDialog extends StatefulWidget {
  final VoidCallback? onConfigurationChanged;

  const BackendConfigDialog({super.key, this.onConfigurationChanged});

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onConfigurationChanged,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) =>
          BackendConfigDialog(onConfigurationChanged: onConfigurationChanged),
    );
  }

  @override
  State<BackendConfigDialog> createState() => _BackendConfigDialogState();
}

class _BackendConfigDialogState extends State<BackendConfigDialog> {
  final _service = CustomerService();
  late final TextEditingController _urlController;
  bool _isTesting = false;
  bool? _testResult;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: CustomerService.apiBaseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final candidate = _urlController.text.trim();
    if (candidate.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
      _testMessage = null;
    });

    final success = await _service.checkBackendConnection(candidate);

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testResult = success;
      _testMessage = success
          ? 'Successfully connected to backend ($candidate/health/).'
          : 'Could not connect to $candidate/health/. Check server and CORS.';
    });
  }

  void _saveConfiguration() {
    final target = _urlController.text.trim();
    if (target.isNotEmpty) {
      CustomerService.setApiBaseUrl(target);
      widget.onConfigurationChanged?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API URL updated: ${CustomerService.apiBaseUrl}'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    }
  }

  void _resetToDefault() {
    CustomerService.resetApiBaseUrl();
    _urlController.text = CustomerService.apiBaseUrl;
    setState(() {
      _testResult = null;
      _testMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.blueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dns_rounded,
              color: AppTheme.blueAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Backend Connection',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navyPrimary,
                  ),
                ),
                Text(
                  'Django REST Framework + PostgreSQL Server',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the public or local API base endpoint where the Django server is hosted (e.g. Render, Railway, or localhost):',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                hintText: 'https://bank-customer-api.onrender.com/api',
                prefixIcon: const Icon(Icons.link_rounded, size: 20),
                suffixIcon: IconButton(
                  tooltip: 'Reset to default',
                  icon: const Icon(Icons.restore_rounded, size: 20),
                  onPressed: _resetToDefault,
                ),
              ),
              onChanged: (_) {
                setState(() {
                  _testResult = null;
                  _testMessage = null;
                });
              },
            ),
            const SizedBox(height: 12),

            // Quick presets
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Localhost (8000)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _urlController.text = 'http://127.0.0.1:8000/api';
                    setState(() {});
                  },
                ),
                ActionChip(
                  label: const Text('Android (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _urlController.text = 'http://10.0.2.2:8000/api';
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Test connection result alert
            if (_testMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testResult == true
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testResult == true
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult == true
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      color: _testResult == true
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testResult == true
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Test connection action
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_ping_rounded, size: 16),
              label: Text(_isTesting ? 'Testing Health...' : 'Test Connection'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(38),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveConfiguration,
          child: const Text('Save & Apply'),
        ),
      ],
    );
  }
}
