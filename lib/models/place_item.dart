class PlaceItem {
  final String placeId;
  final String name;
  final String address;
  final double rating;
  final int userRatingsTotal;

  PlaceItem({
    required this.placeId,
    required this.name,
    required this.address,
    required this.rating,
    required this.userRatingsTotal,
  });

  factory PlaceItem.fromJson(Map<String, dynamic> j) => PlaceItem(
        placeId: (j['placeId'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        address: (j['address'] ?? '') as String,
        rating: ((j['rating'] ?? 0) as num).toDouble(),
        userRatingsTotal: (j['userRatingsTotal'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => {
        "placeId": placeId,
        "name": name,
        "address": address,
        "rating": rating,
        "userRatingsTotal": userRatingsTotal,
      };
}
