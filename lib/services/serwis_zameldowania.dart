import '../enums/status_pokoju.dart';
import '../enums/status_rezerwacji.dart';
import '../interfaces/i_system_otwierania_drzwi.dart';
import '../models/pokoj.dart';
import '../models/rezerwacja.dart';

class SerwisZameldowania {
  SerwisZameldowania({
    required this.systemOtwieraniaDrzwi,
    required List<Pokoj> pokoje,
  }) : _pokoje = pokoje;

  final ISystemOtwieraniaDrzwi systemOtwieraniaDrzwi;
  final List<Pokoj> _pokoje;

  String przetworzZameldowanie({required int idRezerwacji}) {
            throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool przetworzWymeldowanie({required int idRezerwacji}) {
            throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  _RezerwacjaZPokojem _znajdzRezerwacjeZPokojem(int idRezerwacji) {
            throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }
}

class _RezerwacjaZPokojem {
  const _RezerwacjaZPokojem({
    required this.rezerwacja,
    required this.pokoj,
  });

  final Rezerwacja rezerwacja;
  final Pokoj pokoj;
}
