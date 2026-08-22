import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityStatus extends StatefulWidget {
  final Widget child;

  const ConnectivityStatus({super.key, required this.child});

  @override
  State<ConnectivityStatus> createState() => _ConnectivityStatusState();
}

class _ConnectivityStatusState extends State<ConnectivityStatus> {
  bool _isOffline = false;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();

    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateFromResults(results);
    } catch (_) {
      // Ignorer les erreurs de check initial
    }
  }

  void _updateFromResults(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (!mounted || _isOffline == offline) return;
    setState(() => _isOffline = offline);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateFromResults(results);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                color: const Color(0xFFFFF3CD),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(
                      Icons.cloud_off,
                      size: 18,
                      color: Color(0xFF8A5A00),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Hors ligne — les données affichées peuvent être obsolètes',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
