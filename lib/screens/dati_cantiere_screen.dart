import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/relazione_provider.dart';
import 'problematiche_screen.dart';
import 'gas_traccianti_screen.dart'; // Import aggiunto per la Sezione 3

class DatiCantiereScreen extends StatefulWidget {
  const DatiCantiereScreen({super.key});
  @override
  State<DatiCantiereScreen> createState() => _DatiCantiereScreenState();
}

class _DatiCantiereScreenState extends State<DatiCantiereScreen> {
  final List<String> _titoliReferente = ['Sig.', 'Sig.ra', 'Ing.', 'Arch.', 'Geom.', 'Amministratore', 'Altro'];
  final List<String> _tipiEdificio = ['Condominio', 'Abitazione singola', 'Box auto', 'Edificio Commerciale', 'Edificio Industriale', 'Altro'];
  
  final List<Map<String, String>> _databaseComuni = [
    {'comune': 'Vicenza', 'provincia': 'VI', 'cap': '36100'},
    {'comune': 'Verona', 'provincia': 'VR', 'cap': '37100'},
    {'comune': 'Padova', 'provincia': 'PD', 'cap': '35100'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<RelazioneProvider>(context, listen: false);
      if (p.dataSopralluogo.isEmpty) p.aggiornaData("${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('1. Dati Generali')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text('Fasi Sopralluogo', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(leading: const Icon(Icons.folder), title: const Text('Archivio Sopralluoghi'), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.looks_one), title: const Text('1) Dati generali'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.looks_two), title: const Text('2) Aree infiltrazioni'), onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProblematicheScreen()));
            }),
            ListTile(leading: const Icon(Icons.looks_3), title: const Text('3) Localizz. gas tracciante'), onTap: () {
                // Collegamento funzionante per i Gas Traccianti
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GasTracciantiScreen()));
            }),
            ListTile(leading: const Icon(Icons.looks_4), title: const Text('4) Verifiche strumentali'), onTap: () {}),
            ListTile(leading: const Icon(Icons.looks_5), title: const Text('5) Ripristino iniezioni'), onTap: () {}),
            ListTile(leading: const Icon(Icons.looks_6), title: const Text('6) Potenziali vulnerabilità'), onTap: () {}),
            ListTile(leading: const Icon(Icons.looks_3, color: Colors.transparent), title: const Text('7) Cause e Consigli (Note)'), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.restaurant), title: const Text('Foto Pranzo/Cena/Hotel'), onTap: () {}),
            ListTile(leading: const Icon(Icons.picture_as_pdf), title: const Text('Genera PDF / Word'), onTap: () {}),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: TextFormField(key: Key(provider.dataSopralluogo), initialValue: provider.dataSopralluogo, decoration: const InputDecoration(labelText: 'Data Inizio', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)), onChanged: (val) => provider.aggiornaData(val))),
                const SizedBox(width: 16),
                Expanded(child: DropdownButtonFormField<String>(value: '1 Giorno', items: ['Mezza giornata', '1 Giorno', '2 Giorni', '3 Giorni', 'Altro'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) {}, decoration: const InputDecoration(labelText: 'Durata', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Orario Inizio', border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time)))),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Orario Fine', border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time)))),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(value: 'Condominio', items: _tipiEdificio.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) {}, decoration: const InputDecoration(labelText: 'Tipologia Edificio', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(value: _titoliReferente.contains(provider.referente) ? provider.referente : 'Sig.', items: _titoliReferente.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => provider.aggiornaDato(nuovoReferente: val), decoration: const InputDecoration(labelText: 'Referente', border: OutlineInputBorder())),
            const SizedBox(height: 16),

            Autocomplete<Map<String, String>>(
              initialValue: TextEditingValue(text: provider.comune),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Map<String, String>>.empty();
                return _databaseComuni.where((c) => c['comune']!.toLowerCase().startsWith(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (option) => option['comune']!,
              onSelected: (Map<String, String> selezione) {
                provider.aggiornaDato(nuovoComune: selezione['comune'], nuovaProvincia: selezione['provincia'], nuovoCap: selezione['cap']);
                setState(() {});
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'Comune (Inizia a digitare es. Vicenza...)', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovoComune: val));
              },
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: TextFormField(key: Key(provider.provincia), initialValue: provider.provincia, decoration: const InputDecoration(labelText: 'Provincia', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovaProvincia: val))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(key: Key(provider.cap), initialValue: provider.cap, decoration: const InputDecoration(labelText: 'CAP', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovoCap: val))),
            ]),
            const SizedBox(height: 16),
            TextFormField(initialValue: provider.viaCivico, decoration: const InputDecoration(labelText: 'Via e Civico', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovaVia: val)),
          ],
        ),
      ),
    );
  }
}
