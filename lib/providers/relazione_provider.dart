import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart'; // Libreria per il Backup!

class RelazioneProvider with ChangeNotifier {
  String dataSopralluogo = '';
  String referente = 'Sig.';
  String comune = '';
  String provincia = '';
  String cap = '';
  String viaCivico = '';
  
  List<Map<String, dynamic>> problematiche = [];
  List<Map<String, dynamic>> fotoGas = []; 
  List<Map<String, dynamic>> fotoStrumenti = []; 

  Future<void> caricaDatiSalvati() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('bozza_corrente');
    
    if (datiString != null) {
      final dati = jsonDecode(datiString);
      dataSopralluogo = dati['dataSopralluogo'] ?? '';
      referente = dati['referente'] ?? 'Sig.';
      comune = dati['comune'] ?? '';
      provincia = dati['provincia'] ?? '';
      cap = dati['cap'] ?? '';
      viaCivico = dati['viaCivico'] ?? '';
      
      if (dati['problematiche'] != null) problematiche = List<Map<String, dynamic>>.from(dati['problematiche']);
      if (dati['fotoGas'] != null) fotoGas = List<Map<String, dynamic>>.from(dati['fotoGas']);
      if (dati['fotoStrumenti'] != null) fotoStrumenti = List<Map<String, dynamic>>.from(dati['fotoStrumenti']);
      
      notifyListeners();
    }
  }

  Future<void> salvaDatiInAutomatico() async {
    final prefs = await SharedPreferences.getInstance();
    final dati = {
      'dataSopralluogo': dataSopralluogo, 'referente': referente, 'comune': comune, 'provincia': provincia, 'cap': cap, 'viaCivico': viaCivico,
      'problematiche': problematiche, 'fotoGas': fotoGas, 'fotoStrumenti': fotoStrumenti,
    };
    await prefs.setString('bozza_corrente', jsonEncode(dati));
    notifyListeners();
  }

  void aggiornaDato({String? nuovoReferente, String? nuovoComune, String? nuovaProvincia, String? nuovoCap, String? nuovaVia}) {
    if (nuovoReferente != null) referente = nuovoReferente;
    if (nuovoComune != null) comune = nuovoComune;
    if (nuovaProvincia != null) provincia = nuovaProvincia;
    if (nuovoCap != null) cap = nuovoCap;
    if (nuovaVia != null) viaCivico = nuovaVia;
    salvaDatiInAutomatico();
  }

  void aggiornaData(String nuovaData) {
    dataSopralluogo = nuovaData;
    salvaDatiInAutomatico();
  }

  Future<void> aggiungiProblematica(String pathFoto, String tipologia, String nota) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory('${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : 'Sconosciuto'}');
      if (!await cartellaCantiere.exists()) await cartellaCantiere.create(recursive: true);
      final nuovoPath = '${cartellaCantiere.path}/Foto_${DateTime.now().millisecondsSinceEpoch}${path.extension(pathFoto)}';
      await File(pathFoto).copy(nuovoPath);
      problematiche.add({'path': nuovoPath, 'tipologia': tipologia, 'nota': nota, 'cancellata': false});
      salvaDatiInAutomatico();
    } catch (e) { print(e); }
  }
  void impostaCancellata(int index, bool stato) { problematiche[index]['cancellata'] = stato; salvaDatiInAutomatico(); }

  Future<void> aggiungiFotoGas(String pathFoto, String tipologia, String nota) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory('${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : 'Sconosciuto'}');
      if (!await cartellaCantiere.exists()) await cartellaCantiere.create(recursive: true);
      final nuovoPath = '${cartellaCantiere.path}/Gas_${DateTime.now().millisecondsSinceEpoch}${path.extension(pathFoto)}';
      await File(pathFoto).copy(nuovoPath);
      fotoGas.add({'path': nuovoPath, 'tipologia': tipologia, 'nota': nota, 'cancellata': false});
      salvaDatiInAutomatico();
    } catch (e) { print(e); }
  }
  void impostaGasCancellata(int index, bool stato) { fotoGas[index]['cancellata'] = stato; salvaDatiInAutomatico(); }

  Future<void> aggiungiFotoStrumento(String pathFoto, String tipologia, String nota) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory('${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : 'Sconosciuto'}');
      if (!await cartellaCantiere.exists()) await cartellaCantiere.create(recursive: true);
      final nuovoPath = '${cartellaCantiere.path}/Strum_${DateTime.now().millisecondsSinceEpoch}${path.extension(pathFoto)}';
      await File(pathFoto).copy(nuovoPath);
      fotoStrumenti.add({'path': nuovoPath, 'tipologia': tipologia, 'nota': nota, 'cancellata': false});
      salvaDatiInAutomatico();
    } catch (e) { print(e); }
  }
  void impostaStrumentoCancellata(int index, bool stato) { fotoStrumenti[index]['cancellata'] = stato; salvaDatiInAutomatico(); }

  // NUOVO: FUNZIONE DI BACKUP E CONDIVISIONE
  Future<void> esportaBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('bozza_corrente');
    
    if (datiString != null) {
      final directory = await getTemporaryDirectory();
      final nomeFile = comune.isNotEmpty ? comune.replaceAll(' ', '_') : 'cantiere';
      final backupFile = File('${directory.path}/backup_$nomeFile.json');
      await backupFile.writeAsString(datiString);
      
      // Apre finestra Telegram/Whatsapp
      await Share.shareXFiles([XFile(backupFile.path)], text: 'Backup Cantiere $comune');
    }
  }
}
