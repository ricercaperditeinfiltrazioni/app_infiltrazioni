import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart'; // Importazione file

class RelazioneProvider with ChangeNotifier {
  String dataSopralluogo = '';
  String durataGiorni = '1 Giorno'; // NUOVA
  String referente = 'Sig.';
  String comune = '';
  String provincia = '';
  String cap = '';
  String viaCivico = '';
  
  List<Map<String, dynamic>> problematiche = [];
  List<Map<String, dynamic>> fotoGas = []; 
  List<Map<String, dynamic>> fotoStrumenti = []; 
  List<Map<String, dynamic>> fotoRipristini = []; // SEZIONE 5
  List<Map<String, dynamic>> fotoVulnerabilita = []; // SEZIONE 6

  Future<void> caricaDatiSalvati() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('bozza_corrente');
    if (datiString != null) _applicaJson(datiString);
  }

  void _applicaJson(String jsonString) {
    final dati = jsonDecode(jsonString);
    dataSopralluogo = dati['dataSopralluogo'] ?? '';
    durataGiorni = dati['durataGiorni'] ?? '1 Giorno';
    referente = dati['referente'] ?? 'Sig.';
    comune = dati['comune'] ?? '';
    provincia = dati['provincia'] ?? '';
    cap = dati['cap'] ?? '';
    viaCivico = dati['viaCivico'] ?? '';
    
    if (dati['problematiche'] != null) problematiche = List<Map<String, dynamic>>.from(dati['problematiche']);
    if (dati['fotoGas'] != null) fotoGas = List<Map<String, dynamic>>.from(dati['fotoGas']);
    if (dati['fotoStrumenti'] != null) fotoStrumenti = List<Map<String, dynamic>>.from(dati['fotoStrumenti']);
    if (dati['fotoRipristini'] != null) fotoRipristini = List<Map<String, dynamic>>.from(dati['fotoRipristini']);
    if (dati['fotoVulnerabilita'] != null) fotoVulnerabilita = List<Map<String, dynamic>>.from(dati['fotoVulnerabilita']);
    notifyListeners();
  }

  Future<void> salvaDatiInAutomatico() async {
    final prefs = await SharedPreferences.getInstance();
    final dati = {
      'dataSopralluogo': dataSopralluogo, 'durataGiorni': durataGiorni, 'referente': referente, 'comune': comune, 'provincia': provincia, 'cap': cap, 'viaCivico': viaCivico,
      'problematiche': problematiche, 'fotoGas': fotoGas, 'fotoStrumenti': fotoStrumenti, 'fotoRipristini': fotoRipristini, 'fotoVulnerabilita': fotoVulnerabilita
    };
    await prefs.setString('bozza_corrente', jsonEncode(dati));
    notifyListeners();
  }

  void aggiornaDato({String? nuovoReferente, String? nuovoComune, String? nuovaProvincia, String? nuovoCap, String? nuovaVia, String? nuovaDurata}) {
    if (nuovoReferente != null) referente = nuovoReferente;
    if (nuovoComune != null) comune = nuovoComune;
    if (nuovaProvincia != null) provincia = nuovaProvincia;
    if (nuovoCap != null) cap = nuovoCap;
    if (nuovaVia != null) viaCivico = nuovaVia;
    if (nuovaDurata != null) durataGiorni = nuovaDurata;
    salvaDatiInAutomatico();
  }

  void aggiornaData(String nuovaData) { dataSopralluogo = nuovaData; salvaDatiInAutomatico(); }

  // METODO GENERICO PER SALVARE FOTO NELLE VARIE LISTE E AGGIUNGERE IL "GIORNO"
  Future<void> _salvaFotoGenerico(String pathFoto, String tipologia, String nota, String giorno, List<Map<String, dynamic>> listaDestinazione, String prefisso) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory('${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : 'Sconosciuto'}');
      if (!await cartellaCantiere.exists()) await cartellaCantiere.create(recursive: true);
      final nuovoPath = '${cartellaCantiere.path}/${prefisso}_${DateTime.now().millisecondsSinceEpoch}${path.extension(pathFoto)}';
      await File(pathFoto).copy(nuovoPath);
      listaDestinazione.add({'path': nuovoPath, 'tipologia': tipologia, 'nota': nota, 'giorno': giorno, 'cancellata': false});
      salvaDatiInAutomatico();
    } catch (e) { print(e); }
  }

  Future<void> aggiungiProblematica(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, problematiche, 'Foto');
  Future<void> aggiungiFotoGas(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoGas, 'Gas');
  Future<void> aggiungiFotoStrumento(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoStrumenti, 'Strum');
  Future<void> aggiungiFotoRipristino(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoRipristini, 'Ripr'); // NUOVO
  Future<void> aggiungiFotoVulnerabilita(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoVulnerabilita, 'Vuln'); // NUOVO

  void impostaCancellata(int i, bool s, List<Map<String, dynamic>> l) { l[i]['cancellata'] = s; salvaDatiInAutomatico(); }

  Future<void> esportaBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('bozza_corrente');
    if (datiString != null) {
      final directory = await getTemporaryDirectory();
      final backupFile = File('${directory.path}/backup_${comune}.json');
      await backupFile.writeAsString(datiString);
      await Share.shareXFiles([XFile(backupFile.path)], text: 'Backup Cantiere $comune');
    }
  }

  // NUOVO: IMPORTAZIONE BACKUP
  Future<void> importaBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result != null) {
      File file = File(result.files.single.path!);
      String contenuto = await file.readAsString();
      _applicaJson(contenuto);
      salvaDatiInAutomatico();
    }
  }
}
