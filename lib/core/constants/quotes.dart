class Quotes {
  static const List<String> dailyQuotes = [
    "“Every day is a page in the book of your life. Make it worth reading.”",
    "“Keep a journal, and one day your journal will keep you.” — Mae West",
    "“What you write today becomes the nostalgia of tomorrow.”",
    "“Preserve your memories, keep them well, what you forget you can never retell.” — Louisa May Alcott",
    "“Fill your paper with the breathings of your heart.” — William Wordsworth",
    "“In the journal I do not just express myself more openly than I could to any person; I create myself.” — Susan Sontag",
    "“A personal journal is an ideal environment in which to become. It is a perfect place for you to think, feel, discover, expand, remember, and dream.” — Brad Wilcox",
    "“We write to taste life twice, in the moment and in retrospect.” — Anaïs Nin",
    "“I write because I don't know what I think until I read what I say.” — Flannery O'Connor",
    "“The life of every person is a diary in which they mean to write one story, and write another.” — J.M. Barrie",
  ];

  static String getTodayQuote() {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return dailyQuotes[dayOfYear % dailyQuotes.length];
  }
}
