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
  String cantiereId = '';

  String dataSopralluogo = '';
  DateTime? dataSopralluogoDate;
  String durataGiorni = '1 Giorno';
  String ultimoGiornoSelezionato = 'Giorno 1';
  String referente = 'Sig.';
  String comune = '';
  String provincia = '';
  String cap = '';
  String viaCivico = '';
  String cliente = '';
  String responsabile = '';
  String tecnico = '';
  String orarioArrivo = '08:00';
  String orarioPartenza = '17:00';
  String noteDatiCantiere = '';
  String noteCauseConsigli = '';

  List<Map<String, dynamic>> fotoCause = [];
  List<Map<String, dynamic>> problematiche = [];
  List<Map<String, dynamic>> fotoGas = [];
  List<Map<String, dynamic>> fotoStrumenti = [];
  List<Map<String, dynamic>> fotoRipristini = [];
  List<Map<String, dynamic>> fotoVulnerabilita = [];

  // Compatibilità con il vecchio DatiCantiereScreen
  DateTime? get dataSopralluogo2 => dataSopralluogoDate;

  void nuovoCantiere() {
    cantiereId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    dataSopralluogoDate = now;
    dataSopralluogo = '${now.day}/${now.month}/${now.year}';
    durataGiorni = '1 Giorno';
    ultimoGiornoSelezionato = 'Giorno 1';
    referente = 'Sig.';
    comune = ''; provincia = ''; cap = ''; viaCivico = '';
    cliente = ''; responsabile = ''; tecnico = '';
    orarioArrivo = '08:00'; orarioPartenza = '17:00';
    noteDatiCantiere = ''; noteCauseConsigli = '';
    fotoCause = []; problematiche = []; fotoGas = [];
    fotoStrumenti = []; fotoRipristini = []; fotoVulnerabilita = [];
    salvaDatiInAutomatico();
    notifyListeners();
  }

  // Usato dal nuovo DatiCantiereScreen
  void setDatiCantiere({
    required String cliente,
    required String comune,
    required String indirizzo,
    required String responsabile,
    required String tecnico,
    required String noteDatiCantiere,
    required String orarioArrivo,
    required String orarioPartenza,
    DateTime? dataSopralluogo,
  }) {
    this.cliente = cliente;
    this.comune = comune;
    this.viaCivico = indirizzo;
    this.responsabile = responsabile;
    this.tecnico = tecnico;
    this.noteDatiCantiere = noteDatiCantiere;
    this.orarioArrivo = orarioArrivo;
    this.orarioPartenza = orarioPartenza;
    if (dataSopralluogo != null) {
      dataSopralluogoDate = dataSopralluogo;
      this.dataSopralluogo =
          '${dataSopralluogo.day.toString().padLeft(2, '0')}/${dataSopralluogo.month.toString().padLeft(2, '0')}/${dataSopralluogo.year}';
    }
    salvaDatiInAutomatico();
    notifyListeners();
  }

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
    cliente = dati['cliente'] ?? '';
    responsabile = dati['responsabile'] ?? '';
    tecnico = dati['tecnico'] ?? '';
    orarioArrivo = dati['orarioArrivo'] ?? '08:00';
    orarioPartenza = dati['orarioPartenza'] ?? '17:00';
    noteDatiCantiere = dati['noteDatiCantiere'] ?? '';
    noteCauseConsigli = dati['noteCauseConsigli'] ?? '';

    // Ripristina data come DateTime
    if (dataSopralluogo.isNotEmpty) {
      try {
        final parti = dataSopralluogo.split('/');
        if (parti.length == 3) {
          dataSopralluogoDate = DateTime(
            int.parse(parti[2]),
            int.parse(parti[1]),
            int.parse(parti[0]),
          );
        }
      } catch (_) {}
    }

    if (dati['problematiche'] != null)
      problematiche = List<Map<String, dynamic>>.from(dati['problematiche']);
    if (dati['fotoGas'] != null)
      fotoGas = List<Map<String, dynamic>>.from(dati['fotoGas']);
    if (dati['fotoStrumenti'] != null)
      fotoStrumenti = List<Map<String, dynamic>>.from(dati['fotoStrumenti']);
    if (dati['fotoRipristini'] != null)
      fotoRipristini = List<Map<String, dynamic>>.from(dati['fotoRipristini']);
    if (dati['fotoVulnerabilita'] != null)
      fotoVulnerabilita =
          List<Map<String, dynamic>>.from(dati['fotoVulnerabilita']);
    if (dati['fotoCause'] != null)
      fotoCause = List<Map<String, dynamic>>.from(dati['fotoCause']);
    notifyListeners();
  }

  Future<void> salvaDatiInAutomatico() async {
    if (cantiereId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final dati = {
      'cantiereId': cantiereId,
      'dataSopralluogo': dataSopralluogo,
      'durataGiorni': durataGiorni,
      'ultimoGiornoSelezionato': ultimoGiornoSelezionato,
      'referente': referente,
      'comune': comune,
      'provincia': provincia,
      'cap': cap,
      'viaCivico': viaCivico,
      'cliente': cliente,
      'responsabile': responsabile,
      'tecnico': tecnico,
      'orarioArrivo': orarioArrivo,
      'orarioPartenza': orarioPartenza,
      'noteDatiCantiere': noteDatiCantiere,
      'noteCauseConsigli': noteCauseConsigli,
      'problematiche': problematiche,
      'fotoGas': fotoGas,
      'fotoStrumenti': fotoStrumenti,
      'fotoRipristini': fotoRipristini,
      'fotoVulnerabilita': fotoVulnerabilita,
      'fotoCause': fotoCause,
    };
    List<String> listaCantieri =
        prefs.getStringList('lista_cantieri') ?? [];
    if (!listaCantieri.contains(cantiereId)) {
      listaCantieri.add(cantiereId);
      await prefs.setStringList('lista_cantieri', listaCantieri);
    }
    await prefs.setString('cantiere_$cantiereId', jsonEncode(dati));
    notifyListeners();
  }

  void aggiornaDato({
    String? nuovoReferente,
    String? nuovoComune,
    String? nuovaProvincia,
    String? nuovoCap,
    String? nuovaVia,
    String? nuovaDurata,
  }) {
    if (nuovoReferente != null) referente = nuovoReferente;
    if (nuovoComune != null) comune = nuovoComune;
    if (nuovaProvincia != null) provincia = nuovaProvincia;
    if (nuovoCap != null) cap = nuovoCap;
    if (nuovaVia != null) viaCivico = nuovaVia;
    if (nuovaDurata != null) durataGiorni = nuovaDurata;
    salvaDatiInAutomatico();
  }

  void aggiornaData(String nuovaData) {
    dataSopralluogo = nuovaData;
    salvaDatiInAutomatico();
  }

  void aggiornaNoteCause(String note) {
    noteCauseConsigli = note;
    salvaDatiInAutomatico();
  }

  void impostaUltimoGiornoSelezionato(String giorno) {
    ultimoGiornoSelezionato = giorno;
    salvaDatiInAutomatico();
  }

  Future<void> _salvaFotoGenerico(
      String pathFoto,
      String tipologia,
      String nota,
      String giorno,
      List<Map<String, dynamic>> listaDestinazione,
      String prefisso) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory(
          '${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : cantiereId}');
      if (!await cartellaCantiere.exists())
        await cartellaCantiere.create(recursive: true);
      final nuovoPath =
          '${cartellaCantiere.path}/${prefisso}_${DateTime.now().millisecondsSinceEpoch}${path.extension(pathFoto)}';
      await File(pathFoto).copy(nuovoPath);
      listaDestinazione.add({
        'path': nuovoPath,
        'tipologia': tipologia,
        'nota': nota,
        'giorno': giorno,
        'cancellata': false
      });
      salvaDatiInAutomatico();
    } catch (e) {
      print(e);
    }
  }

  Future<void> aggiungiFotoCausaDisegnata(
      String pathOriginale, Uint8List byteDisegnati, String nota, String giorno) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataOggi = DateTime.now().toIso8601String().split('T')[0];
      final cartellaCantiere = Directory(
          '${directory.path}/${dataOggi}_${comune.isNotEmpty ? comune.replaceAll(' ', '_') : cantiereId}');
      if (!await cartellaCantiere.exists())
        await cartellaCantiere.create(recursive: true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pathOrigSalvato =
          '${cartellaCantiere.path}/CauseOrig_${timestamp}${path.extension(pathOriginale)}';
      final pathDisegnato =
          '${cartellaCantiere.path}/CauseDisegno_${timestamp}.png';
      await File(pathOriginale).copy(pathOrigSalvato);
      await File(pathDisegnato).writeAsBytes(byteDisegnati);
      fotoCause.add({
        'path_originale': pathOrigSalvato,
        'path_disegnato': pathDisegnato,
        'nota': nota,
        'giorno': giorno,
        'cancellata': false
      });
      salvaDatiInAutomatico();
    } catch (e) {
      print(e);
    }
  }

  Future<void> aggiungiProblematica(String p, String t, String n, String g) =>
      _salvaFotoGenerico(p, t, n, g, problematiche, 'Foto');
  Future<void> aggiungiFotoGas(String p, String t, String n, String g) =>
      _salvaFotoGenerico(p, t, n, g, fotoGas, 'Gas');
  Future<void> aggiungiFotoStrumento(String p, String t, String n, String g) =>
      _salvaFotoGenerico(p, t, n, g, fotoStrumenti, 'Strum');
  Future<void> aggiungiFotoRipristino(String p, String t, String n, String g) =>
      _salvaFotoGenerico(p, t, n, g, fotoRipristini, 'Ripr');
  Future<void> aggiungiFotoVulnerabilita(String p, String t, String n, String g) =>
      _salvaFotoGenerico(p, t, n, g, fotoVulnerabilita, 'Vuln');

  void impostaCancellata(int i, bool s, List<Map<String, dynamic>> l) {
    l[i]['cancellata'] = s;
    salvaDatiInAutomatico();
  }

  Future<void> esportaBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('cantiere_$cantiereId');
    if (datiString != null) {
      final directory = await getTemporaryDirectory();
      final nomeFile =
          comune.isNotEmpty ? comune.replaceAll(' ', '_') : cantiereId;
      final backupFile =
          File('${directory.path}/backup_$nomeFile.json');
      await backupFile.writeAsString(datiString);
      await Share.shareXFiles(
          [XFile(backupFile.path)], text: 'Backup Cantiere $comune');
    }
  }

  Future<void> importaBackup() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result != null) {
      File file = File(result.files.single.path!);
      String contenuto = await file.readAsString();
      cantiereId = DateTime.now().millisecondsSinceEpoch.toString();
      _applicaJson(contenuto);
      salvaDatiInAutomatico();
    }
  }
}
