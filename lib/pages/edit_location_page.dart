import 'package:flutter/material.dart';

class EditLocationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController locationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lokasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Nama Lokasi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String newLocation = locationController.text.trim();
                if (newLocation.isNotEmpty) {
                  Navigator.pop(context, newLocation);
                }
              },
              child: Text('Simpan Lokasi'),
            ),
          ],
        ),
      ),
    );
  }
}
