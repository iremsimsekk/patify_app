// Dosya: lib/data/mock_data.dart

// Kullanıcı Tipleri
enum UserType { petOwner, shelter }

// Mock Kullanıcı Modeli (Barınak Detayları Genişletildi)
class AppUser {
  final String id;
  final String email;
  final String password;
  final String name;
  final UserType type;
  final String? photoUrl;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final String? workingHours;
  final String? about;
  final double? rating; // Puanlama eklendi (Google Maps simülasyonu)
  final int? reviewCount; // Yorum sayısı

  AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.type,
    this.photoUrl,
    this.address,
    this.phoneNumber,
    this.website,
    this.workingHours,
    this.about,
    this.rating,
    this.reviewCount,
  });
}

// Mock Hayvan Modeli
class Animal {
  final String id;
  final String shelterId;
  final String name;
  final String type; // Köpek, Kedi
  final String breed; // Cins
  final String age;
  final String gender;
  final double weight;
  final String color;
  final String healthStatus;
  final String description;
  final String imagePath;

  Animal({
    required this.id,
    required this.shelterId,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.color,
    required this.healthStatus,
    required this.description,
    required this.imagePath,
  });
}

// --- VERİLER ---

final List<AppUser> mockUsers = [
  // 1. Normal Kullanıcı
  AppUser(
    id: 'u1',
    email: 'user@patify.com',
    password: '123',
    name: 'Merve Nair',
    type: UserType.petOwner,
    photoUrl: 'assets/user_placeholder.png',
  ),

  // --- ANKARA GERÇEK BARINAK VERİLERİ (SİMÜLASYON) ---
  
  // 2. Barınak: Çankaya Belediyesi
  AppUser(
    id: 's1',
    email: 'cankaya@patify.com',
    password: '123',
    name: 'Çankaya Belediyesi Sahipsiz Hayvan Barınağı',
    type: UserType.shelter,
    address: 'Mühye Köyü, Yeşilkent Mahallesi, 06550 Çankaya/Ankara',
    phoneNumber: '0312 442 37 18',
    website: 'www.cankaya.bel.tr',
    workingHours: 'Hafta içi: 10:00 - 16:00',
    about: 'Çankaya Belediyesi olarak binlerce dostumuza geçici ev sahipliği yapıyoruz. Modern tesislerimizde veteriner hekimlerimiz gözetiminde rehabilitasyon çalışmaları yürütülmektedir.',
    rating: 4.2,
    reviewCount: 1250,
    photoUrl: 'assets/shelter_placeholder.png',
  ),

  // 3. Barınak: Gölbaşı Belediyesi
  AppUser(
    id: 's2',
    email: 'golbasi@patify.com',
    password: '123',
    name: 'Gölbaşı Belediyesi Hayvan Barınağı',
    type: UserType.shelter,
    address: 'Ballıkpınar, 06830 Gölbaşı/Ankara',
    phoneNumber: '0312 485 55 55',
    website: 'www.ankaragolbasi.bel.tr',
    workingHours: 'Her gün: 09:00 - 17:00',
    about: 'Gölbaşı\'nın doğal ortamında, geniş arazimizde sokak hayvanlarını misafir ediyoruz. Sahiplendirme odaklı çalışmalarımızla her yıl yüzlerce canı sıcak yuvalara kavuşturuyoruz.',
    rating: 3.8,
    reviewCount: 840,
    photoUrl: 'assets/shelter_placeholder.png',
  ),

  // 4. Barınak: Keçiören Belediyesi
  AppUser(
    id: 's3',
    email: 'kecioren@patify.com',
    password: '123',
    name: 'Keçiören Belediyesi Hayvan Bakım Merkezi',
    type: UserType.shelter,
    address: 'Uyanış, Aşık Veysel Cd., 06300 Keçiören/Ankara',
    phoneNumber: '0312 361 10 65',
    website: 'www.kecioren.bel.tr',
    workingHours: 'Hafta içi: 08:30 - 17:30',
    about: 'Keçiören\'deki patili dostlarımızın sağlık kontrolleri, aşıları ve bakımları merkezimizde titizlikle yapılmaktadır. Satın alma sahiplen!',
    rating: 4.0,
    reviewCount: 560,
    photoUrl: 'assets/shelter_placeholder.png',
  ),
];

// --- HAYVANLAR (Barınaklara Dağıtılmış) ---
List<Animal> mockAnimals = [
  // Çankaya Barınağı (s1) Hayvanları
  Animal(
    id: 'a1',
    shelterId: 's1',
    name: 'Pamuk',
    type: 'Köpek',
    breed: 'Golden Retriever Melezi',
    age: '2 Yaşında',
    gender: 'Dişi',
    weight: 24.5,
    color: 'Krem',
    healthStatus: 'Aşıları Tam, Kısırlaştırılmış',
    description: 'Pamuk çok sakin ve insan canlısı bir köpek. Parkta gezmeyi çok seviyor, tasmayla yürümeye alışkın.',
    imagePath: 'assets/animals/dog.jpg',
  ),
  Animal(
    id: 'a2',
    shelterId: 's1',
    name: 'Zeytin',
    type: 'Kedi',
    breed: 'Bombay (Siyah)',
    age: '8 Aylık',
    gender: 'Erkek',

    weight: 3.2,
    color: 'Gri',
    healthStatus: 'İç-Dış Parazit Yapıldı',
    description: 'Duman biraz çekingen ama sevdikçe açılan bir kedi. Sakin bir ev arıyor.',
    imagePath: 'assets/animals/Duman.jpg',

  ),

  // Gölbaşı Barınağı (s2) Hayvanları
  Animal(
    id: 'a3',
    shelterId: 's2',
    name: 'Herkül',
    type: 'Köpek',
    breed: 'Kangal',
    age: '3 Yaşında',
    gender: 'Erkek',

    weight: 6.5,
    color: 'Beyaz',
    healthStatus: 'Aşıları Tam',
    description: 'Enerjisi hiç bitmeyen, top oynamayı çok seven minik bir dost.',
    imagePath: 'assets/animals/Boncuk.jpg',
  ),
  Animal(
    id: 'a4',
    shelterId: 's2',
    name: 'Benek',
    type: 'Köpek',
    breed: 'Dalmaçyalı Kırması',
    age: '1.5 Yaşında',
    gender: 'Dişi',

    weight: 1.1,
    color: 'Sarı-Beyaz',
    healthStatus: 'Tedavisi Devam Ediyor',
    description: 'Limon sokakta bulundu, göz tedavisi görüyor ama çok neşeli.',
    imagePath: 'assets/animals/Limon.jpg',


  // Keçiören Barınağı (s3) Hayvanları
  Animal(
    id: 'a5',
    shelterId: 's3',
    name: 'Mırmır',
    type: 'Kedi',
    breed: 'Tekir',
    age: '2 Yaşında',
    gender: 'Dişi',
    weight: 4.0,
    color: 'Kahve-Siyah',
    healthStatus: 'Kısırlaştırılmış',

    description: 'Baron çok iyi eğitimli, komutları biliyor. Bahçeli ev tercih sebebidir.',
    imagePath: 'assets/animals/Baron.jpeg',

  ),
];

// Yardımcı Fonksiyonlar
AppUser? authenticateUser(String email, String password) {
  try {
    return mockUsers.firstWhere(
      (user) => user.email == email && user.password == password,
    );
  } catch (e) {
    return null;
  }
}

List<Animal> getAnimalsByShelter(String shelterId) {
  return mockAnimals.where((animal) => animal.shelterId == shelterId).toList();
}

// Yeni: Mock Veteriner Kliniği Modeli
class VeterinaryClinic {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String workingHours;
  final String about;

  VeterinaryClinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.workingHours,
    required this.about,
  });
}

// Yeni: Mock Veteriner Verileri (Ankara gereksinimine uygun)
final List<VeterinaryClinic> mockVeterinaries = [
  VeterinaryClinic(
    id: 'v1',
    name: 'Çankaya Veteriner Kliniği',
    address: 'Atakent, Çankaya/Ankara',
    phoneNumber: '0312 111 22 33',
    workingHours: 'Hafta içi: 09:00 - 19:00',
    about: 'Yirmi yıllık tecrübemizle can dostlarınızın sağlığı için buradayız.',
  ),
  VeterinaryClinic(
    id: 'v2',
    name: 'Batıkent Pet Hospital',
    address: 'Batıkent, Yenimahalle/Ankara',
    phoneNumber: '0312 444 55 66',
    workingHours: '7/24 Acil Hizmet',
    about: 'Geniş kapsamlı hastane ortamında tam donanımlı hizmet.',
  ),
];

// ... (mevcut mockUsers ve mockAnimals listeleri kalıyor)

// Yeni: Yardımcı Fonksiyon (Opsiyonel: Detay ekranı için)
VeterinaryClinic? getClinicById(String id) {
  try {
    return mockVeterinaries.firstWhere((clinic) => clinic.id == id);
  } catch (e) {
    return null;
  }
}