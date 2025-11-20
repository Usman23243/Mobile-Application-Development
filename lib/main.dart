import 'package:flutter/material.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const DashboardScreen(),
    );
  }
}

class Device {
  String name;
  String type;
  String room;
  bool isOn;
  double value;
  IconData icon;

  Device({required this.name, required this.type, required this.room, this.isOn = false, this.value = 50, required this.icon});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Device> devices = [
    Device(name: "Living Room Light", type: "Light", room: "Living Room", icon: Icons.lightbulb_outline),
    Device(name: "Bedroom Fan", type: "Fan", room: "Bedroom", icon: Icons.air),
    Device(name: "Main AC", type: "AC", room: "Hall", icon: Icons.ac_unit),
    Device(name: "Front Camera", type: "Camera", room: "Outdoor", isOn: true, icon: Icons.camera_alt),
  ];

  void addDevice(Device device) {
    setState(() {
      devices.add(device);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text("Smart Home Dashboard"),
        actions: const [
          CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/300")),
          SizedBox(width: 16),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final d = devices[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceDetailsScreen(device: d),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: d.isOn ? Colors.blue.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(d.icon, size: 40, color: d.isOn ? Colors.blue : Colors.black54),
                    const SizedBox(height: 10),
                    Text(d.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Switch(
                      value: d.isOn,
                      onChanged: (val) {
                        setState(() {
                          d.isOn = val;
                        });
                      },
                    ),
                    Text(d.isOn ? "Status: ON" : "Status: OFF"),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddDeviceDialog(onAdd: addDevice),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DeviceDetailsScreen extends StatefulWidget {
  final Device device;
  const DeviceDetailsScreen({super.key, required this.device});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(widget.device.icon, size: 120, color: Colors.blue),
            const SizedBox(height: 20),
            Text(widget.device.isOn ? "Device is ON" : "Device is OFF", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Slider(
              value: widget.device.value,
              min: 0,
              max: 100,
              onChanged: (val) {
                setState(() {
                  widget.device.value = val;
                });
              },
            ),
            Text("Value: ${widget.device.value.toInt()}%"),
          ],
        ),
      ),
    );
  }
}

class AddDeviceDialog extends StatefulWidget {
  final Function(Device) onAdd;
  const AddDeviceDialog({super.key, required this.onAdd});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final nameCtrl = TextEditingController();
  String type = "Light";
  final roomCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Device"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Device Name")),

          DropdownButton<String>(
            value: type,
            items: ["Light", "Fan", "AC", "Camera"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => type = val!),
          ),

          TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: "Room Name")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),

        ElevatedButton(
          onPressed: () {
            final icon = type == "Light"
                ? Icons.lightbulb_outline
                : type == "Fan"
                    ? Icons.air
                    : type == "AC"
                        ? Icons.ac_unit
                        : Icons.camera_alt;

            widget.onAdd(Device(name: nameCtrl.text, type: type, room: roomCtrl.text, icon: icon));

            Navigator.pop(context);
          },
          child: const Text("Add"),
        )
      ],
    );
  }
  
}
