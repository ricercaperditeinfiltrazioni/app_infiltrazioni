import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class RelazioneProvider with ChangeNotifier {
  // ID UNIVOCO DEL CANTIERE ATTUALE
  String cantiereId = '';

  String dataSopralluogo = '';
  String durataGiorni = '1 Giorno'; 
  String ultimoGiornoSelezionato = 'Giorno 1';
  String referente = 'Sig.';
  String comune = '';
  String provincia = '';
  String cap = '';
  String viaCivico = '';
  String noteCauseConsigli = ''; 
  
  List<Map<String, dynamic>> fotoCause = []; 
  List<Map<String, dynamic>> problematiche = [];
  List<Map<String, dynamic>> fotoGas = []; 
  List<Map<String, dynamic>> fotoStrumenti = []; 
  List<Map<String, dynamic>> fotoRipristini = []; 
  List<Map<String, dynamic>> fotoVulnerabilita = []; 

  // Crea un nuovo cantiere vuoto
  void nuovoCantiere() {
    cantiereId = DateTime.now().millisecondsSinceEpoch.toString(); // ID Unico
    dataSopralluogo = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    durataGiorni = '1 Giorno';
    ultimoGiornoSelezionato = 'Giorno 1';
    referente = 'Sig.';
    comune = ''; provincia = ''; cap = ''; viaCivico = ''; noteCauseConsigli = '';
    fotoCause = []; problematiche = []; fotoGas = []; fotoStrumenti = []; fotoRipristini = []; fotoVulnerabilita = [];
    salvaDatiInAutomatico();
    notifyListeners();
  }

  // Carica un cantiere specifico dall'archivio
  Future<void> apriCantiere(String idCantiere, String jsonString) async {
    cantiereId = idCantiere;
    _applicaJson(jsonString);
  }

  void _applicaJson(String jsonString) {
    final dati = jsonDecode(jsonString);
    dataSopralluogo = dati['dataSopralluogo'] ?? '';
    durataGiorni = dati['durataGiorni'] ?? '1 Giorno';
    ultimoGiornoSelezionato = dati['ultimoGiornoSelezionato'] ?? 'Giorno 1';
    referente = dati['referente'] ?? 'Sig.';
    comune = dati['comune'] ?? '';
    provincia = dati['provincia'] ?? '';
    cap = dati['cap'] ?? '';
    viaCivico = dati['viaCivico'] ?? '';
    noteCauseConsigli = dati['noteCauseConsigli'] ?? '';
    
    if (dati['problematiche'] != null) problematiche = List<Map<String, dynamic>>.from(dati['problematiche']);
    if (dati['fotoGas'] != null) fotoGas = List<Map<String, dynamic>>.from(dati['fotoGas']);
    if (dati['fotoStrumenti'] != null) fotoStrumenti = List<Map<String, dynamic>>.from(dati['fotoStrumenti']);
    if (dati['fotoRipristini'] != null) fotoRipristini = List<Map<String, dynamic>>.from(dati['fotoRipristini']);
    if (dati['fotoVulnerabilita'] != null) fotoVulnerabilita = List<Map<String, dynamic>>.from(dati['fotoVulnerabilita']);
    if (dati['fotoCause'] != null) fotoCause = List<Map<String, dynamic>>.from(dati['fotoCause']);
    notifyListeners();
  }

  // Salva il cantiere non più come bozza, ma nel suo "cassetto" specifico
  Future<void> salvaDatiInAutomatico() async {
    if (cantiereId.isEmpty) return; // Sicurezza

    final prefs = await SharedPreferences.getInstance();
    final dati = {
      'cantiereId': cantiereId,
      'dataSopralluogo': dataSopralluogo, 'durataGiorni': durataGiorni, 'ultimoGiornoSelezionato': ultimoGiornoSelezionato,
      'referente': referente, 'comune': comune, 'provincia': provincia, 'cap': cap, 'viaCivico': viaCivico, 'noteCauseConsigli': noteCauseConsigli,
      'problematiche': problematiche, 'fotoGas': fotoGas, 'fotoStrumenti': fotoStrumenti, 'fotoRipristini': fotoRipristini, 'fotoVulnerabilita': fotoVulnerabilita, 'fotoCause': fotoCause
    };
    
    // Aggiorna l'elenco generale dei cantieri
    List<String> listaCantieri = prefs.getStringList('lista_cantieri') ?? [];
    if (!listaCantieri.contains(cantiereId)) {
      listaCantieri.add(cantiereId);
      await prefs.setStringList('lista_cantieri', listaCantieri);
    }
    
    // Salva i dati veri e propri
    await prefs.setString('cantiere_$cantiereId', jsonEncode(dati));
    notifyListeners();
  }

  // TUTTE LE ALTRE FUNZIONI IDENTICHE A PRIMA
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
  void aggiornaNoteCause(String note) { noteCauseConsigli = note; salvaDatiInAutomatico(); }
  void impostaUltimoGiornoSelezionato(String giorno) { ultimoGiornoSelezionato = giorno; salvaDatiInAutomatico(); }

  Future<void> _salvaFotoGenerico(String pathFoto, String tipologia, String nota, String giorno, List<Map<String, dynamic>> listaDestinazione, String prefisso) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory('${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : cantiereId}');
      if (!await cartellaCantiere.exists()) await cartellaCantiere.create(recursive: true);
      final nuovoPath = '${cartellaCantiere.path}/${prefisso}_${DateTime.now().millisecondsSinceEpoch}${path.extension(pathFoto)}';
      await File(pathFoto).copy(nuovoPath);
      listaDestinazione.add({'path': nuovoPath, 'tipologia': tipologia, 'nota': nota, 'giorno': giorno, 'cancellata': false});
      salvaDatiInAutomatico();
    } catch (e) { print(e); }
  }

  Future<void> aggiungiFotoCausaDisegnata(String pathOriginale, Uint8List byteDisegnati, String nota, String giorno) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory('${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : cantiereId}');
      if (!await cartellaCantiere.exists()) await cartellaCantiere.create(recursive: true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pathOrigSalvato = '${cartellaCantiere.path}/CauseOrig_${timestamp}${path.extension(pathOriginale)}';
      final pathDisegnato = '${cartellaCantiere.path}/CauseDisegno_${timestamp}.png';
      await File(pathOriginale).copy(pathOrigSalvato);
      final fileDisegnato = File(pathDisegnato);
      await fileDisegnato.writeAsBytes(byteDisegnati);
      fotoCause.add({'path_originale': pathOrigSalvato, 'path_disegnato': pathDisegnato, 'nota': nota, 'giorno': giorno, 'cancellata': false});
      salvaDatiInAutomatico();
    } catch (e) { print(e); }
  }

  Future<void> aggiungiProblematica(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, problematiche, 'Foto');
  Future<void> aggiungiFotoGas(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoGas, 'Gas');
  Future<void> aggiungiFotoStrumento(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoStrumenti, 'Strum');
  Future<void> aggiungiFotoRipristino(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoRipristini, 'Ripr');
  Future<void> aggiungiFotoVulnerabilita(String p, String t, String n, String g) => _salvaFotoGenerico(p, t, n, g, fotoVulnerabilita, 'Vuln'); 

  void impostaCancellata(int i, bool s, List<Map<String, dynamic>> l) { l[i]['cancellata'] = s; salvaDatiInAutomatico(); }

  Future<void> esportaBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('cantiere_$cantiereId');
    if (datiString != null) {
      final directory = await getTemporaryDirectory();
      final nomeFile = comune.isNotEmpty ? comune.replaceAll(' ', '_') : cantiereId;
      final backupFile = File('${directory.path}/backup_$nomeFile.json');
      await backupFile.writeAsString(datiString);
      await Share.shareXFiles([XFile(backupFile.path)], text: 'Backup Cantiere $comune');
    }
  }

  Future<void> importaBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result != null) {
      File file = File(result.files.single.path!);
      String contenuto = await file.readAsString();
      // Importando un backup, creiamo un nuovo ID per non sovrascrivere quello aperto
      cantiereId = DateTime.now().millisecondsSinceEpoch.toString();
      _applicaJson(contenuto);
      salvaDatiInAutomatico();
    }
  }
}
