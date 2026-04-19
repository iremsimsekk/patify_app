import 'package:flutter/material.dart';

class FunArticle {
  const FunArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.petType,
    required this.intro,
    required this.icon,
    required this.moodIcon,
    required this.highlights,
    required this.funTip,
  });

  final String id;
  final String title;
  final String summary;
  final String petType;
  final String intro;
  final IconData icon;
  final IconData moodIcon;
  final List<String> highlights;
  final String funTip;
}

const List<FunArticle> mockFunArticles = [
  FunArticle(
    id: 'cute-facts',
    title: 'Tatlı Bilgiler',
    summary: 'Patili dostlarla ilgili gülümseten kısa bilgiler.',
    petType: 'general',
    intro:
        'Bazen en keyifli içerikler, kısa ama iç ısıtan notlardır. Bu bölümde patili dostlara dair sıcak ve zarif detaylar yer alır.',
    icon: Icons.favorite_rounded,
    moodIcon: Icons.pets_rounded,
    highlights: [
      'Kediler kendilerini güvende hissettiklerinde yavaşça göz kırpabilir.',
      'Bazı köpekler en sevdikleri oyuncağı yanlarında taşımayı çok sever.',
      'Patili dostlar düzeni fark eder; günlük tekrarlar onları rahatlatabilir.',
    ],
    funTip:
        'Günün içinde ayrılan kısa bir sevgi molası bile bağınızı güçlendirebilir.',
  ),
  FunArticle(
    id: 'paw-of-the-day',
    title: 'Günün Patisi',
    summary: 'Güne enerji ve neşe katan sevimli bir içerik seçkisi.',
    petType: 'dog',
    intro:
        'Her günün kendine özgü küçük bir yıldızı olabilir. Bu içerik, günün enerjisini yansıtan sıcak ve dikkat çekici notlar sunar.',
    icon: Icons.star_rounded,
    moodIcon: Icons.wb_sunny_rounded,
    highlights: [
      'Bugünün patisi, oyun ve küçük keşiflerle dolu bir ruh hâline sahip.',
      'En sevdiği şey, ilgi görmek ve çevresiyle etkileşim kurmak.',
      'Kısa bir fotoğraf molası için oldukça uygun bir gün gibi görünüyor.',
    ],
    funTip:
        'Sevimli anları küçük bir albümde biriktirmek, bu keyifli anları daha da özel kılabilir.',
  ),
  FunArticle(
    id: 'mini-notes',
    title: 'Eğlenceli Mini Notlar',
    summary: 'Günlük hayata sıcak bir dokunuş katan kısa notlar.',
    petType: 'cat',
    intro:
        'Her bilgi uzun olmak zorunda değil. Bazen kısa bir not bile güne keyifli bir dokunuş katmaya yeter.',
    icon: Icons.sticky_note_2_rounded,
    moodIcon: Icons.celebration_rounded,
    highlights: [
      'Kediler bazen kutuları, yataklarından bile daha ilgi çekici bulabilir.',
      'Köpekler tanıdık sesleri ve ayak seslerini şaşırtıcı ölçüde iyi ayırt edebilir.',
      'Küçük ödüller, oyun zamanını daha eğlenceli hale getirebilir.',
    ],
    funTip:
        'Kısa ama özenli notlar, içerik deneyimini daha akıcı ve keyifli hale getirir.',
  ),
  FunArticle(
    id: 'interesting-animal-things',
    title: 'Hayvanlar Hakkında İlginç Şeyler',
    summary: 'Merak uyandıran, hafif ve keyifli bilgiler.',
    petType: 'general',
    intro:
        'Doğa ve hayvan davranışlarına dair şaşırtıcı detaylar, bu bölüme merak uyandıran zarif bir tat katar.',
    icon: Icons.lightbulb_rounded,
    moodIcon: Icons.auto_awesome_rounded,
    highlights: [
      'Bazı hayvanlar, seslerden çok beden diliyle iletişim kurar.',
      'Koklama ve keşif davranışları onlar için bir oyun kadar değerli olabilir.',
      'Kısa gözlemler bile karakterlerini daha iyi tanımana yardımcı olabilir.',
    ],
    funTip:
        'Merak uyandıran küçük bilgiler, günlük içerik akışına keyifli bir çeşitlilik katar.',
  ),
];
