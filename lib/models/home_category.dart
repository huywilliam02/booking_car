class Categories {
  String? categoryName, image, categoryId, createdAt, updatedAt;
  int? id, status;
  Categories(
      {this.id,
      this.categoryName,
      this.image,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.status});
  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['id'],
      image: json['completeImage'].toString(),
      categoryId: json['category_id'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      categoryName: json['category_name'].toString(),
      status: json['status'],
    );
  }
}
