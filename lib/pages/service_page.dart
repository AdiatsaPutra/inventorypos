import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:inventorypos/provider/service_provider.dart';
import 'package:inventorypos/widgets/app_button.dart';
import 'package:provider/provider.dart';

class ServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(serviceProvider),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AppButton(
                  title: 'Tambah Service',
                  onPressed: () {
                    _showCreateDialog(context);
                  },
                ),
              ),
              Expanded(
                child: serviceProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildServiceTable(serviceProvider, context),
              ),
              _buildPagination(serviceProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ServiceProvider serviceProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: serviceProvider.searchController,
        decoration: InputDecoration(
          labelText: 'Cari service',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              serviceProvider.onSearch();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTable(
      ServiceProvider serviceProvider, BuildContext context) {
    if (serviceProvider.services.isEmpty) {
      return Center(child: Text('Belum ada Service'));
    }
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Kode Service')),
            DataColumn(label: Text('Nama Service')),
            DataColumn(label: Text('No. HP')),
            DataColumn(label: Text('Keluhan')),
            DataColumn(label: Text('Tipe Device')),
            // DataColumn(label: Text('Price')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: serviceProvider.services.map((service) {
            return DataRow(cells: [
              DataCell(Text(service['code'] ?? '')),
              DataCell(Text(service['name'] ?? '-')),
              DataCell(Text(service['phone'].toString().isEmpty
                  ? '-'
                  : service['phone'])),
              DataCell(Text(service['description'] ?? '')),
              DataCell(Text(service['device_type'] ?? '')),
              // DataCell(Text(service['price']?.toString() ?? '0.0')),
              DataCell(_buildServiceActions(service['id'], context)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination(ServiceProvider serviceProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: serviceProvider.currentPage > 1
              ? () =>
                  serviceProvider.onPagination(serviceProvider.currentPage - 1)
              : null,
        ),
        Text('Halaman ${serviceProvider.currentPage}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: serviceProvider.services.length ==
                  serviceProvider.itemsPerPage
              ? () =>
                  serviceProvider.onPagination(serviceProvider.currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildServiceActions(int serviceId, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.info,
            color: Colors.blue,
          ),
          onPressed: () => _showDetailDialog(serviceId, context),
        ),
        IconButton(
          icon: Icon(
            Icons.edit,
            color: Colors.yellow,
          ),
          onPressed: () => _showEditDialog(serviceId, context),
        ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () => _showDeleteDialog(serviceId, context),
        ),
      ],
    );
  }

  void _showDetailDialog(int serviceId, BuildContext context) {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    final service =
        serviceProvider.services.firstWhere((s) => s['id'] == serviceId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Service'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Kode Service:', service['code'] ?? '-'),
              _buildDetailRow('Nama Service:', service['name'] ?? '-'),
              _buildDetailRow('No. HP:', service['phone'] ?? '-'),
              _buildDetailRow('Keluhan:', service['description'] ?? '-'),
              _buildDetailRow('Tipe Device:', service['device_type'] ?? '-'),
              // _buildDetailRow('Harga:',
              //     service['price'] != null ? 'Rp ${service['price']}' : '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final descriptionController = TextEditingController();
    final deviceTypeController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Service'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'No HP (Opsional)'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: deviceTypeController,
                decoration: InputDecoration(labelText: 'Tipe Device'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Keluhan'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Harga(Opsional)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyTextInputFormatter.currency(
                    decimalDigits: 0,
                    locale: 'id_ID',
                    symbol: 'Rp',
                  )
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final code =
                  '${deviceTypeController.text.trim()}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}';
              final service = {
                'code': code,
                'name': nameController.text,
                'phone': phoneController.text,
                'description': descriptionController.text,
                'device_type': deviceTypeController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
              };
              final serviceProvider =
                  Provider.of<ServiceProvider>(context, listen: false);
              final res = await serviceProvider.createService(service);
              if (res.isSuccess) {
                serviceProvider.fetchAllServicesFromDB();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil'),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int serviceId, BuildContext context) {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    final service =
        serviceProvider.services.firstWhere((s) => s['id'] == serviceId);
    final code = service['code'];

    final nameController = TextEditingController(text: service['name']);
    final phoneController = TextEditingController(text: service['phone']);
    final descriptionController =
        TextEditingController(text: service['description']);
    final deviceTypeController =
        TextEditingController(text: service['device_type']);
    final priceController = TextEditingController(
        text: service['price'] == 0.0
            ? ''
            : (service['price'] as double).toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Service'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'No HP (Opsional)'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: deviceTypeController,
                decoration: InputDecoration(labelText: 'Tipe Device'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Keluhan'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Harga (Opsional)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyTextInputFormatter.currency(
                    decimalDigits: 0,
                    locale: 'id_ID',
                    symbol: 'Rp',
                  )
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updatedService = {
                'id': serviceId,
                'code': code,
                'name': nameController.text,
                'phone': phoneController.text,
                'description': descriptionController.text,
                'device_type': deviceTypeController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
              };
              serviceProvider
                  .updateService(serviceId, updatedService)
                  .then((result) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result.message),
                ));
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int serviceId, BuildContext context) {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('Delete Service'),
    //     content: Text('Are you sure you want to delete this service?'),
    //     actions: [
    //       TextButton(
    //         onPressed: () {
    //           Navigator.pop(context);
    //         },
    //         child: Text('Delete'),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: Text('Cancel'),
    //       ),
    //     ],
    //   ),
    // );
    serviceProvider.deleteService(serviceId).then((result) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message),
      ));
    });
  }
}
