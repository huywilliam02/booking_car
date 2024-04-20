class Offers {
  String? code,
      image,
      description,
      serviceId,
      categoryId,
      startDate,
      endDate,
      createdAt,
      updatedAt,
      service,
      category;
  int? id, discount;
  Offers(
      {this.code,
      this.image,
      this.description,
      this.serviceId,
      this.categoryId,
      this.startDate,
      this.endDate,
      this.createdAt,
      this.updatedAt,
      this.id,
      this.discount,
      this.service,
      this.category});
  factory Offers.fromJson(Map<String, dynamic> json) {
    return Offers(
      code: json['code'].toString(),
      image: json['completeImage'].toString(),
      description: json['description'].toString(),
      serviceId: json['service_id'].toString(),
      categoryId: json['category_id'].toString(),
      startDate: json['start_date'].toString(),
      endDate: json['end_date'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      id: json['id'],
      discount: json['discount'],
      service: '',
      category: '',
    );
  }
}
