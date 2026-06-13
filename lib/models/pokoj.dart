import '../enums/status_pokoju.dart';
import '../enums/status_rezerwacji.dart';
import 'rezerwacja.dart';

class Pokoj {
  Pokoj({
    required this.idPokoju,
    required this.nrPokoju,
    required this.pojemnoscPokoju,
    required this.cenaZaDobe,
    required this.statusPokoju,
    List<Rezerwacja>? rezerwacje,
  }) : rezerwacje = rezerwacje ?? [];

  final int idPokoju;
  final int nrPokoju;
  final int pojemnoscPokoju;
  double cenaZaDobe;
  StatusPokoju statusPokoju;
  final List<Rezerwacja> rezerwacje;

  double obliczKoszt(int iloscDni) {
     throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  void zmienStatus(StatusPokoju nowyStatus) {
     throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool czyDostepny(DateTime dataPoczatkowa, DateTime dataKoncowa) {
     throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');
    }


  bool _blokujeDostepnosc(Rezerwacja rezerwacja) {
    throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool _terminySiePokrywaja(
    DateTime poczatekA,
    DateTime koniecA,
    DateTime poczatekB,
    DateTime koniecB,
  ) {
     throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');
  }
}
