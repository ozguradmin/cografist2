class Question {
  final String id;
  final String soruMetni;
  final List<String> secenekler;
  final int dogruIndex;
  final String konu;
  final String aciklama;
  final List<String> sinav;
  final int zorluk;

  const Question({
    required this.id,
    required this.soruMetni,
    required this.secenekler,
    required this.dogruIndex,
    required this.konu,
    required this.aciklama,
    required this.sinav,
    this.zorluk = 1,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id:         j['id'],
        soruMetni:  j['soru'],
        secenekler: List<String>.from(j['secenekler']),
        dogruIndex: j['dogru'],
        konu:       j['konu'],
        aciklama:   j['aciklama'] ?? '',
        sinav:      List<String>.from(j['sinav'] ?? ['yks','kpss','lgs']),
        zorluk:     j['zorluk'] ?? 1,
      );

  String get dogruCevap => secenekler[dogruIndex];
}
