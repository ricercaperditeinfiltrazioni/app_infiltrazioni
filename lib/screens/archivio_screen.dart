import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        final d = jsonDecode(datiCantiere);

        // Formatta data
        String dataStr = 'Data non impostata';
        if (d['dataSopralluogo'] != null && d['dataSopralluogo'].toString().isNotEmpty) {
          try {
            final dt = DateTime.parse(d['dataSopralluogo']);
            dataStr = '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
          } catch (_) {
            dataStr = d['dataSopralluogo'].toString();
          }
        }

        final comune = (d['comune'] as String? ?? '').isNotEmpty ? d['comune'] : null;
        final cliente = (d['cliente'] as String? ?? '').isNotEmpty ? d['cliente'] : null;

        String titolo = comune ?? cliente ?? 'Cantiere senza nome';

        temp.add({
          'id': id,
          'json_completo': datiCantiere,
          'titolo': titolo,
          'comune': comune ?? '—',
          'cliente': cliente ?? '—',
          'data': dataStr,
          'foto_totali': (d['problematiche']?.length ?? 0) +
              (d['fotoGas']?.length ?? 0) +
              (d['fotoVulnerabilita']?.length ?? 0),
        });
      }
    }

    temp.sort((a, b) => b['id'].compareTo(a['id']));
    setState(() => _cantieriSalvati = temp);
  }

  Future<void> _eliminaCantiere(String id) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina cantiere'),
        content: const Text('Sei sicuro? L\'operazione non è reversibile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (conferma != true) return;

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
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _cantieriSalvati.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun cantiere salvato.\nPremi + per iniziare!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _cantieriSalvati.length,
              itemBuilder: (context, index) {
                final c = _cantieriSalvati[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[700],
                      child: const Icon(Icons.home_work, color: Colors.white),
                    ),
                    title: Text(
                      c['titolo'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(c['data'], style: const TextStyle(fontSize: 13)),
                          ]),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_city, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Comune: ${c['comune']}', style: const TextStyle(fontSize: 13)),
                          ]),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.person, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Cliente: ${c['cliente']}', style: const TextStyle(fontSize: 13)),
                          ]),
                          if ((c['foto_totali'] as int) > 0) ...[
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.photo_camera, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('Foto: ${c['foto_totali']}', style: const TextStyle(fontSize: 13)),
                            ]),
                          ],
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _eliminaCantiere(c['id']),
                    ),
                    onTap: () {
                      Provider.of<RelazioneProvider>(context, listen: false)
                          .apriCantiere(c['id'], c['json_completo']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DatiCantiereScreen()),
                      ).then((_) => _caricaArchivio());
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[700],
        onPressed: () {
          Provider.of<RelazioneProvider>(context, listen: false).nuovoCantiere();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DatiCantiereScreen()),
          ).then((_) => _caricaArchivio());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuovo Cantiere', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
