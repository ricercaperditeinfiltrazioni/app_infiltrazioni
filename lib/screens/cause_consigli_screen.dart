import 'dart:io';
import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:painter/painter.dart';
import '../widgets/casella_testo_vocale.dart';
import '../providers/relazione_provider.dart';

class CauseConsigliScreen extends StatefulWidget {
  const CauseConsigliScreen({super.key});
  @override
  State<CauseConsigliScreen> createState() => _CauseConsigliScreenState();
}

class _CauseConsigliScreenState extends State<CauseConsigliScreen> {
  final ImagePicker _picker = ImagePicker();
  int _indiceSelezionato = 0; 

  Future<void> _scattaEDisegna(List<String> giornatePossibili, String giornoSalvato) async {
    final XFile? fotoOriginale = await _picker.pickImage(source: ImageSource.camera);
    if (fotoOriginale == null) return; 

    if (!mounted) return;
    String giornoSelezionato = giornatePossibili.contains(giornoSalvato) ? giornoSalvato : giornatePossibili.first;
    String notaInserita = '';
    
    PainterController controller = PainterController();
    controller.thickness = 5.0;
    controller.drawColor = Colors.red;
    controller.backgroundColor = Colors.transparent;

    bool salvato = false;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Disegna (Trascina il dito)"),
            actions: [
              IconButton(icon: const Icon(Icons.undo), onPressed: () => controller.undo()),
              IconButton(
                icon: const Icon(Icons.check, size: 30),
                onPressed: () async {
                  final picture = await controller.finish().toImage();
                  final byteData = await picture.toByteData(format: dart_ui.ImageByteFormat.png);
                  if (byteData != null) {
                    salvato = true;
                    Navigator.pop(context, byteData.buffer.asUint8List());
                  }
                },
              )
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: FileImage(File(fotoOriginale.path)), fit: BoxFit.contain)
            ),
            child: Painter(controller), // Qua puoi disegnare!
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.circle, color: Colors.red), onPressed: () => controller.drawColor = Colors.red),
              IconButton(icon: const Icon(Icons.circle, color: Colors.yellow), onPressed: () => controller.drawColor = Colors.yellow),
              IconButton(icon: const Icon(Icons.circle, color: Colors.green), onPressed: () => controller.drawColor = Colors.green),
            ],
          ),
        ),
      )
    ).then((byteImage) async {
      if (salvato && byteImage != null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStatePopup) {
                return AlertDialog(
                  title: const Text('Dettagli Foto Editata'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.memory(byteImage as dynamic, height: 150),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: giornoSelezionato,
                          items: giornatePossibili.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (val) {
                            setStatePopup(() => giornoSelezionato = val!);
                            Provider.of<RelazioneProvider>(context, listen: false).impostaUltimoGiornoSelezionato(val!);
                          },
                          decoration: const InputDecoration(labelText: 'Giorno rilevamento'),
                        ),
                        const SizedBox(height: 16),
                        CasellaTestoVocale(label: 'Didascalia Foto', valoreIniziale: notaInserita, onChanged: (val) => notaInserita = val),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
                    ElevatedButton(
                      onPressed: () {
                        final prov = Provider.of<RelazioneProvider>(context, listen: false);
                        prov.aggiungiFotoCausaDisegnata(fotoOriginale.path, byteImage as dynamic, notaInserita, giornoSelezionato);
                        setState(() { _indiceSelezionato = prov.fotoCause.length - 1; }); 
                        Navigator.pop(context);
                      },
                      child: const Text('Salva Definitivo'),
                    ),
                  ],
                );
              }
            );
          }
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);
    final list = provider.fotoCause;
    int numGiorni = 1;
    if (provider.durataGiorni.contains('2')) numGiorni = 2;
    if (provider.durataGiorni.contains('3')) numGiorni = 3;
    List<String> giornatePossibili = List.generate(numGiorni, (i) => "Giorno ${i+1}");

    if (_indiceSelezionato >= list.length && list.isNotEmpty) _indiceSelezionato = list.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('7. Cause e Consigli')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CasellaTestoVocale(
              label: 'Scrivi o detta la Relazione Conclusiva...',
              valoreIniziale: provider.noteCauseConsigli,
              maxLines: 8,
              onChanged: (val) => provider.aggiornaNoteCause(val),
            ),
          ),
          const Divider(),
          const Text("Foto Dimostrative Finali (con disegni)", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: list.isEmpty 
              ? const Center(child: Text('Nessuna foto dimostrativa.\nPremi il tasto in basso.', textAlign: TextAlign.center))
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
                              Expanded(child: Opacity(opacity: (list[_indiceSelezionato]['cancellata'] ?? false) ? 0.3 : 1.0, child: Image.file(File(list[_indiceSelezionato]['path_disegnato']), fit: BoxFit.contain))),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("[${list[_indiceSelezionato]['giorno'] ?? 'Giorno 1'}]", style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(list[_indiceSelezionato]['nota']),
                                        ],
                                      ),
                                    ),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => provider.impostaCancellata(_indiceSelezionato, true, provider.fotoCause)),
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
                              child: Image.file(File(list[index]['path_disegnato']), fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _scattaEDisegna(giornatePossibili, provider.ultimoGiornoSelezionato), icon: const Icon(Icons.brush), label: const Text('Disegna su Foto')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: '6. Vulnerab.'), BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Fine')],
        selectedItemColor: Colors.green, unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          else if (index == 1) Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}
