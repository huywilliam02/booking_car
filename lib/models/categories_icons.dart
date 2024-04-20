class CategoriesIcons {
  String? serviceName,
      image,
      categoryId,
      coworkerId,
      description,
      createdAt,
      updatedAt,
      category,
      imagePath,
      coworker;
  int? id, price, duration, status;
  CategoriesIcons(
      {this.serviceName,
      this.image,
      this.categoryId,
      this.coworkerId,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.category,
      this.imagePath,
      this.coworker,
      this.id,
      this.status,
      this.duration,
      this.price});
  factory CategoriesIcons.fromJson(Map<String, dynamic> json) {
    return CategoriesIcons(
      serviceName: json['service_name'].toString(),
      image: json['image'].toString(),
      categoryId: json['category_id'].toString(),
      coworkerId: json['coworker_id'].toString(),
      description: json['description'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      category: '',
      imagePath: json['imagePath'].toString(),
      coworker: '',
      id: json['id'],
      status: json['status'],
      duration: json['duration'],
      price: json['price'],
    );
  }
}
