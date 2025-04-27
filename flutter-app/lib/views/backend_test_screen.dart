import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({Key? key}) : super(key: key);

  @override
  _BackendTestScreenState createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  bool _isLoading = false;
  String _message = "Not tested yet";

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _message = "Testing connection...";
    });

    try {
      final repository = context.read<SpringBackendRepository>();
      final isReachable = await repository.isBackendReachable();

      setState(() {
        _isLoading = false;
        _message = isReachable
            ? "Connection successful!"
            : "Failed to connect to backend";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backend Connection Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(
                _message,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _testBackendConnection,
              child: const Text("Test Connection"),
            ),
          ],
        ),
      ),
    );
  }
}
