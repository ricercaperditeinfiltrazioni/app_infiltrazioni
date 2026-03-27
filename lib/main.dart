import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/relazione_provider.dart';
import 'screens/archivio_screen.dart'; // ORA PARTE DALL'ARCHIVIO!

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RelazioneProvider()),
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
      title: 'App Infiltrazioni',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ArchivioScreen(), // HOME CAMBIATA
    );
  }
}
