import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/telemetry_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool runnig = false;

  Future<void> _testConnection(BuildContext context, String ip) async {
    setState(() {
      runnig = true;
    });
    final url = 'http://$ip/metrics';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Provider.of<TelemetryProvider>(context, listen: false).setIp(ip);
        setState(() {
          runnig = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/data');
      } else {
        setState(() {
          runnig = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha na conexão: IP inválido')),
        );
      }
    } catch (e) {
      setState(() {
        runnig = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController ipController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 64,
            children: [
              Center(
                child: Card(
                  shape: CircleBorder(),
                  color: Colors.white,
                  elevation: 8,
                  child: Image(
                    height: MediaQuery.sizeOf(context).height * .2,
                    image: AssetImage('assets/images/logo_baja.png'),
                  ),
                ),
              ),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'Digite o IP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(1000),
                    ),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => !runnig
                    ? _testConnection(context, ipController.text)
                    : null,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                  padding: WidgetStatePropertyAll(EdgeInsets.all(6)),
                ),
                child: Center(
                  child: !runnig
                      ? const Text(
                          'CONECTAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
