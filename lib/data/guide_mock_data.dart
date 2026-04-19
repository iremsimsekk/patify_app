import 'package:flutter/material.dart';

class GuideArticle {
  const GuideArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.petType,
    required this.intro,
    required this.icon,
    required this.bullets,
    required this.tip,
    required this.vetNote,
  });

  final String id;
  final String title;
  final String summary;
  final String petType;
  final String intro;
  final IconData icon;
  final List<String> bullets;
  final String tip;
  final String vetNote;
}

const List<GuideArticle> mockGuideArticles = [
  GuideArticle(
    id: 'first-cat-adoption',
    title: 'İlk Kez Kedi Sahiplendim',
    summary:
        'Yeni kedinle ilk günleri daha huzurlu ve güvenli geçirmen için temel öneriler.',
    petType: 'cat',
    intro:
        'Eve yeni gelen bir kedi, ilk günlerde çekingen davranabilir. Sakin bir alan sunmak ve rutini yavaş yavaş kurmak, uyum sürecini kolaylaştırır.',
    icon: Icons.pets_rounded,
    bullets: [
      'Sessiz bir dinlenme alanı, su kabı ve kum kabı önceden hazır olsun.',
      'İlk günlerde tüm evi gezmek yerine, tek bir odada kendini güvende hissetmesine izin ver.',
      'Teması zorlamadan, kendi hızında sana yaklaşmasını bekle.',
    ],
    tip:
        'İlk günlerde aynı mama ve kum markasıyla başlamak, adaptasyonu kolaylaştırabilir.',
    vetNote:
        'İlk hafta içinde genel kontrol ve parazit planı için veteriner randevusu oluşturman faydalı olur.',
  ),
  GuideArticle(
    id: 'first-vet-visit',
    title: 'İlk Veteriner Ziyareti',
    summary:
        'İlk muayeneyi daha sakin ve verimli geçirmen için kısa bir rehber.',
    petType: 'general',
    intro:
        'Veteriner ziyareti, temel sağlık kontrolü ve sonraki takipler için önemli bir başlangıçtır. Hazırlıklı gitmek, süreci daha rahat hale getirir.',
    icon: Icons.medical_services_rounded,
    bullets: [
      'Taşıma çantası veya güvenli tasma ile gitmeye özen göster.',
      'Mama düzeni, aşılar ve önceki sağlık bilgilerini kısa notlarla yanında bulundur.',
      'Bir belirti fark ettiysen, ne zaman başladığını açık şekilde paylaş.',
    ],
    tip:
        'Randevu saatinden biraz erken giderek ortama alışması için kısa bir süre tanıyabilirsin.',
    vetNote:
        'Küçük görünen belirtiler bile önemli olabilir; iştah, tuvalet ve enerji değişimlerini mutlaka paylaş.',
  ),
  GuideArticle(
    id: 'cat-feeding',
    title: 'Kedi Nasıl Beslenmeli?',
    summary:
        'Yaşına ve günlük rutinine uygun, daha dengeli bir beslenme için temel bilgiler.',
    petType: 'cat',
    intro:
        'Kedilerde düzenli su tüketimi ve yaşına uygun mama seçimi büyük önem taşır. Tek seferde fazla vermek yerine planlı öğünler sunmak daha dengeli bir yaklaşım sağlar.',
    icon: Icons.restaurant_rounded,
    bullets: [
      'Yaşına uygun yavru, yetişkin veya kısırlaştırılmış kedi maması tercih et.',
      'Temiz su kabını kolay ulaşabileceği bir yerde tut ve gün içinde kontrol et.',
      'Mama değişikliklerini ani değil, 5 ila 7 günlük bir geçişle yap.',
    ],
    tip:
        'Su tüketimi düşükse, su pınarı ya da birden fazla su noktası faydalı olabilir.',
    vetNote:
        'Kilo artışı, kusma veya ishal gibi durumlarda mama tercihini veterinerle birlikte değerlendirmek en doğru yaklaşım olur.',
  ),
  GuideArticle(
    id: 'dog-walking-routine',
    title: 'Köpek Yürüyüş Rutini',
    summary:
        'Daha dengeli enerji ve davranış için uygulanabilir yürüyüş önerileri.',
    petType: 'dog',
    intro:
        'Düzenli yürüyüş, köpeklerde yalnızca fiziksel değil zihinsel rahatlama da sağlar. Kısa ama düzenli bir rutin, uzun aralıklı yürüyüşlerden çoğu zaman daha verimlidir.',
    icon: Icons.directions_walk_rounded,
    bullets: [
      'Her gün benzer saatlerde dışarı çıkmak, düzen oluşturmayı kolaylaştırır.',
      'Yürüyüş sırasında koklama molaları vererek keşfetmesine alan tanı.',
      'Hava sıcaklığına göre süreyi ve tempoyu ayarla.',
    ],
    tip:
        'Kısa eğitim komutlarını yürüyüşe dahil etmek, odağını ve iletişiminizi güçlendirebilir.',
    vetNote:
        'Aşırı yorulma, topallama veya nefes darlığı fark edersen tempoyu düşürüp veteriner görüşü al.',
  ),
  GuideArticle(
    id: 'emergency-signs',
    title: 'Acil Belirtiler',
    summary:
        'Hızlı destek alman gerekebilecek temel uyarı işaretlerini hatırlatır.',
    petType: 'general',
    intro:
        'Bazı belirtiler, evde beklemek yerine hızlı destek almayı gerektirebilir. Erken fark etmek süreci daha güvenli ve kontrollü hale getirir.',
    icon: Icons.warning_amber_rounded,
    bullets: [
      'Nefes almada zorluk, baygınlık veya ani denge kaybı.',
      'Sürekli kusma, belirgin halsizlik veya su içmeyi tamamen bırakma.',
      'Travma, kanama ya da şiddetli ağrı belirtisi.',
    ],
    tip:
        'Acil bir durumda en yakın kliniğin adresi ve telefonunun kolay ulaşılabilir olması büyük kolaylık sağlar.',
    vetNote:
        'Belirtiler şiddetliyse önce telefonla bilgi verip doğrudan en yakın veterinere yönel.',
  ),
];
