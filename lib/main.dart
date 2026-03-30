import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/relazione_provider.dart';
import 'screens/archivio_screen.dart';
import 'screens/dati_cantiere_screen.dart';
import 'screens/problematiche_screen.dart';
import 'screens/gas_traccianti_screen.dart';
import 'screens/verifiche_strumentali_screen.dart';
import 'screens/ripristino_iniezioni_screen.dart';
import 'screens/vulnerabilita_screen.dart';
import 'screens/cause_consigli_screen.dart';

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
      home: const ArchivioScreen(),
      routes: {
        '/dati_cantiere':       (ctx) => const DatiCantiereScreen(),
        '/problematiche':       (ctx) => const ProblematicheScreen(),
        '/gas_screen':          (ctx) => const GasTraccianiScreen(),
        '/igrometria_screen':   (ctx) => const VerificheStrumentaliScreen(),
        '/termografia_screen':  (ctx) => const RipristoIniezioniScreen(),
        '/vulnerabilita_screen':(ctx) => const VulnerabilitaScreen(),
        '/cause_consigli':      (ctx) => const CauseConsigliScreen(),
      },
    );
  }
}
