class Entry {
  String title, description, rating;
  Entry(this.title, this.description, this.rating);
}

class Journal {
  List<Entry> entries;

  void addEntry(Entry entry) {
    entries.add(entry);
  }
}