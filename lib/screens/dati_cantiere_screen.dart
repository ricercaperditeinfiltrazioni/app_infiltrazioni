import 'package:flutter/material.dart';

class DatiCantiereScreen extends StatefulWidget {
  const DatiCantiereScreen({super.key});

  @override
  State<DatiCantiereScreen> createState() => _DatiCantiereScreenState();
}

class _DatiCantiereScreenState extends State<DatiCantiereScreen> {
  // Generiamo la lista degli orari dalle 07:00 alle 20:00 a scatti di 30 minuti
  final List<String> _orariDisponibili = [
    '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', 
    '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30',
    '19:00', '19:30', '20:00'
  ];

  String _orarioArrivo = '08:00';
  String _orarioPartenza = '17:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1. Dati Cantiere e Menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SEZIONE DATI GENERALI ---
            const Text(
              'Informazioni Generali', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cliente / Riferimento', 
                border: OutlineInputBorder(), 
                prefixIcon: Icon(Icons.person)
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Indirizzo Cantiere', 
                border: OutlineInputBorder(), 
                prefixIcon: Icon(Icons.location_on)
              ),
            ),
            const SizedBox(height: 16),
            
            // --- SEZIONE ORARI CON MENU A TENDINA ---
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
                    items: _orariDisponibili.map((String orario) {
                      return DropdownMenuItem<String>(
                        value: orario,
                        child: Text(orario),
                      );
                    }).toList(),
                    onChanged: (String? nuovoValore) {
                      setState(() {
                        if (nuovoValore != null) _orarioArrivo = nuovoValore;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _orarioPartenza,
                    decoration: const InputDecoration(
                      labelText: 'Orario Partenza',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    items: _orariDisponibili.map((String orario) {
                      return DropdownMenuItem<String>(
                        value: orario,
                        child: Text(orario),
                      );
                    }).toList(),
                    onChanged: (String? nuovoValore) {
                      setState(() {
                        if (nuovoValore != null) _orarioPartenza = nuovoValore;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // --- SEZIONE MENU NAVIGAZIONE ---
            const Text(
              'Navigazione Sezioni', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.looks_two, color: Colors.blue), 
                    title: const Text('2) Aree Infiltrazioni'), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16), 
                    onTap: () => Navigator.pushNamed(context, '/problematiche')
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.looks_3, color: Colors.blue), 
                    title: const Text('3) Ricerca Gas Tracciante'), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16), 
                    onTap: () => Navigator.pushNamed(context, '/gas_screen')
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.looks_4, color: Colors.blue), 
                    title: const Text('4) Igrometria e Umidità'), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16), 
                    onTap: () => Navigator.pushNamed(context, '/igrometria_screen')
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.looks_5, color: Colors.blue), 
                    title: const Text('5) Termografia'), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16), 
                    onTap: () => Navigator.pushNamed(context, '/termografia_screen')
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.looks_6, color: Colors.blue), 
                    title: const Text('6) Vulnerabilità'), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16), 
                    onTap: () => Navigator.pushNamed(context, '/vulnerabilita_screen')
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.blue), 
                    title: const Text('7) Cause e Consigli (Note)'), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16), 
                    onTap: () => Navigator.pushNamed(context, '/cause_consigli')
                  ),
                ],
              ),
            ),
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
          if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
          if (index == 1) Navigator.pushNamed(context, '/problematiche');
        },
      ),
    );
  }
}
