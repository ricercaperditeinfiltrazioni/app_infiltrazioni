import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/relazione_provider.dart';
import 'dati_cantiere_screen.dart';

class ArchivioScreen extends StatefulWidget {
  const ArchivioScreen({super.key});

  @override
  State<ArchivioScreen> createState() => _ArchivioScreenState();
}

class _ArchivioScreenState extends State<ArchivioScreen> {
  List<Map<String, dynamic>> _cantieriSalvati = [];

  @override
  void initState() {
    super.initState();
    _caricaArchivio();
  }

  Future<void> _caricaArchivio() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaIds = prefs.getStringList('lista_cantieri') ?? [];
    List<Map<String, dynamic>> temp = [];

    for (String id in listaIds) {
      String? datiCantiere = prefs.getString('cantiere_$id');
      if (datiCantiere != null) {
        final datiDecodificati = jsonDecode(datiCantiere);
        temp.add({
          'id': id,
          'json_completo': datiCantiere,
          'comune': datiDecodificati['comune']?.isNotEmpty == true ? datiDecodificati['comune'] : 'Nuovo Cantiere in Bozza',
          'data': datiDecodificati['dataSopralluogo'] ?? 'Data Sconosciuta',
          'foto_totali': (datiDecodificati['problematiche']?.length ?? 0) + (datiDecodificati['fotoGas']?.length ?? 0)
        });
      }
    }
    
    // Ordina dal più recente al più vecchio
    temp.sort((a, b) => b['id'].compareTo(a['id']));
    
    setState(() {
      _cantieriSalvati = temp;
    });
  }

  Future<void> _eliminaCantiere(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaIds = prefs.getStringList('lista_cantieri') ?? [];
    listaIds.remove(id);
    await prefs.setStringList('lista_cantieri', listaIds);
    await prefs.remove('cantiere_$id');
    _caricaArchivio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Cantieri', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _cantieriSalvati.isEmpty
          ? const Center(child: Text("Nessun cantiere salvato.\nPremi '+' per iniziare!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _cantieriSalvati.length,
              itemBuilder: (context, index) {
                final cantiere = _cantieriSalvati[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.home_work, color: Colors.white),
                    ),
                    title: Text(cantiere['comune'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('Data: ${cantiere['data']}\nFoto totali: ${cantiere['foto_totali']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _eliminaCantiere(cantiere['id']),
                    ),
                    onTap: () {
                      // APRE IL CANTIERE
                      Provider.of<RelazioneProvider>(context, listen: false).apriCantiere(cantiere['id'], cantiere['json_completo']);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DatiCantiereScreen())).then((_) => _caricaArchivio());
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Provider.of<RelazioneProvider>(context, listen: false).nuovoCantiere();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DatiCantiereScreen())).then((_) => _caricaArchivio());
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Cantiere'),
      ),
    );
  }
}
