class Review {
  String? image, name, date, comment;
  int? rating;
  Review({this.image, this.name, this.date, this.comment, this.rating});
  factory Review.fromjson(Map<String, dynamic> json) {
    return Review(
      image: json['user']['completeImage'],
      name: json['user']['name'],
      date: json['date'],
      comment: json['comment'],
      rating: json['rate'],
    );
  }
}
