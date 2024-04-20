class Offer {
  String? description, expireDate, type;
  int? id, discount;
  Offer({
    this.description,
    this.expireDate,
    this.id,
    this.discount,
    this.type,
  });
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      description: json['description'],
      expireDate: json['end_date'],
      discount: json['discount'],
      type: json['type'],
    );
  }
}
