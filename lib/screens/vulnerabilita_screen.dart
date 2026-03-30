import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/casella_testo_vocale.dart';
import '../providers/relazione_provider.dart';

class VulnerabilitaScreen extends StatefulWidget {
  const VulnerabilitaScreen({super.key});
  @override
  State<VulnerabilitaScreen> createState() => _VulnerabilitaScreenState();
}

class _VulnerabilitaScreenState extends State<VulnerabilitaScreen> {
  final ImagePicker _picker = ImagePicker();
  
  final List<String> _tipologie = [
    'Tegola rotta/spostata',
    'Guaina lesionata',
    'Scossalina ostruita',
    'Sigillatura mancante',
    'Fessurazione muro',
    'Altro'
  ];
  
  int _indiceSelezionato = 0;

  Future<void> _scattaFoto(List<String> giornatePossibili) async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto == null) return;

    if (!mounted) return;
    String tipologiaSelezionata = 'Tegola rotta/spostata';
    String giornoSelezionato = giornatePossibili.first;
    String notaInserita = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dettagli Vulnerabilità'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(foto.path), height: 150),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: giornoSelezionato,
                  items: giornatePossibili
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => giornoSelezionato = val!,
                  decoration: const InputDecoration(labelText: 'Giorno rilevamento'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipologiaSelezionata,
                  items: _tipologie
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => tipologiaSelezionata = val!,
                  decoration: const InputDecoration(labelText: 'Tipo vulnerabilità'),
                ),
                const SizedBox(height: 16),
                CasellaTestoVocale(
                  label: 'Note / Consigli',
                  valoreIniziale: notaInserita,
                  onChanged: (val) => notaInserita = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                final prov = Provider.of<RelazioneProvider>(context, listen: false);
                prov.aggiungiFotoVulnerabilita(
                  foto.path,
                  tipologiaSelezionata,
                  notaInserita,
                  giornoSelezionato,
                );
                setState(() {
                  _indiceSelezionato = prov.fotoVulnerabilita.length - 1;
                });
                Navigator.pop(context);
              },
              child: const Text('Salva Foto'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);
    final list = provider.fotoVulnerabilita;

    int numGiorni = 1;
    if (provider.durataGiorni.contains('2')) numGiorni = 2;
    if (provider.durataGiorni.contains('3')) numGiorni = 3;
    List<String> giornatePossibili =
        List.generate(numGiorni, (i) => "Giorno ${i + 1}");

    if (_indiceSelezionato >= list.length && list.isNotEmpty) {
      _indiceSelezionato = list.length - 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('6. Potenziali Vulnerabilità')),
      body: list.isEmpty
          ? const Center(
              child: Text(
                'Nessuna vulnerabilità inserita.\nPremi il tasto in basso.',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: (list[_indiceSelezionato]['cancellata'] ?? false)
                          ? Colors.grey.shade300
                          : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Opacity(
                              opacity: (list[_indiceSelezionato]['cancellata'] ?? false)
                                  ? 0.3
                                  : 1.0,
                              child: Image.file(
                                File(list[_indiceSelezionato]['path']),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "[${list[_indiceSelezionato]['giorno'] ?? 'Giorno 1'}] ${list[_indiceSelezionato]['tipologia']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          decoration: (list[_indiceSelezionato]['cancellata'] ?? false)
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      Text(list[_indiceSelezionato]['nota']),
                                    ],
                                  ),
                                ),
                                (list[_indiceSelezionato]['cancellata'] ?? false)
                                    ? IconButton(
                                        icon: const Icon(Icons.restore,
                                            color: Colors.green, size: 30),
                                        onPressed: () => provider.impostaCancellata(
                                          _indiceSelezionato,
                                          false,
                                          provider.fotoVulnerabilita,
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 30),
                                        onPressed: () => provider.impostaCancellata(
                                          _indiceSelezionato,
                                          true,
                                          provider.fotoVulnerabilita,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final isCancellata = item['cancellata'] ?? false;
                      final isSelezionata = index == _indiceSelezionato;

                      return GestureDetector(
                        onTap: () => setState(() => _indiceSelezionato = index),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelezionata
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Opacity(
                            opacity: isCancellata ? 0.3 : 1.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.file(
                                File(item['path']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scattaFoto(giornatePossibili),
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Scatta Foto'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: '5. Ripristini',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward),
            label: '7. Cause (Note)',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 2) {
            Navigator.pushNamed(context, '/cause_consigli');
          }
        },
      ),
    );
  }
}
