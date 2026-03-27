import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/relazione_provider.dart';
import 'problematiche_screen.dart';

class DatiCantiereScreen extends StatefulWidget {
  const DatiCantiereScreen({super.key});

  @override
  State<DatiCantiereScreen> createState() => _DatiCantiereScreenState();
}

class _DatiCantiereScreenState extends State<DatiCantiereScreen> {
  final List<String> _titoliReferente = ['Sig.', 'Sig.ra', 'Ing.', 'Arch.', 'Geom.', 'Amministratore', 'Altro'];

  // Database fittizio per ora (poi lo collegheremo al JSON completo di tutti i comuni italiani)
  final List<Map<String, String>> _databaseComuni = [
    {'comune': 'Vicenza', 'provincia': 'VI', 'cap': '36100'},
    {'comune': 'Verona', 'provincia': 'VR', 'cap': '37100'},
    {'comune': 'Padova', 'provincia': 'VR', 'cap': '35100'},
    {'comune': 'Roma', 'provincia': 'RM', 'cap': '00100'},
    {'comune': 'Milano', 'provincia': 'MI', 'cap': '20100'},
  ];

  @override
  void initState() {
    super.initState();
    // Imposta la data di oggi in automatico se è un nuovo sopralluogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<RelazioneProvider>(context, listen: false);
      if (p.dataSopralluogo.isEmpty) {
        final oggi = DateTime.now();
        p.aggiornaData("${oggi.day}/${oggi.month}/${oggi.year}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dati Cantiere')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text('Menù Ispezione', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(leading: const Icon(Icons.folder), title: const Text('Archivio Sopralluoghi'), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.home), title: const Text('1. Dati Cantiere e Date'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('2. Problematiche Segnalate'), onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProblematicheScreen()));
            }),
            ListTile(leading: const Icon(Icons.science), title: const Text('3. Indagini Termografiche/Igrom.'), onTap: () {}),
            ListTile(leading: const Icon(Icons.air), title: const Text('4. Gas Traccianti'), onTap: () {}),
            ListTile(leading: const Icon(Icons.build), title: const Text('5. Strumenti e Categorie'), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.restaurant), title: const Text('Foto Extra (Pranzo/Cena)'), onTap: () {}),
            ListTile(leading: const Icon(Icons.picture_as_pdf), title: const Text('Genera PDF / Word'), onTap: () {}),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data automatica e durata
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: Key(provider.dataSopralluogo),
                    initialValue: provider.dataSopralluogo,
                    decoration: const InputDecoration(labelText: 'Data Inizio', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                    onChanged: (val) => provider.aggiornaData(val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: '1 Giorno',
                    items: ['Mezza giornata', '1 Giorno', '2 Giorni', '3 Giorni', 'Altro'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {},
                    decoration: const InputDecoration(labelText: 'Durata', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Referente
            DropdownButtonFormField<String>(
              value: _titoliReferente.contains(provider.referente) ? provider.referente : 'Sig.',
              items: _titoliReferente.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => provider.aggiornaDato(nuovoReferente: val),
              decoration: const InputDecoration(labelText: 'Referente', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Autocompletamento Comune
            Autocomplete<Map<String, String>>(
              initialValue: TextEditingValue(text: provider.comune),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Map<String, String>>.empty();
                return _databaseComuni.where((c) => c['comune']!.toLowerCase().startsWith(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (option) => option['comune']!,
              onSelected: (Map<String, String> selezione) {
                // Quando selezioni un comune, compila tutto in automatico!
                provider.aggiornaDato(
                  nuovoComune: selezione['comune'],
                  nuovaProvincia: selezione['provincia'],
                  nuovoCap: selezione['cap']
                );
                // Forza l'aggiornamento grafico
                setState(() {});
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Comune (Inizia a digitare es. Vicenza...)', border: OutlineInputBorder()),
                  onChanged: (val) => provider.aggiornaDato(nuovoComune: val),
                );
              },
            ),
            const SizedBox(height: 16),

            // Campi Provincia e CAP che si auto-compilano
            Row(children: [
              Expanded(child: TextFormField(key: Key(provider.provincia), initialValue: provider.provincia, decoration: const InputDecoration(labelText: 'Provincia', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovaProvincia: val))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(key: Key(provider.cap), initialValue: provider.cap, decoration: const InputDecoration(labelText: 'CAP', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovoCap: val))),
            ]),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: provider.viaCivico,
              decoration: const InputDecoration(labelText: 'Via e Civico', border: OutlineInputBorder()),
              onChanged: (val) => provider.aggiornaDato(nuovaVia: val),
            ),
          ],
        ),
      ),
    );
  }
}
