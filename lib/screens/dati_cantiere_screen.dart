import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/relazione_provider.dart';

class DatiCantiereScreen extends StatefulWidget {
  const DatiCantiereScreen({super.key});

  @override
  State<DatiCantiereScreen> createState() => _DatiCantiereScreenState();
}

class _DatiCantiereScreenState extends State<DatiCantiereScreen> {
  final List<String> _orariDisponibili = [
    '07:00', '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30',
    '19:00', '19:30', '20:00'
  ];

  String _orarioArrivo = '08:00';
  String _orarioPartenza = '17:00';

  final _clienteCtrl = TextEditingController();
  final _comuneCtrl = TextEditingController();
  final _indirizzoCtrl = TextEditingController();
  final _responsabileCtrl = TextEditingController();
  final _tecnicoCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime? _dataSelezionata;

  @override
  void initState() {
    super.initState();
    _dataSelezionata = DateTime.now();
    final provider = Provider.of<RelazioneProvider>(context, listen: false);
    _clienteCtrl.text = provider.cliente;
    _comuneCtrl.text = provider.comune;
    _indirizzoCtrl.text = provider.viaCivico;
    _responsabileCtrl.text = provider.responsabile;
    _tecnicoCtrl.text = provider.tecnico;
    _noteCtrl.text = provider.noteDatiCantiere;
    if (provider.orarioArrivo.isNotEmpty) _orarioArrivo = provider.orarioArrivo;
    if (provider.orarioPartenza.isNotEmpty) _orarioPartenza = provider.orarioPartenza;
    if (provider.dataSopralluogo != null) _dataSelezionata = provider.dataSopralluogo;
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _comuneCtrl.dispose();
    _indirizzoCtrl.dispose();
    _responsabileCtrl.dispose();
    _tecnicoCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _salva() {
    final provider = Provider.of<RelazioneProvider>(context, listen: false);
    provider.setDatiCantiere(
      cliente: _clienteCtrl.text,
      comune: _comuneCtrl.text,
      indirizzo: _indirizzoCtrl.text,
      responsabile: _responsabileCtrl.text,
      tecnico: _tecnicoCtrl.text,
      noteDatiCantiere: _noteCtrl.text,
      orarioArrivo: _orarioArrivo,
      orarioPartenza: _orarioPartenza,
      dataSopralluogo: _dataSelezionata,
    );
  }

  Future<void> _selezionaData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelezionata ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('it', 'IT'),
    );
    if (picked != null) {
      setState(() => _dataSelezionata = picked);
    }
  }

  String get _dataFormattata {
    if (_dataSelezionata == null) return 'Seleziona data';
    return '${_dataSelezionata!.day.toString().padLeft(2, '0')}/'
        '${_dataSelezionata!.month.toString().padLeft(2, '0')}/'
        '${_dataSelezionata!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1. Dati Cantiere'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Salva',
            onPressed: () {
              _salva();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dati salvati')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- DATA SOPRALLUOGO ---
            const Text('Data Sopralluogo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_dataFormattata,
                  style: const TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _selezionaData,
            ),
            const SizedBox(height: 20),

            // --- DATI GENERALI ---
            const Text('Informazioni Generali',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _comuneCtrl,
              decoration: const InputDecoration(
                labelText: 'Comune',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              onChanged: (_) => _salva(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _indirizzoCtrl,
              decoration: const InputDecoration(
                labelText: 'Indirizzo Cantiere',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              onChanged: (_) => _salva(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _clienteCtrl,
              decoration: const InputDecoration(
                labelText: 'Cliente / Committente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (_) => _salva(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _responsabileCtrl,
              decoration: const InputDecoration(
                labelText: 'Responsabile / Amministratore',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.manage_accounts),
              ),
              onChanged: (_) => _salva(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _tecnicoCtrl,
              decoration: const InputDecoration(
                labelText: 'Tecnico Rilevatore',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.engineering),
              ),
              onChanged: (_) => _salva(),
            ),
            const SizedBox(height: 20),

            // --- ORARI ---
            const Text('Orari Sopralluogo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _orarioArrivo,
                    decoration: const InputDecoration(
                      labelText: 'Orario Arrivo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    items: _orariDisponibili
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) {
                      setState(() { if (v != null) _orarioArrivo = v; });
                      _salva();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _orarioPartenza,
                    decoration: const InputDecoration(
                      labelText: 'Orario Partenza',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time_filled),
                    ),
                    items: _orariDisponibili
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) {
                      setState(() { if (v != null) _orarioPartenza = v; });
                      _salva();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- NOTE ---
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note generali cantiere',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              onChanged: (_) => _salva(),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // --- MENU NAVIGAZIONE ---
            const Text('Sezioni Sopralluogo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              child: Column(
                children: [
                  _menuItem(Icons.water_damage, '2. Aree Problematiche', '/problematiche'),
                  const Divider(height: 1),
                  _menuItem(Icons.thermostat, '3. Termografia e Igrometro', '/igrometria_screen'),
                  const Divider(height: 1),
                  _menuItem(Icons.bubble_chart, '4. Gas Traccianti', '/gas_screen'),
                  const Divider(height: 1),
                  _menuItem(Icons.warning_amber, '5. Criticità Individuate', '/vulnerabilita_screen'),
                  const Divider(height: 1),
                  _menuItem(Icons.build, '6. Ripristino delle Aree', '/termografia_screen'),
                  const Divider(height: 1),
                  _menuItem(Icons.search, '7. Altre Potenziali Vulnerabilità', '/vulnerabilita_screen'),
                  const Divider(height: 1),
                  _menuItem(Icons.lightbulb, '8. Cause e Consigli', '/cause_consigli'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_forward), label: 'Avanti'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          _salva();
          if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
          if (index == 1) Navigator.pushNamed(context, '/problematiche');
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, String titolo, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(titolo),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _salva();
        Navigator.pushNamed(context, route);
      },
    );
  }
}
