import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/casella_testo_vocale.dart'; 
import '../providers/relazione_provider.dart';

class GasTracciantiScreen extends StatefulWidget {
  const GasTracciantiScreen({super.key});
  @override
  State<GasTracciantiScreen> createState() => _GasTracciantiScreenState();
}

class _GasTracciantiScreenState extends State<GasTracciantiScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _tipologie = ['Intradosso solaio', 'Estradosso solaio', 'Pozzetto', 'Attraversamento impiantistico', 'Altro'];
  int _indiceSelezionato = 0; 

  Future<void> _scattaFoto(List<String> giornatePossibili) async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto == null) return; 

    if (!mounted) return;
    String tipologiaSelezionata = 'Intradosso solaio';
    String giornoSelezionato = giornatePossibili.first;
    String notaInserita = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dettagli Punto Iniezione'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(foto.path), height: 150),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: giornoSelezionato,
                  items: giornatePossibili.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => giornoSelezionato = val!,
                  decoration: const InputDecoration(labelText: 'Giorno rilevamento'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipologiaSelezionata,
                  items: _tipologie.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => tipologiaSelezionata = val!,
                  decoration: const InputDecoration(labelText: 'Punto iniezione gas'),
                ),
                const SizedBox(height: 16),
                CasellaTestoVocale(label: 'Note aggiuntive', valoreIniziale: notaInserita, onChanged: (val) => notaInserita = val),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                final prov = Provider.of<RelazioneProvider>(context, listen: false);
                prov.aggiungiFotoGas(foto.path, tipologiaSelezionata, notaInserita, giornoSelezionato);
                setState(() { _indiceSelezionato = prov.fotoGas.length - 1; }); 
                Navigator.pop(context);
              },
              child: const Text('Salva Foto Gas'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);
    final list = provider.fotoGas;
    
    int numGiorni = 1;
    if (provider.durataGiorni.contains('2')) numGiorni = 2;
    if (provider.durataGiorni.contains('3')) numGiorni = 3;
    List<String> giornatePossibili = List.generate(numGiorni, (i) => "Giorno ${i+1}");

    if (_indiceSelezionato >= list.length && list.isNotEmpty) _indiceSelezionato = list.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('3. Gas Traccianti')),
      body: list.isEmpty 
        ? const Center(child: Text('Nessuna foto gas inserita.\nPremi il tasto in basso.', textAlign: TextAlign.center))
        : Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: (list[_indiceSelezionato]['cancellata'] ?? false) ? Colors.grey.shade300 : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Opacity(opacity: (list[_indiceSelezionato]['cancellata'] ?? false) ? 0.3 : 1.0, child: Image.file(File(list[_indiceSelezionato]['path']), fit: BoxFit.contain))),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("[${list[_indiceSelezionato]['giorno'] ?? 'Giorno 1'}] ${list[_indiceSelezionato]['tipologia']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(list[_indiceSelezionato]['nota']),
                                  ],
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => provider.impostaCancellata(_indiceSelezionato, true, provider.fotoGas)),
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
                    return GestureDetector(
                      onTap: () => setState(() => _indiceSelezionato = index),
                      child: Container(
                        width: 80, margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(border: Border.all(color: index == _indiceSelezionato ? Colors.blue : Colors.transparent, width: 3)),
                        child: Image.file(File(list[index]['path']), fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _scattaFoto(giornatePossibili), icon: const Icon(Icons.gas_meter), label: const Text('Aggiungi Foro')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: '2. Infiltrazioni'), BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.arrow_forward), label: '4. Verifiche')],
        selectedItemColor: Colors.blue, unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          else if (index == 1) Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}
