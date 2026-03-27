import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';
import '../providers/relazione_provider.dart';
import 'problematiche_screen.dart';
import 'gas_traccianti_screen.dart'; 
import 'verifiche_strumentali_screen.dart';
import 'ripristino_iniezioni_screen.dart'; // Import per la nuova Sezione 5
import 'cause_consigli_screen.dart'; // Importa la Sezione 7

class DatiCantiereScreen extends StatefulWidget {
  const DatiCantiereScreen({super.key});
  @override
  State<DatiCantiereScreen> createState() => _DatiCantiereScreenState();
}

class _DatiCantiereScreenState extends State<DatiCantiereScreen> {
  final List<String> _titoliReferente = ['Sig.', 'Sig.ra', 'Ing.', 'Arch.', 'Geom.', 'Amministratore', 'Altro'];
  final List<String> _tipiEdificio = ['Condominio', 'Abitazione singola', 'Box auto', 'Edificio Commerciale', 'Edificio Industriale', 'Altro'];
  final List<String> _anniEdificio = List.generate(127, (index) => (2026 - index).toString());
  
  final List<Map<String, String>> _databaseComuni = [
    {'comune': 'Vicenza', 'provincia': 'VI', 'cap': '36100'},
    {'comune': 'Verona', 'provincia': 'VR', 'cap': '37100'},
    {'comune': 'Padova', 'provincia': 'PD', 'cap': '35100'},
    {'comune': 'Venezia', 'provincia': 'VE', 'cap': '30100'},
    {'comune': 'Treviso', 'provincia': 'TV', 'cap': '31100'},
    {'comune': 'Rovigo', 'provincia': 'RO', 'cap': '45100'},
    {'comune': 'Belluno', 'provincia': 'BL', 'cap': '32100'},
    {'comune': 'Bassano del Grappa', 'provincia': 'VI', 'cap': '36061'},
    {'comune': 'Schio', 'provincia': 'VI', 'cap': '36015'},
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
      appBar: AppBar(
        title: const Text('1. Dati Generali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Importa Backup JSON',
            onPressed: () => provider.importaBackup(), // Tasto per importare
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Invia Backup (Telegram/WhatsApp)',
            onPressed: () => provider.esportaBackup(), // Tasto per esportare
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(decoration: BoxDecoration(color: Colors.blueAccent), child: Text('Fasi Sopralluogo', style: TextStyle(color: Colors.white, fontSize: 24))),
            ListTile(leading: const Icon(Icons.folder), title: const Text('Archivio Sopralluoghi'), onTap: () {}),
            const Divider(),
            ListTile(leading: const Icon(Icons.looks_one), title: const Text('1) Dati generali'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.looks_two), title: const Text('2) Aree infiltrazioni'), onTap: () {
                Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProblematicheScreen()));
            }),
            ListTile(leading: const Icon(Icons.looks_3), title: const Text('3) Localizz. gas tracciante'), onTap: () {
                Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const GasTracciantiScreen()));
            }),
            ListTile(leading: const Icon(Icons.looks_4), title: const Text('4) Verifiche strumentali'), onTap: () {
                Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificheStrumentaliScreen()));
            }),
            ListTile(leading: const Icon(Icons.looks_5), title: const Text('5) Ripristino iniezioni'), onTap: () {
                Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RipristinoIniezioniScreen())); // Collegamento Sezione 5
            }),
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
          children: [
            Row(children: [
                Expanded(child: TextFormField(key: Key(provider.dataSopralluogo), initialValue: provider.dataSopralluogo, decoration: const InputDecoration(labelText: 'Data Inizio', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)), onChanged: (val) => provider.aggiornaData(val))),
                const SizedBox(width: 16),
                // LA DURATA ORA COMANDA QUANTI GIORNI VEDI NELLE FOTO
                Expanded(child: DropdownButtonFormField<String>(value: provider.durataGiorni, items: ['Mezza giornata', '1 Giorno', '2 Giorni', '3 Giorni', 'Altro'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => provider.aggiornaDato(nuovaDurata: val), decoration: const InputDecoration(labelText: 'Durata', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
                Expanded(child: TextFormField(keyboardType: TextInputType.number, inputFormatters: [PatternInputFormatter(pattern: '##:##')], decoration: const InputDecoration(labelText: 'Orario Inizio', hintText: '09:00', border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time)))),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(keyboardType: TextInputType.number, inputFormatters: [PatternInputFormatter(pattern: '##:##')], decoration: const InputDecoration(labelText: 'Orario Fine', hintText: '17:30', border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time)))),
            ]),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(value: _titoliReferente.contains(provider.referente) ? provider.referente : 'Sig.', items: _titoliReferente.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => provider.aggiornaDato(nuovoReferente: val), decoration: const InputDecoration(labelText: 'Referente', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(flex: 2, child: DropdownButtonFormField<String>(value: 'Condominio', items: _tipiEdificio.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) {}, decoration: const InputDecoration(labelText: 'Tipo Edificio', border: OutlineInputBorder()))),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: DropdownButtonFormField<String>(value: '2026', items: _anniEdificio.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) {}, decoration: const InputDecoration(labelText: 'Anno', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Piani f.t.', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Piani interrati', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Interventi manutenzione precedenti', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Autocomplete<Map<String, String>>(
              initialValue: TextEditingValue(text: provider.comune),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Map<String, String>>.empty();
                return _databaseComuni.where((c) => c['comune']!.toLowerCase().startsWith(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (option) => option['comune']!,
              onSelected: (Map<String, String> selezione) { provider.aggiornaDato(nuovoComune: selezione['comune'], nuovaProvincia: selezione['provincia'], nuovoCap: selezione['cap']); setState(() {}); },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) { return TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'Comune (Solo Veneto)', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovoComune: val)); },
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextFormField(key: Key(provider.provincia), initialValue: provider.provincia, decoration: const InputDecoration(labelText: 'Provincia', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovaProvincia: val))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(key: Key(provider.cap), initialValue: provider.cap, decoration: const InputDecoration(labelText: 'CAP', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovoCap: val))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(flex: 3, child: TextFormField(initialValue: provider.viaCivico, decoration: const InputDecoration(labelText: 'Via/Piazza', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovaVia: val))),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: TextFormField(decoration: const InputDecoration(labelText: 'Civico', border: OutlineInputBorder()))),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.block, color: Colors.transparent), label: ''), 
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_forward), label: '2. Infiltrazioni'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProblematicheScreen()));
          }
        },
      ),
    );
  }
}
