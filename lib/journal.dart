class Entry {
  final int id;
  final String title;
  final String description;
  final int rating;
  final DateTime date;

  Entry({this.id, this.title, this.description, this.rating, this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rating': rating,
      'date': date
    };
  }
}

class EntryDataTransfer {
  String title, description;
  int rating;
}