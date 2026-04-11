import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/p2p_service.dart';

class ExpeditionModePage extends ConsumerStatefulWidget {
  const ExpeditionModePage({super.key});

  @override
  ConsumerState<ExpeditionModePage> createState() => _ExpeditionModePageState();
}

class _ExpeditionModePageState extends ConsumerState<ExpeditionModePage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isServiceRunning = false;
  String _role = 'Viajero';

  @override
  void dispose() {
    _messageController.dispose();
    // Detenemos el servicio al salir para ahorrar batería
    ref.read(p2pServiceProvider).stopAll();
    super.dispose();
  }

  Future<void> _toggleService(bool start) async {
    final service = ref.read(p2pServiceProvider);
    
    if (start) {
      final hasPermissions = await service.checkAndRequestPermissions();
      if (!hasPermissions) return;

      const myName = 'Usuario FeelTrip'; // Aquí usarías el nombre del perfil
      
      if (_role == 'Guía') {
        await service.startAdvertising(myName);
      } else {
        await service.startDiscovery(myName);
      }
    } else {
      service.stopAll();
    }

    setState(() => _isServiceRunning = start);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(p2pMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Expedición Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(p2pMessagesProvider.notifier).state = [],
          )
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Estado: ${_isServiceRunning ? "Activo" : "Inactivo"}'),
            subtitle: Text('Rol actual: $_role'),
            trailing: Switch(
              value: _isServiceRunning,
              onChanged: _toggleService,
            ),
          ),
          if (!_isServiceRunning)
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Viajero', label: Text('Viajero'), icon: Icon(Icons.person)),
                ButtonSegment(value: 'Guía', label: Text('Guía'), icon: Icon(Icons.hiking)),
              ],
              selected: {_role},
              onSelectionChanged: (set) => setState(() => _role = set.first),
            ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.message),
                title: Text(messages[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Escribir a los cercanos...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isServiceRunning ? () {
                    ref.read(p2pServiceProvider).broadcastMessage(_messageController.text);
                    _messageController.clear();
                  } : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}