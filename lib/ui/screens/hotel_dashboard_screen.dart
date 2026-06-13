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

enum _AccountRole { gosc, recepcjonista }

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.controller,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.onFiltersChanged,
    required this.onReserve,
    required this.onOpenRooms,
  });

  final HotelController controller;
  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
  final void Function(DateTime startDate, DateTime endDate, int guestCount)
  onFiltersChanged;
  final VoidCallback onReserve;
  final VoidCallback onOpenRooms;

  @override
  Widget build(BuildContext context) {
    final availableRooms = controller.znajdzDostepnePokoje(
      dataPoczatkowa: startDate,
      dataKoncowa: endDate,
      liczbaGosci: guestCount,
    );
    final reservations = controller.rezerwacje;

    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroPanel(
            onReserve: onReserve,
            onOpenRooms: onOpenRooms,
          ),
          const SizedBox(height: 18),
          _BookingCard(
            startDate: startDate,
            endDate: endDate,
            guestCount: guestCount,
            onChanged: onFiltersChanged,
            onSearch: onOpenRooms,
          ),
          const SizedBox(height: 22),
          _SectionTitle(
            title: 'Polecane pokoje',
            actionLabel: 'Zobacz wszystkie',
            onAction: onOpenRooms,
          ),
          const SizedBox(height: 12),
          if (availableRooms.isEmpty)
            const _EmptyCard(
              icon: Icons.king_bed_outlined,
              title: 'Brak pokoi w tym terminie',
            )
          else
            SizedBox(
              height: 288,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableRooms.take(3).length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final room = availableRooms[index];
                  return SizedBox(
                    width: 290,
                    child: _RoomOfferCard(
                      room: room,
                      available: true,
                      unavailableReason: null,
                      rating: _roomRating(room, reservations),
                      role: _AccountRole.gosc,
                      onReserve: () => onReserve(),
                      onStatusChanged: (_) {},
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Twoj pobyt'),
          const SizedBox(height: 12),
          if (reservations.isEmpty)
            const _EmptyCard(
              icon: Icons.luggage_outlined,
              title: 'Nie masz jeszcze rezerwacji',
            )
          else
            _StaySummaryCard(reservation: reservations.last),
        ],
      ),
    );
  }
}

class _ReceptionDashboardPage extends StatelessWidget {
  const _ReceptionDashboardPage({
    required this.controller,
    required this.onOpenReservations,
    required this.onOpenRooms,
  });

  final HotelController controller;
  final VoidCallback onOpenReservations;
  final VoidCallback onOpenRooms;

  @override
  Widget build(BuildContext context) {
    final reservations = controller.rezerwacje;
    final rooms = controller.repozytorium.pokoje;
    final activeReservations = reservations
        .where(
          (reservation) => reservation.status != StatusRezerwacji.anulowana,
        )
        .length;
    final cleaningRooms = rooms
        .where((room) => room.statusPokoju == StatusPokoju.czyszczenie)
        .length;

    return _Page(
      title: 'Panel recepcji',
      subtitle: 'Obsluga rezerwacji i statusow pokoi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisExtent: 128,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            children: [
              _MetricCard(
                icon: Icons.event_available_rounded,
                label: 'Rezerwacje',
                value: '$activeReservations',
              ),
              _MetricCard(
                icon: Icons.meeting_room_rounded,
                label: 'Pokoje',
                value: '${rooms.length}',
              ),
              _MetricCard(
                icon: Icons.cleaning_services_rounded,
                label: 'Do sprzatania',
                value: '$cleaningRooms',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Zadania recepcji'),
          const SizedBox(height: 12),
          _ReceptionActionCard(
            icon: Icons.edit_calendar_rounded,
            title: 'Zarzadzaj rezerwacjami',
            subtitle: 'Modyfikuj daty rezerwacji zgodnie z diagramem.',
            buttonLabel: 'Otworz rezerwacje',
            onPressed: onOpenReservations,
          ),
          const SizedBox(height: 12),
          _ReceptionActionCard(
            icon: Icons.meeting_room_rounded,
            title: 'Zarzadzanie pokojami',
            subtitle:
                'Zmieniaj status: dostepny, zajety, czyszczenie, wylaczony.',
            buttonLabel: 'Otworz pokoje',
            onPressed: onOpenRooms,
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Opinie pokoi'),
          const SizedBox(height: 12),
          _RoomReviewsOverview(
            rooms: rooms,
            reservations: reservations,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF6F8F83)),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3A2922),
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF75665B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceptionActionCard extends StatelessWidget {
  const _ReceptionActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFECE1D4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF5B4033)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF75665B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceptionRoomSummary extends StatelessWidget {
  const _ReceptionRoomSummary({required this.rooms});

  final List<Pokoj> rooms;

  @override
  Widget build(BuildContext context) {
    int count(StatusPokoju status) {
      return rooms.where((room) => room.statusPokoju == status).length;
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: StatusPokoju.values.map((status) {
        return _StatusPill(
          text: '${_roomStatusLabel(status)}: ${count(status)}',
          color: status == StatusPokoju.dostepny
              ? const Color(0xFF4E7B63)
              : const Color(0xFF8B4C4C),
        );
      }).toList(),
    );
  }
}

class _RoomReviewsOverview extends StatelessWidget {
  const _RoomReviewsOverview({
    required this.rooms,
    required this.reservations,
  });

  final List<Pokoj> rooms;
  final List<Rezerwacja> reservations;

  @override
  Widget build(BuildContext context) {
    final ratedRooms = rooms
        .map((room) => (room: room, rating: _roomRating(room, reservations)))
        .where((item) => item.rating.count > 0)
        .toList();

    if (ratedRooms.isEmpty) {
      return const _EmptyCard(
        icon: Icons.star_outline_rounded,
        title: 'Brak ocen pokoi',
      );
    }

    return Column(
      children: ratedRooms.map((item) {
        final latestReview = _latestRoomReview(item.room, reservations);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE1D4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF5B4033),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pokoj ${item.room.nrPokoju}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.rating.average.toStringAsFixed(1)}/5 z ${item.rating.count} ocen',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (latestReview != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            latestReview.komentarz,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF75665B),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RoomsPage extends StatelessWidget {
  const _RoomsPage({
    required this.controller,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.role,
    required this.onFiltersChanged,
    required this.onSearch,
    required this.onReserve,
    required this.onStatusChanged,
  });

  final HotelController controller;
  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
  final _AccountRole role;
  final void Function(DateTime startDate, DateTime endDate, int guestCount)
  onFiltersChanged;
  final VoidCallback onSearch;
  final void Function(Pokoj room) onReserve;
  final void Function(Pokoj room, StatusPokoju status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final rooms = controller.repozytorium.pokoje;
    final availableRooms = controller.znajdzDostepnePokoje(
      dataPoczatkowa: startDate,
      dataKoncowa: endDate,
      liczbaGosci: guestCount,
    );
    final isReception = role == _AccountRole.recepcjonista;

    return _Page(
      title: isReception ? 'Zarzadzanie pokojami' : 'Pokoje',
      subtitle: isReception
          ? 'Statusy pokoi wedlug pracy recepcji'
          : 'Wybierz pokoj dopasowany do pobytu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReception) ...[
            _ReceptionRoomSummary(rooms: rooms),
            const SizedBox(height: 20),
          ] else ...[
            _BookingCard(
              startDate: startDate,
              endDate: endDate,
              guestCount: guestCount,
              onChanged: onFiltersChanged,
              onSearch: onSearch,
            ),
            const SizedBox(height: 20),
          ],
          ...rooms.map(
            (room) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: role == _AccountRole.recepcjonista ? 336 : 278,
                child: _RoomOfferCard(
                  room: room,
                  available: availableRooms.contains(room),
                  unavailableReason: _roomUnavailableReason(
                    room: room,
                    startDate: startDate,
                    endDate: endDate,
                    guestCount: guestCount,
                  ),
                  rating: _roomRating(room, controller.rezerwacje),
                  role: role,
                  onReserve: () => onReserve(room),
                  onStatusChanged: (status) => onStatusChanged(room, status),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
