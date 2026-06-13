import 'package:flutter/material.dart';

import '../../controllers/hotel_controller.dart';
import '../../enums/status_pokoju.dart';
import '../../enums/status_rezerwacji.dart';
import '../../models/gosc.dart';
import '../../models/ocena_pobytu.dart';
import '../../models/pokoj.dart';
import '../../models/recepcjonista.dart';
import '../../models/rezerwacja.dart';
import '../../models/uzytkownik.dart';

class HotelDashboardScreen extends StatefulWidget {
  const HotelDashboardScreen({super.key});

  @override
  State<HotelDashboardScreen> createState() => _HotelDashboardScreenState();
}

class _HotelDashboardScreenState extends State<HotelDashboardScreen> {
  late final HotelController _controller;
  int _selectedIndex = 0;
  late DateTime _startDate;
  late DateTime _endDate;
  int _guestCount = 2;
  _AccountRole _role = _AccountRole.gosc;
  late Uzytkownik _activeUser;

  @override
  void initState() {
    super.initState();
    _controller = HotelController.demo();
    _startDate = _today();
    _endDate = _startDate.add(const Duration(days: 2));
    _activeUser = _controller.repozytorium.goscie.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _page()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: _navigationDestinations(),
      ),
    );
  }

  List<NavigationDestination> _navigationDestinations() {
    return switch (_role) {
      _AccountRole.gosc => const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Start',
        ),
        NavigationDestination(
          icon: Icon(Icons.king_bed_outlined),
          selectedIcon: Icon(Icons.king_bed_rounded),
          label: 'Pokoje',
        ),
        NavigationDestination(
          icon: Icon(Icons.luggage_outlined),
          selectedIcon: Icon(Icons.luggage_rounded),
          label: 'Pobyt',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          selectedIcon: Icon(Icons.account_circle_rounded),
          label: 'Konto',
        ),
      ],
      _AccountRole.recepcjonista => const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Panel',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note_rounded),
          label: 'Rezerwacje',
        ),
        NavigationDestination(
          icon: Icon(Icons.meeting_room_outlined),
          selectedIcon: Icon(Icons.meeting_room_rounded),
          label: 'Pokoje',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          selectedIcon: Icon(Icons.account_circle_rounded),
          label: 'Konto',
        ),
      ],
    };
  }

  Widget _page() {
    return switch (_role) {
      _AccountRole.gosc => _guestPage(),
      _AccountRole.recepcjonista => _receptionPage(),
    };
  }

  Widget _guestPage() {
    return switch (_selectedIndex) {
      0 => _HomePage(
        controller: _controller,
        startDate: _startDate,
        endDate: _endDate,
        guestCount: _guestCount,
        onFiltersChanged: _setFilters,
        onReserve: _showReservationDialog,
        onOpenRooms: _openRooms,
      ),
      1 => _RoomsPage(
        controller: _controller,
        startDate: _startDate,
        endDate: _endDate,
        guestCount: _guestCount,
        role: _role,
        onFiltersChanged: _setFilters,
        onSearch: _openRooms,
        onReserve: (room) => _showReservationDialog(initialRoom: room),
        onStatusChanged: _changeRoomStatus,
      ),
      2 => _StayPage(
        controller: _controller,
        role: _role,
        onPay: _payReservation,
        onCheckIn: _checkInReservation,
        onCheckOut: _checkOutReservation,
        onCancel: _cancelReservation,
        onReview: _showReviewDialog,
        onModifyDates: _showDateEditDialog,
      ),
      _ => _AccountPage(
        controller: _controller,
        role: _role,
        activeUser: _activeUser,
        onRoleChanged: _changeRole,
        onUserChanged: _changeUser,
      ),
    };
  }

  Widget _receptionPage() {
    return switch (_selectedIndex) {
      0 => _ReceptionDashboardPage(
        controller: _controller,
        onOpenReservations: () => setState(() => _selectedIndex = 1),
        onOpenRooms: () => setState(() => _selectedIndex = 2),
      ),
      1 => _StayPage(
        controller: _controller,
        role: _role,
        onPay: _payReservation,
        onCheckIn: _checkInReservation,
        onCheckOut: _checkOutReservation,
        onCancel: _cancelReservation,
        onReview: _showReviewDialog,
        onModifyDates: _showDateEditDialog,
      ),
      2 => _RoomsPage(
        controller: _controller,
        startDate: _startDate,
        endDate: _endDate,
        guestCount: _guestCount,
        role: _role,
        onFiltersChanged: _setFilters,
        onSearch: _openRooms,
        onReserve: (room) => _showReservationDialog(initialRoom: room),
        onStatusChanged: _changeRoomStatus,
      ),
      _ => _AccountPage(
        controller: _controller,
        role: _role,
        activeUser: _activeUser,
        onRoleChanged: _changeRole,
        onUserChanged: _changeUser,
      ),
    };
  }

  void _openRooms() {
    setState(() => _selectedIndex = 1);
  }

  void _setFilters(DateTime startDate, DateTime endDate, int guestCount) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate.isAfter(startDate)
          ? endDate
          : startDate.add(const Duration(days: 1));
      _guestCount = guestCount;
    });
  }

  void _changeRole(_AccountRole role) {
    setState(() {
      _role = role;
      _selectedIndex = 0;
      _activeUser = switch (role) {
        _AccountRole.gosc => _controller.repozytorium.goscie.first,
        _AccountRole.recepcjonista =>
          _controller.repozytorium.recepcjonisci.first,
      };
    });
  }

  void _changeUser(Uzytkownik user) {
    setState(() => _activeUser = user);
  }

  void _changeRoomStatus(Pokoj room, StatusPokoju status) {
    setState(() {
      _controller.zmienStatusPokoju(
        idPokoju: room.idPokoju,
        nowyStatus: status,
      );
    });
    _message('Status pokoju ${room.nrPokoju}: ${_roomStatusLabel(status)}');
  }

  Future<void> _showReservationDialog({Pokoj? initialRoom}) async {
    final activeGuest = _activeUser;
    if (activeGuest is! Gosc) {
      _message('Rezerwacje moze utworzyc tylko gosc hotelowy');
      return;
    }

    final result = await showModalBottomSheet<_ReservationDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _ReservationSheet(
          guest: activeGuest,
          rooms: _controller.repozytorium.pokoje,
          initialRoom: initialRoom,
          initialStartDate: _startDate,
          initialEndDate: _endDate,
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      late final Rezerwacja rezerwacja;
      setState(() {
        rezerwacja = _controller.utworzRezerwacje(
          idGoscia: result.guest.idUzytkownika,
          idPokoju: result.room.idPokoju,
          dataPoczatkowa: result.startDate,
          dataKoncowa: result.endDate,
        );
        _selectedIndex = 2;
      });
      _message('Rezerwacja zostala zapisana. PIN: ${rezerwacja.kodPin}');
    } on StateError catch (error) {
      _message(error.message);
    }
  }

  void _payReservation(Rezerwacja reservation) {
    final wasPaid = reservation.platnosc?.czyPoprawna == true;
    setState(() {
      _controller.wykonajPlatnosc(idRezerwacji: reservation.idRezerwacji);
    });
    _message(
      wasPaid
          ? 'Rezerwacja jest juz oplacona'
          : reservation.platnosc?.czyPoprawna == true
          ? 'Platnosc przyjeta'
          : 'Platnosc odrzucona',
    );
  }

  void _checkInReservation(Rezerwacja reservation) {
    try {
      late final String pin;
      setState(() {
        pin = _controller.zamelduj(idRezerwacji: reservation.idRezerwacji);
      });
      _message('Kod PIN do pokoju: $pin');
    } on StateError catch (error) {
      _message(error.message);
    }
  }

  void _checkOutReservation(Rezerwacja reservation) {
    final checkedOut = _controller.wymelduj(
      idRezerwacji: reservation.idRezerwacji,
    );
    if (checkedOut) {
      setState(() {});
    }
    _message(checkedOut ? 'Wymeldowanie zakonczone' : 'Nie mozna wymeldowac');
  }

  void _cancelReservation(Rezerwacja reservation) {
    final cancelled = _controller.anulujRezerwacje(
      idRezerwacji: reservation.idRezerwacji,
      powod: 'Anulowano przez klienta',
    );
    if (cancelled) {
      setState(() {});
    }
    _message(cancelled ? 'Rezerwacja anulowana' : 'Nie znaleziono rezerwacji');
  }

  Future<void> _showReviewDialog(Rezerwacja reservation) async {
    final result = await showModalBottomSheet<_ReviewDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _ReviewSheet(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _controller.dodajOcenePobytu(
        idRezerwacji: reservation.idRezerwacji,
        liczbaGwiazdek: result.stars,
        komentarz: result.comment,
        dataDodania: DateTime.now(),
      );
    });
    _message('Dziekujemy za opinie');
  }

  Future<void> _showDateEditDialog(Rezerwacja reservation) async {
    final result = await showModalBottomSheet<_DateRangeDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _DateEditSheet(
          startDate: reservation.dataPoczatkowa,
          endDate: reservation.dataKoncowa,
        );
      },
    );

    if (result == null) {
      return;
    }

    final changed = _controller.modyfikujDatyRezerwacji(
      idRezerwacji: reservation.idRezerwacji,
      nowaDataPoczatkowa: result.startDate,
      nowaDataKoncowa: result.endDate,
    );
    if (changed) {
      setState(() {});
    }
    _message(
      changed ? 'Termin zaktualizowany' : 'Wybrany termin jest niedostepny',
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
