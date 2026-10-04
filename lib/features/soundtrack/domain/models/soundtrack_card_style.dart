/// Visual display variations for the physical Soundtrack Card in the journal and scrapbook:
/// 1. Cassette card: Vintage tape cassette with spools, label, and tactile aesthetic.
/// 2. Vinyl record card: Circular grooved vinyl record peaking out from an album sleeve jacket.
/// 3. Polaroid-style music card: Square album art with classic creamy photo border, handwritten notes, and washi tape.
/// 4. Handwritten music note: Deckled edge paper with musical clef stamp, handwritten track and artist.
/// 5. Minimal vintage ticket: Punched concert stub / admission ticket with perforated edge and track details.
enum SoundtrackCardStyle {
  cassette,
  vinyl,
  polaroid,
  handwrittenNote,
  vintageTicket;

  String get label {
    switch (this) {
      case SoundtrackCardStyle.cassette:
        return 'Cassette Tape';
      case SoundtrackCardStyle.vinyl:
        return 'Vinyl Record';
      case SoundtrackCardStyle.polaroid:
        return 'Polaroid Keepsake';
      case SoundtrackCardStyle.handwrittenNote:
        return 'Handwritten Note';
      case SoundtrackCardStyle.vintageTicket:
        return 'Concert Ticket Stub';
    }
  }
}
