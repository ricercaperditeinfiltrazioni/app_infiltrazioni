import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/casella_testo_vocale.dart';
import '../providers/relazione_provider.dart';
import 'gas_traccianti_screen.dart'; 

class ProblematicheScreen extends StatefulWidget {
  const ProblematicheScreen({super.key});
  @override
  State<ProblematicheScreen> createState() => _ProblematicheScreenState();
}

class _ProblematicheScreenState extends State<ProblematicheScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _tipologie = ['Altro', 'Distacco intonaco', 'Infiltrazione', 'Macchia', 'Muffa', 'Perdita', 'Rigonfiamento', 'Termografia', 'Umidità di risalita'];
  
  int _indiceSelezionato = 0; 

  Future<void> _scattaFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto == null) return; 

    if (!mounted) return;
    String tipologiaSelezionata = 'Infiltrazione';
    String notaInserita = '';
    bool infiltrazioneAttiva = false;
    bool presenzaAcquaPiove = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return AlertDialog(
              title: const Text('Dettagli Infiltrazione'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.file(File(foto.path), height: 150),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: tipologiaSelezionata,
                      items: _tipologie.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setStatePopup(() => tipologiaSelezionata = val!),
                      decoration: const InputDecoration(labelText: 'Tipologia problema'),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text("Infiltrazione attiva"),
                      value: infiltrazioneAttiva,
                      onChanged: (val) => setStatePopup(() => infiltrazioneAttiva = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text("Presenza d'acqua quando piove"),
                      value: presenzaAcquaPiove,
                      onChanged: (val) => setStatePopup(() => presenzaAcquaPiove = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    CasellaTestoVocale(
                      label: 'Note aggiuntive / Stanza',
                      valoreIniziale: notaInserita,
                      onChanged: (val) => notaInserita = val,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
                ElevatedButton(
                  onPressed: () {
                    String notaFinale = notaInserita;
                    if (infiltrazioneAttiva) notaFinale = "[ATTIVA] $notaFinale";
                    if (presenzaAcquaPiove) notaFinale = "[PIOVE] $notaFinale";

                    final prov = Provider.of<RelazioneProvider>(context, listen: false);
                    prov.aggiungiProblematica(foto.path, tipologiaSelezionata, notaFinale);
                    setState(() { _indiceSelezionato = prov.problematiche.length - 1; }); 
                    Navigator.pop(context);
                  },
                  child: const Text('Salva Foto'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);
    final list = provider.problematiche;
    
    if (_indiceSelezionato >= list.length && list.isNotEmpty) {
      _indiceSelezionato = list.length - 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('2. Aree Infiltrazioni')),
      body: list.isEmpty 
        ? const Center(child: Text('Nessuna foto inserita.\nPremi il tasto in basso.', textAlign: TextAlign.center))
        : Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    color: (list[_indiceSelezionato]['cancellata'] ?? false) ? Colors.grey.shade300 : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: (list[_indiceSelezionato]['cancellata'] ?? false) ? 0.3 : 1.0,
                            child: Image.file(File(list[_indiceSelezionato]['path']), fit: BoxFit.contain)
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
                                      "Foto #${_indiceSelezionato + 1} - ${list[_indiceSelezionato]['tipologia']}", 
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: (list[_indiceSelezionato]['cancellata'] ?? false) ? TextDecoration.lineThrough : null)
                                    ),
                                    Text(list[_indiceSelezionato]['nota']),
                                  ],
                                ),
                              ),
                              (list[_indiceSelezionato]['cancellata'] ?? false)
                                ? IconButton(icon: const Icon(Icons.restore, color: Colors.green, size: 30), onPressed: () => provider.impostaCancellata(_indiceSelezionato, false))
                                : IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 30), onPressed: () => provider.impostaCancellata(_indiceSelezionato, true)),
                            ],
                          ),
                        )
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
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: isSelezionata ? Colors.blue : Colors.transparent, width: 3),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Opacity(
                          opacity: isCancellata ? 0.3 : 1.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.file(File(item['path']), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scattaFoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scatta Foto'),
      ),
      // BARRA NAVIGAZIONE INFERIORE CORRETTA
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: '1. Dati Gen.'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_forward), label: '3. Gas Tracc.'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // Torna alla pagina 1
          } else if (index == 1) {
            Navigator.of(context).popUntil((route) => route.isFirst); // Torna alla home
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GasTracciantiScreen())); // Va alla pagina 3
          }
        },
      ),
    );
  }
}
