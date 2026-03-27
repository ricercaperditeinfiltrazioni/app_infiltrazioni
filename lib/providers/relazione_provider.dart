import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RelazioneProvider with ChangeNotifier {
  String referente = 'Sig.';
  String comune = '';
  String provincia = '';
  String cap = '';
  String viaCivico = '';
  
  // NUOVO: Lista per salvare i dati delle problematiche (percorso foto, tipo, nota)
  List<Map<String, dynamic>> problematiche = [];

  Future<void> caricaDatiSalvati() async {
    final prefs = await SharedPreferences.getInstance();
    final datiString = prefs.getString('bozza_corrente');
    
    if (datiString != null) {
      final dati = jsonDecode(datiString);
      referente = dati['referente'] ?? 'Sig.';
      comune = dati['comune'] ?? '';
      provincia = dati['provincia'] ?? '';
      cap = dati['cap'] ?? '';
      viaCivico = dati['viaCivico'] ?? '';
      
      // Carica le foto salvate
      if (dati['problematiche'] != null) {
        problematiche = List<Map<String, dynamic>>.from(dati['problematiche']);
      }
      notifyListeners();
    }
  }

  Future<void> salvaDatiInAutomatico() async {
    final prefs = await SharedPreferences.getInstance();
    final dati = {
      'referente': referente,
      'comune': comune,
      'provincia': provincia,
      'cap': cap,
      'viaCivico': viaCivico,
      'problematiche': problematiche, // Salva le foto nel JSON
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

  // NUOVO: Metodo per aggiungere una foto scattata
  void aggiungiProblematica(String pathFoto, String tipologia, String nota) {
    problematiche.add({
      'path': pathFoto,
      'tipologia': tipologia,
      'nota': nota,
    });
    salvaDatiInAutomatico();
  }
  
  // NUOVO: Metodo per eliminare una foto se sbagliata
  void rimuoviProblematica(int index) {
    problematiche.removeAt(index);
    salvaDatiInAutomatico();
  }
}
