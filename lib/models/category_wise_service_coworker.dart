class CategoryWiseServiceCoworker {
  String? serviceName,
      image,
      categoryId,
      coworkerId,
      description,
      createdAt,
      updatedAt,
      rate;
  bool? selected;
  int? id, price, duration, status;
  CategoryWiseServiceCoworker(
      {this.serviceName,
      this.image,
      this.categoryId,
      this.coworkerId,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.id,
      this.price,
      this.duration,
      this.status,
      this.rate,
      this.selected});
  factory CategoryWiseServiceCoworker.fromJson(Map<String, dynamic> json) {
    return CategoryWiseServiceCoworker(
      serviceName: json['service_name'].toString(),
      image: json['completeImage'].toString(),
      categoryId: json['category_id'].toString(),
      coworkerId: json['coworker_id'].toString(),
      description: json['description'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      id: json['id'],
      price: json['price'],
      duration: json['duration'],
      status: json['status'],
      rate: json['rate'].toString(),
    );
  }
}
