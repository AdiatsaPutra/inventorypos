import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _services = [];
  List<Map<String, String>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = _services;
  }

  void _addService(String name, String phone, String deviceName,
      String deviceDetail, String complaint) {
    setState(() {
      _services.add({
        'name': name,
        'phone': phone,
        'deviceName': deviceName,
        'deviceDetail': deviceDetail,
        'complaint': complaint,
      });
      _filteredServices = _services;
    });
  }

  void _editService(int index, String name, String phone, String deviceName,
      String deviceDetail, String complaint) {
    setState(() {
      _services[index] = {
        'name': name,
        'phone': phone,
        'deviceName': deviceName,
        'deviceDetail': deviceDetail,
        'complaint': complaint,
      };
      _filteredServices = _services;
    });
  }

  void _deleteService(int index) {
    setState(() {
      _services.removeAt(index);
      _filteredServices = _services;
    });
  }

  void _searchServices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _services;
      } else {
        _filteredServices = _services.where((service) {
          return service['name']!.toLowerCase().contains(query.toLowerCase()) ||
              service['phone']!.toLowerCase().contains(query.toLowerCase()) ||
              service['deviceName']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              service['deviceDetail']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              service['complaint']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText:
                    'Cari berdasarkan Nama, Telepon, Perangkat, atau Keluhan',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchServices,
            ),
          ),
          // Service List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        service['name']![0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(service['name']!),
                    subtitle: Text(
                        'Telepon: ${service['phone']}\nPerangkat: ${service['deviceName']} (${service['deviceDetail']})\nKeluhan: ${service['complaint']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showServiceForm(context, index, service),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteService(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Add Service Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showServiceForm(context),
              child: const Text('Tambah Layanan'),
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceForm(BuildContext context,
      [int? index, Map<String, String>? service]) {
    final TextEditingController nameController =
        TextEditingController(text: service?['name'] ?? '');
    final TextEditingController phoneController =
        TextEditingController(text: service?['phone'] ?? '');
    final TextEditingController deviceNameController =
        TextEditingController(text: service?['deviceName'] ?? '');
    final TextEditingController deviceDetailController =
        TextEditingController(text: service?['deviceDetail'] ?? '');
    final TextEditingController complaintController =
        TextEditingController(text: service?['complaint'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Tambah Layanan' : 'Edit Layanan'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telepon'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: deviceNameController,
                  decoration:
                      const InputDecoration(labelText: 'Nama Perangkat'),
                ),
                TextField(
                  controller: deviceDetailController,
                  decoration:
                      const InputDecoration(labelText: 'Detail Perangkat'),
                ),
                TextField(
                  controller: complaintController,
                  decoration: const InputDecoration(labelText: 'Keluhan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String phone = phoneController.text.trim();
                final String deviceName = deviceNameController.text.trim();
                final String deviceDetail = deviceDetailController.text.trim();
                final String complaint = complaintController.text.trim();

                if (index == null) {
                  _addService(name, phone, deviceName, deviceDetail, complaint);
                } else {
                  _editService(
                      index, name, phone, deviceName, deviceDetail, complaint);
                }

                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
