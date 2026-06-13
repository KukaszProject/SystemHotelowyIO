class OcenaPobytu {
  OcenaPobytu({
    required this.idOceny,
    required this.liczbaGwiazdek,
    required this.komentarz,
    required this.dataDodania,
  }) {
    if (liczbaGwiazdek < 1 || liczbaGwiazdek > 5) {
      throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');

    }
  }

  final int idOceny;
  final int liczbaGwiazdek;
  final String komentarz;
  final DateTime dataDodania;

  int getLiczbaGwiazdek() {
      throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');

  }
}
