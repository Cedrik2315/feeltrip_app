import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_flags.dart';
import '../core/error_presenter.dart';
import '../models/booking_model.dart';
import '../repositories/app_data_repository.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with TickerProviderStateMixin {
  final AppDataRepository _repository = AppDataRepository();
  late TabController _tabController;

  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getCurrentUserBookings();
      if (!mounted) return;
      setState(() => _bookings = result.getOrElse([]));
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = ErrorPresenter.message(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildUpcomingBookings() {
    final now = DateTime.now();
    final upcoming = _bookings
        .where((b) => b.startDate.isAfter(now) && b.status != 'Cancelada')
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return _buildBookingsList(upcoming, 0);
  }

  Widget _buildPastBookings() {
    final now = DateTime.now();
    final past = _bookings
        .where((b) => b.startDate.isBefore(now) && b.status == 'Confirmada')
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return _buildBookingsList(past, 1);
  }

  Widget _buildCancelledBookings() {
    final cancelled = _bookings
        .where((b) => b.status == 'Cancelada')
        .toList()
        ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return _buildBookingsList(cancelled, 2);
  }

  Widget _buildBookingsList(List<Booking> bookings, int tabIndex) {
    if (bookings.isEmpty) {
      IconData icon;
      String message;
      switch (tabIndex) {
        case 0:
          icon = Icons.flight_takeoff;
          message = "No tienes viajes próximos";
          break;
        case 1:
          icon = Icons.map_outlined;
          message = "Aún no has viajado con nosotros";
          break;
        case 2:
          icon = Icons.check_circle_outline;
          message = "No hay cancelaciones 🎉";
          break;
        default:
          icon = Icons.calendar_today;
          message = "No hay reservas";
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (showDemoIndicators && _repository.isMockMode)
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Modo demo activo: reservas simuladas',
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  leading: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.withValues(alpha: 0.1),
                            Colors.purple[100]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff,
                        size: 40,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  title: Text(
                    booking.tripTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(booking.startDate),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${booking.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusDisplay(booking.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('ID Reserva:', booking.id),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Fecha de reserva:',
                            DateFormat('dd/MM/yyyy').format(booking.bookingDate),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Viajeros:',
                            '${booking.numberOfPeople} ${booking.numberOfPeople == 1 ? 'persona' : 'personas'}',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Total:',
                            '\$${booking.totalPrice.toStringAsFixed(2)}',
                            bold: true,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (tabIndex == 0 && booking.status != 'Cancelada')
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    onPressed: () => _showCancelDialog(booking),
                                    child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              if (tabIndex == 0 && booking.status != 'Cancelada') const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Detalles enviados a tu email')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                  child: const Text('Ver Detalles'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'Confirmada':
        return '✅ Confirmada';
      case 'En Proceso':
        return '⏳ Pendiente';
      case 'Cancelada':
        return '❌ Cancelada';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmada':
        return Colors.green;
      case 'En Proceso':
        return Colors.amber[700]!;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool bold = false,
    Color color = Colors.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(Booking booking) {
    final rootContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text('¿Estás seguro de que deseas cancelar la reserva "${booking.tripTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(rootContext);
              Navigator.pop(dialogContext);

              bool success = false;
              try {
                final result = await _repository.cancelBooking(booking.id);
                success = result.getOrElse(false);
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(ErrorPresenter.message(e)), backgroundColor: Colors.redAccent),
                );
                return;
              }
              if (!mounted) return;

              if (success) {
                final int globalIndex = _bookings.indexWhere((b) => b.id == booking.id);
                if (globalIndex != -1) {
                  setState(() {
                    _bookings[globalIndex] = Booking(
                      id: booking.id,
                      userId: booking.userId,
                      tripId: booking.tripId,
                      tripTitle: booking.tripTitle,
                      numberOfPeople: booking.numberOfPeople,
                      totalPrice: booking.totalPrice,
                      status: 'Cancelada',
                      bookingDate: booking.bookingDate,
                      startDate: booking.startDate,
                      passengers: booking.passengers,
                      paymentMethod: booking.paymentMethod,
                      isPaid: booking.isPaid,
                    );
                  });
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Reserva cancelada'), backgroundColor: Colors.red),
                  );
                }
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('No se pudo cancelar la reserva'), backgroundColor: Colors.redAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.deepPurple,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              dividerHeight: 0,
              tabs: const [
                Tab(text: '✈️ Próximas'),
                Tab(text: '🗺️ Pasadas'),
                Tab(text: '❌ Canceladas'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingBookings(),
                    _buildPastBookings(),
                    _buildCancelledBookings(),
                  ],
                ),
    );
  }
}
