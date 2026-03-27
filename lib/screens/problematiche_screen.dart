import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/relazione_provider.dart';

class ProblematicheScreen extends StatefulWidget {
  const ProblematicheScreen({super.key});

  @override
  State<ProblematicheScreen> createState() => _ProblematicheScreenState();
}

class _ProblematicheScreenState extends State<ProblematicheScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _tipologie = ['Altro', 'Distacco intonaco', 'Infiltrazione', 'Macchia', 'Muffa', 'Perdita', 'Rigonfiamento', 'Termografia', 'Umidità di risalita'];

  Future<void> _scattaFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto == null) return; 

    if (!mounted) return;
    String tipologiaSelezionata = 'Infiltrazione';
    String notaInserita = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dettagli Rilevamento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(foto.path), height: 150),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipologiaSelezionata,
                  items: _tipologie.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => tipologiaSelezionata = val!,
                  decoration: const InputDecoration(labelText: 'Tipologia problema'),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Note aggiuntive (opzionale)', border: OutlineInputBorder()),
                  maxLines: 3,
                  onChanged: (val) => notaInserita = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                Provider.of<RelazioneProvider>(context, listen: false)
                    .aggiungiProblematica(foto.path, tipologiaSelezionata, notaInserita);
                Navigator.pop(context);
              },
              child: const Text('Salva Foto'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);
    final list = provider.problematiche;

    return Scaffold(
      appBar: AppBar(title: const Text('Problematiche Segnalate')),
      body: list.isEmpty 
        ? const Center(child: Text('Nessuna foto inserita.\nPremi il tasto in basso per scattare.', textAlign: TextAlign.center))
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final bool isCancellata = item['cancellata'] ?? false;

              return Card(
                color: isCancellata ? Colors.grey.shade300 : Colors.white,
                margin: const EdgeInsets.all(8.0),
                child: Opacity(
                  opacity: isCancellata ? 0.4 : 1.0, // Effetto trasparenza!
                  child: ListTile(
                    leading: Image.file(File(item['path']), width: 60, height: 60, fit: BoxFit.cover),
                    title: Text(
                      isCancellata ? 'CANCELLATA - ${item['tipologia']}' : item['tipologia'], 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isCancellata ? TextDecoration.lineThrough : null, // Riga sopra il testo
                        color: isCancellata ? Colors.red : Colors.black
                      )
                    ),
                    subtitle: Text(item['nota']),
                    trailing: isCancellata
                      ? IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          tooltip: 'Ripristina',
                          onPressed: () => provider.impostaCancellata(index, false),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Elimina',
                          onPressed: () => provider.impostaCancellata(index, true),
                        ),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scattaFoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scatta Foto'),
      ),
    );
  }
}
