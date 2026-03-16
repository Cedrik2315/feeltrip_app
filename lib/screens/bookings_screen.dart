import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tienes reservas',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    child: Text('Explorar Viajes'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              final booking = Booking.fromJson(data);

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple[100],
                    ),
                    child: Icon(Icons.flight, color: Colors.deepPurple),
                  ),
                  title: Text(booking.tripTitle,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(booking.startDate
                      .toLocal()
                      .toString()
                      .split(' ')[0]), // Date fallback
                  trailing: Chip(
                    label: Text(_getStatusLabel(booking.status)),
                    backgroundColor: _getStatusColor(booking.status),
                    labelStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('ID Reserva:', booking.id),
                          SizedBox(height: 8),
                          _buildInfoRow(
                              'Fecha:',
                              DateFormat('dd/MM/yyyy')
                                  .format(booking.bookingDate)),
                          SizedBox(height: 8),
                          _buildInfoRow('Viajeros:',
                              '\${booking.numberOfPeople} ${booking.numberOfPeople == 1 ? 'persona' : 'personas'}'),
                          SizedBox(height: 8),
                          _buildInfoRow('Total:', '\$${booking.totalPrice}',
                              bold: true, color: Colors.deepPurple),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              if (booking.status != 'cancelled')
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _showCancelDialog(
                                        booking, doc.reference),
                                    child: Text('Cancelar'),
                                  ),
                                ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Detalles enviados a tu email')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple),
                                  child: Text('Ver Detalles'),
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
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool bold = false, Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color)),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmada';
      case 'pending':
        return 'En Proceso';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelDialog(Booking booking, DocumentReference docRef) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Reserva'),
        content: Text(
            '¿Estás seguro de que deseas cancelar la reserva "\${booking.tripTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await docRef.update({'status': 'cancelled'});
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Reserva cancelada'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}
