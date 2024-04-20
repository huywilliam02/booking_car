class SpecialistM {
  int? id;
  String? serviceName;
  String? image;
  String? categoryId;
  String? price;
  String? skill;
  double? rating;
  String? name;
  String? imageUrl;
  SpecialistM({
    this.id,
    this.serviceName,
    this.image,
    this.categoryId,
    this.price,
    this.skill,
    this.rating,
    this.name,
    this.imageUrl,
  });

  factory SpecialistM.fromJson(Map<String, dynamic> json) {
    return SpecialistM(
      id: json['id'],
      serviceName: json['title'].toString(),
      image: json['link'].toString(),
      categoryId: json['category_id'].toString(),
      price: json['price'].toString(),
      skill: json['skill'].toString(),
      rating: json['rating'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
