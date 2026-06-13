import '../enums/status_pokoju.dart';
import '../enums/status_rezerwacji.dart';
import '../interfaces/i_serwis_email.dart';
import '../models/gosc.dart';
import '../models/pokoj.dart';
import '../models/rezerwacja.dart';

class SerwisRezerwacji {
  SerwisRezerwacji({
    required this.serwisEmail,
    required List<Pokoj> pokoje,
    List<Gosc>? goscie,
    DateTime? dzisiejszaData,
  }) : _pokoje = pokoje,
       _goscie = goscie ?? [],
       _dzisiejszaData = dzisiejszaData;

  final ISerwisEmail serwisEmail;
  final List<Pokoj> _pokoje;
  final List<Gosc> _goscie;
  final DateTime? _dzisiejszaData;
  final List<Rezerwacja> _rezerwacje = [];
  int _nastepneIdRezerwacji = 1;

  Rezerwacja stworzRezerwacje({
    required int idGoscia,
    required int idPokoju,
    required DateTime dataPoczatkowa,
    required DateTime dataKoncowa,
  }) {
       throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool anulujRezerwacje({
    required int idRezerwacji,
    required String powod,
  }) {
         throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool modyfikujDatyRezerwacji({
    required int idRezerwacji,
    required DateTime nowaDataPoczatkowa,
    required DateTime nowaDataKoncowa,
  }) {
     throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  List<Pokoj> znajdzDostepnePokoje({
    required DateTime dataPoczatkowa,
    required DateTime dataKoncowa,
    required int liczbaGosci,
  }) {
         throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  Pokoj _znajdzPokoj(int idPokoju) {
         throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  _RezerwacjaZPokojem? _znajdzRezerwacjeZPokojem(int idRezerwacji) {
         throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool _terminySiePokrywaja(
    DateTime poczatekA,
    DateTime koniecA,
    DateTime poczatekB,
    DateTime koniecB,
  ) {
     throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool _czyDataWPrzeszlosci(DateTime data) {
    final dzisiaj = _dzisiejszaData;
        throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  DateTime _tylkoData(DateTime data) {
         throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  Gosc? _znajdzGoscia(int idGoscia) {
        throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  String _tymczasowyEmailGoscia(int idGoscia) {
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
