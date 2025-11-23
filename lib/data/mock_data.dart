// Dosya: lib/data/mock_data.dart

// Kullanıcı Tipleri
enum UserType { petOwner, shelter }

// Mock Kullanıcı Modeli (Barınak Detayları Eklendi)
class AppUser {
  final String id;
  final String email;
  final String password;
  final String name;
  final UserType type;
  final String? photoUrl;
  final String? address;
  final String? phoneNumber; // Yeni
  final String? website; // Yeni
  final String? workingHours; // Yeni
  final String? about; // Yeni
  final double?
      rating; // YENİ EKLENDİ (Hata: The getter 'rating' isn't defined)
  final int?
      reviewCount; // YENİ EKLENDİ (Hata: The getter 'reviewCount' isn't defined)

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
    this.rating, // YENİ
    this.reviewCount, // YENİ
  });
}

// Mock Hayvan Modeli (Detaylar Eklendi)
class Animal {
  final String id;
  final String shelterId;
  final String name;
  final String type; // Köpek, Kedi, Kuş vb.
  final String breed; // Cins (Golden, Tekir vb.) - YENİ
  final String age;
  final String gender;
  final double weight; // Kilo - YENİ
  final String color; // Renk - YENİ
  final String healthStatus; // Sağlık (Aşılı, Kısır vb.) - YENİ
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
  // Normal Kullanıcı
  AppUser(
    id: 'u1',
    email: 'user@patify.com',
    password: '123',
    name: 'Merve Nair',
    type: UserType.petOwner,
    photoUrl: 'assets/user_placeholder.png',
  ),
  // Barınak 1
  AppUser(
    id: 's1',
    email: 'cankaya@patify.com',
    password: '123',
    name: 'Ankara Sevgi Barınağı',
    type: UserType.shelter,
    address: 'Çankaya, Ankara',
    phoneNumber: '+90 312 123 45 67',
    website: 'www.sevgibarinagi.org',
    workingHours: 'Hafta içi: 09:00 - 18:00',
    about:
        '2010 yılından beri Ankara\'daki sokak hayvanlarına yuva bulmak için çalışıyoruz. Bağışlarınızla yüzlerce cana dokunduk.',
    photoUrl: 'assets/shelter_placeholder.png',
  ),
  // Barınak 2 (Yeni Eklendi - Çeşitlilik olsun diye)
  AppUser(
    id: 's2',
    email: 'golbasi@patify.com',
    password: '123',
    name: 'Umut Patiler Derneği',
    type: UserType.shelter,
    address: 'Etimesgut, Ankara',
    phoneNumber: '+90 555 987 65 43',
    website: 'www.umutpatiler.com',
    workingHours: 'Her gün: 10:00 - 17:00',
    about:
        'Hasta ve bakıma muhtaç sokak hayvanlarının tedavilerini üstlenen gönüllü bir kuruluşuz.',
    photoUrl: 'assets/shelter_placeholder.png',
  ),
];

// Hazır Hayvanlar (Sayı ve Detay Artırıldı)
final List<Animal> mockAnimals = [
  Animal(
    id: 'a1',
    shelterId: 's1',
    name: 'Pamuk',
    type: 'Köpek',
    breed: 'Golden Retriever',
    age: '2 Yaşında',
    gender: 'Dişi',
    weight: 24.5,
    color: 'Sarı',
    healthStatus: 'Aşıları Tam, Kısırlaştırılmış',
    description: 'Pamuk çok oyuncu ve insan canlısı. Çocuklarla arası harika.',
    imagePath: 'assets/animals/dog.jpg',
  ),
  Animal(
    id: 'a2',
    shelterId: 's1',
    name: 'Duman',
    type: 'Kedi',
    breed: 'British Shorthair',
    age: '6 Aylık',
    gender: 'Erkek',
    weight: 3.2,
    color: 'Gri',
    healthStatus: 'İç-Dış Parazit Yapıldı',
    description:
        'Duman biraz çekingen ama sevdikçe açılan bir kedi. Sakin bir ev arıyor.',
    imagePath: 'assets/animals/dog.jpg',
  ),
  Animal(
    id: 'a3',
    shelterId: 's1',
    name: 'Boncuk',
    type: 'Köpek',
    breed: 'Terrier',
    age: '1 Yaşında',
    gender: 'Erkek',
    weight: 6.5,
    color: 'Beyaz',
    healthStatus: 'Aşıları Tam',
    description:
        'Enerjisi hiç bitmeyen, top oynamayı çok seven minik bir dost.',
    imagePath: 'assets/animals/dog.jpg',
  ),
  Animal(
    id: 'a4',
    shelterId: 's2',
    name: 'Limon',
    type: 'Kedi',
    breed: 'Tekir',
    age: '3 Aylık',
    gender: 'Dişi',
    weight: 1.1,
    color: 'Sarı-Beyaz',
    healthStatus: 'Tedavisi Devam Ediyor',
    description: 'Limon sokakta bulundu, göz tedavisi görüyor ama çok neşeli.',
    imagePath: 'assets/animals/dog.jpg',
  ),
  Animal(
    id: 'a5',
    shelterId: 's2',
    name: 'Baron',
    type: 'Köpek',
    breed: 'Alman Kurdu',
    age: '4 Yaşında',
    gender: 'Erkek',
    weight: 32.0,
    color: 'Siyah-Sarı',
    healthStatus: 'Kısırlaştırılmış',
    description:
        'Baron çok iyi eğitimli, komutları biliyor. Bahçeli ev tercih sebebidir.',
    imagePath: 'assets/animals/dog.jpg',
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

// Mock Veteriner Kliniği Modeli
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

// Mock Veteriner Klinik Listesi
final List<VeterinaryClinic> mockVeterinaries = [
  VeterinaryClinic(
    id: 'v1',
    name: 'Ankara Pet Tıp Merkezi',
    address: 'Kızılay, Çankaya/Ankara',
    phoneNumber: '+90 312 999 88 77',
    workingHours: 'Hafta içi: 09:00 - 19:00, Cmt: 09:00 - 16:00',
    about:
        'Tecrübeli kadromuzla 7/24 hizmetinizdeyiz. Amacımız can dostlarımızın sağlığı ve mutluluğu.',
  ),
  VeterinaryClinic(
    id: 'v2',
    name: 'Gölbaşı Pati Hastanesi',
    address: 'Gölbaşı, Ankara',
    phoneNumber: '+90 530 111 22 33',
    workingHours: 'Pazartesi-Pazar: 09:00 - 21:00',
    about:
        'Acil durumlara hızlı müdahale, uzman hekim kadrosu ve modern cihazlarla tam donanımlı hayvan hastanesi.',
  ),
];
