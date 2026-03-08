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

class _BookingsScreenState extends State<BookingsScreen> {
  final AppDataRepository _repository = AppDataRepository();

  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: Colors.deepPurple,
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
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes reservas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Explorar Viajes'),
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
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              final booking = _bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple[100],
                    ),
                    child: const Center(
                      child: Icon(Icons.flight_takeoff, color: Colors.deepPurple),
                    ),
                  ),
                  title: Text(
                    booking.tripTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(booking.startDate),
                  ),
                  trailing: Chip(
                    label: Text(booking.status),
                    backgroundColor: _getStatusColor(booking.status),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
                              if (booking.status != 'Cancelada')
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _showCancelDialog(index),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Detalles enviados a tu email'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                  ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmada':
        return Colors.green;
      case 'En Proceso':
        return Colors.orange;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelDialog(int index) {
    final booking = _bookings[index];
    final rootContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          'Estas seguro de que deseas cancelar la reserva "${booking.tripTitle}"?',
        ),
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
                setState(() {
                  _bookings[index] = Booking(
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
                  const SnackBar(
                    content: Text('Reserva cancelada'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo cancelar la reserva'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Si, Cancelar'),
          ),
        ],
      ),
    );
  }
}
