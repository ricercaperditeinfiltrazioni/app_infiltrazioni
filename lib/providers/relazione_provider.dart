import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RelazioneProvider with ChangeNotifier {
  String dataSopralluogo = ''; // NUOVO CAMPO
  String referente = 'Sig.';
  String comune = '';
  String provincia = '';
  String cap = '';
  String viaCivico = '';
  
  List<Map<String, dynamic>> problematiche = [];

  Future<void> caricaDatiSalvati() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('bozza_corrente');
    
   if (datiString != null) {
      final dati = jsonDecode(datiString);
      dataSopralluogo = dati['dataSopralluogo'] ?? ''; // NUOVO
      referente = dati['referente'] ?? 'Sig.';
      comune = dati['comune'] ?? '';
      provincia = dati['provincia'] ?? '';
      cap = dati['cap'] ?? '';
      viaCivico = dati['viaCivico'] ?? '';
      if (dati['problematiche'] != null) {
        problematiche = List<Map<String, dynamic>>.from(dati['problematiche']);
      }
      notifyListeners();
    }
  }

 Future<void> salvaDatiInAutomatico() async {
    final prefs = await SharedPreferences.getInstance();
    final dati = {
      'dataSopralluogo': dataSopralluogo, // NUOVO
      'referente': referente, 'comune': comune, 'provincia': provincia, 'cap': cap, 'viaCivico': viaCivico,
      'problematiche': problematiche,
    };
    await prefs.setString('bozza_corrente', jsonEncode(dati));
    notifyListeners();
  }

  void aggiornaData(String nuovaData) {
    dataSopralluogo = nuovaData;
    salvaDatiInAutomatico();
  }

  void aggiornaDato({String? nuovoReferente, String? nuovoComune, String? nuovaProvincia, String? nuovoCap, String? nuovaVia}) {
    if (nuovoReferente != null) referente = nuovoReferente;
    if (nuovoComune != null) comune = nuovoComune;
    if (nuovaProvincia != null) provincia = nuovaProvincia;
    if (nuovoCap != null) cap = nuovoCap;
    if (nuovaVia != null) viaCivico = nuovaVia;
    salvaDatiInAutomatico();
  }

  // NUOVO: Salva fisicamente la foto in una cartella Giorno_Cantiere
  Future<void> aggiungiProblematica(String pathFoto, String tipologia, String nota) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0]; // Es: 2026-03-27
      final nomeCantiere = comune.isNotEmpty ? comune.replaceAll(' ', '_') : 'Sconosciuto';
      final cartellaCantiere = Directory('${directory.path}/${dataOggi}_$nomeCantiere');
      
      if (!await cartellaCantiere.exists()) {
        await cartellaCantiere.create(recursive: true);
      }

      final estensione = path.extension(pathFoto);
      final nuovoNomeFile = 'Foto_${DateTime.now().millisecondsSinceEpoch}$estensione';
      final nuovoPath = '${cartellaCantiere.path}/$nuovoNomeFile';

      await File(pathFoto).copy(nuovoPath);

      problematiche.add({
        'path': nuovoPath, // Salva il percorso definitivo
        'tipologia': tipologia,
        'nota': nota,
        'cancellata': false, // Di default NON è cancellata
      });
      salvaDatiInAutomatico();
    } catch (e) {
      print("Errore salvataggio foto: $e");
    }
  }
  
  // NUOVO: Cancellazione morbida (rende la foto trasparente)
  void impostaCancellata(int index, bool stato) {
    problematiche[index]['cancellata'] = stato;
    salvaDatiInAutomatico();
  }

  // Se vuoi eliminarla definitivamente dopo (opzionale)
  void eliminaDefinitiva(int index) {
    // Opzionale: cancella anche il file fisico
    // File(problematiche[index]['path']).deleteSync();
    problematiche.removeAt(index);
    salvaDatiInAutomatico();
  }
}
