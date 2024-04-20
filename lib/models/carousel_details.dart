class Slider {
  final String? imageUrl;
  final String? title;
  final String? description;

  Slider({this.imageUrl, this.title, this.description});
}

final List silderList = [
  Slider(
    imageUrl: 'assets/images/splash1.png',
    title: 'Select Specialist',
    description:
        'It is a long established fact that a reader will be distracted by the readable content of a page when vooking at its layout',
  ),
  Slider(
    imageUrl: 'assets/images/splash2.png',
    title: 'Book Your Service',
    description:
        'It is a long established fact that a reader will be distracted by the readable content of a page when vooking at its layout',
  ),
];
