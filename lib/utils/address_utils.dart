class AddressParts {
  final String district; // ilçe
  final String city;     // il
  const AddressParts(this.district, this.city);
}

AddressParts parseDistrictCity(String? address) {
  if (address == null || address.trim().isEmpty) {
    return const AddressParts('Bilinmiyor', 'Ankara');
  }

  final a = address.trim();

  // Sık görülen format: "Çankaya/Ankara, Türkiye"
  final slash = RegExp(r'([^,/]+)\s*/\s*([^,]+)').firstMatch(a);
  if (slash != null) {
    final district = slash.group(1)!.trim();
    final city = slash.group(2)!.trim();
    return AddressParts(district, city);
  }

  // Virgülle ayrılmış formatlardan sezgisel seçim:
  // örn: "Kızılay, Çankaya, Ankara" veya "Çankaya, Ankara"
  final parts = a.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (parts.length >= 2) {
    final city = parts.last;
    final district = parts[parts.length - 2];
    return AddressParts(district, city);
  }

  // Hiçbir şey uymadıysa Ankara varsay
  return AddressParts(a, 'Ankara');
}
