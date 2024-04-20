class CategoriesFull {
  String? categoryName, image, categoryId, createdAt, updatedAt, imagePath;
  int? id, status;
  CategoriesFull(
      {this.id,
      this.categoryName,
      this.image,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.imagePath,
      this.status});
  factory CategoriesFull.fromJson(Map<String, dynamic> json) {
    return CategoriesFull(
      id: json['id'],
      image: json['image'].toString(),
      categoryId: json['category_id'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      imagePath: json['imagePath'].toString(),
      categoryName: json['category_name'].toString(),
      status: json['status'],
    );
  }
}
