// lib/constants/ankara_districts.dart

const List<String> ankaraDistricts = [
  "Akyurt",
  "Altındağ",
  "Ayaş",
  "Bala",
  "Beypazarı",
  "Çamlıdere",
  "Çankaya",
  "Çubuk",
  "Elmadağ",
  "Etimesgut",
  "Evren",
  "Gölbaşı",
  "Güdül",
  "Haymana",
  "Kahramankazan",
  "Kalecik",
  "Keçiören",
  "Kızılcahamam",
  "Mamak",
  "Nallıhan",
  "Polatlı",
  "Pursaklar",
  "Sincan",
  "Şereflikoçhisar",
  "Yenimahalle",
];

String normTr(String s) {
  // Not: "İ".toLowerCase() -> "i̇" (i + combining dot). Onu da temizliyoruz.
  final lower = s.toLowerCase().replaceAll('\u0307', '');

  return lower
      .replaceAll('ı', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c');
}

/// Address/vicinity içinde Ankara ilçesi geçiyorsa yakalar.
/// Örn: "Kızılay, Çankaya, Ankara" -> "Çankaya"
String? extractAnkaraDistrict(String address) {
  final a = normTr(address);

  // Daha doğru eşleşme için kelime bazlı arama:
  for (final d in ankaraDistricts) {
    final nd = normTr(d);
    final re = RegExp(r'(^|[^a-z0-9])' + RegExp.escape(nd) + r'([^a-z0-9]|$)');
    if (re.hasMatch(a)) return d;
  }

  // Bazı address formatlarında "/" geçebiliyor: "Çankaya/Ankara"
  // Üstteki regex çoğunu yakalıyor ama yine de fallback:
  for (final d in ankaraDistricts) {
    if (a.contains(normTr(d))) return d;
  }

  return null;
}
