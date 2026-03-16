class IlModel {
  final String id;
  final String svgId;
  final String ad;
  final String bolge;
  final int nufus;
  final int yuzolcumu;
  final List<String> onemliIlceler;
  final String cografi;
  final Map<String, String> sinavBilgisi;

  const IlModel({
    required this.id,
    required this.svgId,
    required this.ad,
    required this.bolge,
    required this.nufus,
    required this.yuzolcumu,
    required this.onemliIlceler,
    required this.cografi,
    required this.sinavBilgisi,
  });

  factory IlModel.fromJson(Map<String, dynamic> j) => IlModel(
        id:            j['id'],
        svgId:         j['svgId'],
        ad:            j['ad'],
        bolge:         j['bolge'],
        nufus:         j['nufus'] ?? 0,
        yuzolcumu:     j['yuzolcumu'] ?? 0,
        onemliIlceler: List<String>.from(j['onemliIlceler'] ?? []),
        cografi:       j['cografi'] ?? '',
        sinavBilgisi:  Map<String, String>.from(j['sinav'] ?? {}),
      );
}
