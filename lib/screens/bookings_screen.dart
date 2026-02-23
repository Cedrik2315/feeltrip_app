import 'package:flutter/material.dart';

class BookingsScreen extends StatefulWidget {
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Map<String, dynamic>> bookings = [
    {
      'id': 'BK001',
      'title': 'Tromsø Aurora Borealis',
      'destination': 'Tromsø, Noruega',
      'date': '15/02/2026',
      'status': 'Confirmada',
      'people': 2,
      'price': 2580,
      'image': '🌌',
    },
    {
      'id': 'BK002',
      'title': 'Cocina Toscana',
      'destination': 'Toscana, Italia',
      'date': '20/03/2026',
      'status': 'En Proceso',
      'people': 1,
      'price': 980,
      'image': '🍝',
    },
    {
      'id': 'BK003',
      'title': 'Bali Yoga Retreat',
      'destination': 'Bali, Indonesia',
      'date': '01/04/2026',
      'status': 'Cancelada',
      'people': 1,
      'price': 750,
      'image': '🧘',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes reservas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text('Explorar Viajes'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
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
                      child: Center(
                        child: Text(
                          booking['image'],
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    title: Text(
                      booking['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(booking['destination']),
                    trailing: Chip(
                      label: Text(booking['status']),
                      backgroundColor: _getStatusColor(booking['status']),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'ID Reserva:',
                              booking['id'],
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              'Fecha:',
                              booking['date'],
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              'Viajeros:',
                              '${booking['people']} ${booking['people'] == 1 ? 'persona' : 'personas'}',
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              'Total:',
                              '\$${booking['price']}',
                              bold: true,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                if (booking['status'] != 'Cancelada')
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _showCancelDialog(booking);
                                      },
                                      child: Text('Cancelar'),
                                    ),
                                  ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Detalles enviados a tu email'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                    ),
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
            ),
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

  void _showCancelDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Reserva'),
        content: Text(
          '¿Estás seguro de que deseas cancelar la reserva "${booking['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                booking['status'] = 'Cancelada';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reserva cancelada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}
