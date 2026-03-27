import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/relazione_provider.dart';

class DatiCantiereScreen extends StatelessWidget {
  const DatiCantiereScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RelazioneProvider>(context);
    final titoli = ['Sig.', 'Sig.ra', 'Ing.', 'Arch.', 'Geom.', 'Amministratore', 'Altro'];

    return Scaffold(
      appBar: AppBar(title: const Text('Dati Cantiere')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: titoli.contains(provider.referente) ? provider.referente : 'Sig.',
              items: titoli.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => provider.aggiornaDato(nuovoReferente: val),
              decoration: const InputDecoration(labelText: 'Referente', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: provider.comune,
              decoration: const InputDecoration(labelText: 'Comune', border: OutlineInputBorder()),
              onChanged: (val) => provider.aggiornaDato(nuovoComune: val),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextFormField(initialValue: provider.provincia, decoration: const InputDecoration(labelText: 'Provincia', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovaProvincia: val))),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(initialValue: provider.cap, decoration: const InputDecoration(labelText: 'CAP', border: OutlineInputBorder()), onChanged: (val) => provider.aggiornaDato(nuovoCap: val))),
            ]),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: provider.viaCivico,
              decoration: const InputDecoration(labelText: 'Via e Civico', border: OutlineInputBorder()),
              onChanged: (val) => provider.aggiornaDato(nuovaVia: val),
            ),
          ],
        ),
      ),
    );
  }
}
