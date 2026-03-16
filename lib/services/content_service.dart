import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/flash_card.dart';
import '../models/question.dart';
import '../models/il_model.dart';

class ContentService {
  static ContentService? _instance;
  ContentService._();
  static ContentService get instance => _instance ??= ContentService._();

  List<FlashCard>?  _flashCards;
  List<Question>?   _questions;
  List<IlModel>?    _iller;

  Future<List<FlashCard>> getFlashCards({String? sinav, String? konu}) async {
    _flashCards ??= await _loadFlashCards();
    var result = _flashCards!;
    if (sinav != null) result = result.where((c) => c.sinav.contains(sinav)).toList();
    if (konu  != null) result = result.where((c) => c.konu == konu).toList();
    return result;
  }

  Future<List<Question>> getQuestions({String? sinav, String? konu}) async {
    _questions ??= await _loadQuestions();
    var result = _questions!;
    if (sinav != null) result = result.where((q) => q.sinav.contains(sinav)).toList();
    if (konu  != null) result = result.where((q) => q.konu == konu).toList();
    return result;
  }

  Future<List<IlModel>> getIller() async {
    _iller ??= await _loadIller();
    return _iller!;
  }

  Future<IlModel?> getIl(String id) async {
    final all = await getIller();
    try { return all.firstWhere((il) => il.id == id); }
    catch (_) { return null; }
  }

  List<String> get konular => [
    'bolgeler', 'iller', 'daglar', 'gol_deniz', 'akarsular', 'tarim', 'iklim',
  ];

  String konuAdi(String konu) {
    const map = {
      'bolgeler'  : '7 Bölge',
      'iller'     : 'İller',
      'daglar'    : 'Dağlar & Ovalar',
      'gol_deniz' : 'Göller & Denizler',
      'akarsular' : 'Akarsular',
      'tarim'     : 'Tarım & Bitkiler',
      'iklim'     : 'İklim & Toprak',
    };
    return map[konu] ?? konu;
  }

  String konuEmoji(String konu) {
    const map = {
      'bolgeler'  : '🗺️',
      'iller'     : '📍',
      'daglar'    : '🏔️',
      'gol_deniz' : '🌊',
      'akarsular' : '🌊',
      'tarim'     : '🌾',
      'iklim'     : '🌡️',
    };
    return map[konu] ?? '📚';
  }

  Future<List<FlashCard>> _loadFlashCards() async {
    final raw  = await rootBundle.loadString('assets/data/flash_cards.json');
    final list = json.decode(raw) as List;
    return list.map((e) => FlashCard.fromJson(e)).toList();
  }

  Future<List<Question>> _loadQuestions() async {
    final raw  = await rootBundle.loadString('assets/data/sorular.json');
    final list = json.decode(raw) as List;
    return list.map((e) => Question.fromJson(e)).toList();
  }

  Future<List<IlModel>> _loadIller() async {
    final raw  = await rootBundle.loadString('assets/data/iller.json');
    final list = json.decode(raw) as List;
    return list.map((e) => IlModel.fromJson(e)).toList();
  }
}
