class Entry {
  int id, rating;
  String title, description;
  DateTime date;

  Entry(this.title, this.description, this.rating) {
    date = new DateTime.now();
  }
}