import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/relazione_provider.dart';
import 'screens/dati_cantiere_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final relazioneProvider = RelazioneProvider();
  await relazioneProvider.caricaDatiSalvati();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: relazioneProvider),
      ],
      child: const AppInfiltrazioni(),
    ),
  );
}

class AppInfiltrazioni extends StatelessWidget {
  const AppInfiltrazioni({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sopralluoghi Infiltrazioni',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DatiCantiereScreen(),
    );
  }
}
