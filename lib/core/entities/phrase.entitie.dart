class PhraseEntitie {
  
  String phrase;
  String author;
  String image;
  DateTime? date;

  PhraseEntitie({
    required this.phrase,
    required this.author,
    required this.image,
    this.date
  });

  Map<String, dynamic> toJson() => {
    'phrase': phrase,
    'author': author,
    'image': image,
    'date': DateTime.now().toString()
  };

}