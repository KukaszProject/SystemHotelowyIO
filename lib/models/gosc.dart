import 'uzytkownik.dart';

class Gosc extends Uzytkownik {
  Gosc({
    required super.idUzytkownika,
    required super.imie,
    required super.nazwisko,
    required super.email,
    required super.nrTelefonu,
    required this.iloscPunktowLojalnosciowych,
  });

  int iloscPunktowLojalnosciowych;

  void dodajPunktyLojalnosciowe(int punkty) {
      throw NotImplementedError('Metoda nie została jeszcze zaimplementowana');
  }
}
