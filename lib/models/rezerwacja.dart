import '../enums/status_rezerwacji.dart';
import 'gosc.dart';
import 'ocena_pobytu.dart';
import 'platnosc.dart';
import 'pokoj.dart';

class Rezerwacja {
  Rezerwacja({
    required this.idRezerwacji,
    required this.dataPoczatkowa,
    required this.dataKoncowa,
    required this.calkowitaCena,
    required this.status,
    this.gosc,
    List<Pokoj>? pokoje,
    this.platnosc,
    this.ocenaPobytu,
    this.kodPin,
  }) : pokoje = pokoje ?? [];

  final int idRezerwacji;
  DateTime dataPoczatkowa;
  DateTime dataKoncowa;
  double calkowitaCena;
  StatusRezerwacji status;
  Gosc? gosc;
  final List<Pokoj> pokoje;
  Platnosc? platnosc;
  OcenaPobytu? ocenaPobytu;
  String? kodPin;

  void potwierdzRezerwacje() {
     throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  void anulujRezerwacje() {
     throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool modyfikujDaty(DateTime nDataPoczatkowa, DateTime nDataKoncowa) {
     throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  int obliczDlugoscPobytu() {
     throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }

  bool dodajOcenePobytu(OcenaPobytu ocena) {
     throw UnimplementedError('Metoda nie została jeszcze zaimplementowana');
  }
}
