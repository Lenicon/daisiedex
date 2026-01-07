import 'package:floradex/models/plant_photo.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  // Now we use a dynamic list of your custom class
  final List<PlantPhoto> _selectedPhotos = [];
  final int _maxPhotos = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Organ Photos: ${_selectedPhotos.length} / $_maxPhotos (Up to 5 total)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              // We add 1 to the count to show the "Add" button
              itemCount: _selectedPhotos.length < _maxPhotos 
                  ? _selectedPhotos.length + 1 
                  : _selectedPhotos.length,
              itemBuilder: (context, index) {
                if (index < _selectedPhotos.length) {
                  return _buildImageThumbnail(index);
                } else {
                  return _buildAddButton();
                }
              },
            ),
          ),
          _buildIdentifyButton(),
        ],
      ),
    );
  }

  // UI for an image that has already been picked
  Widget _buildImageThumbnail(int index) {
    final photo = _selectedPhotos[index];
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(photo.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Label overlay (Leaf, Flower, etc.)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              photo.organ.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPhotos.removeAt(index)),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // The empty slot used to add a new photo
  final ImagePicker _picker = ImagePicker();
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _showPickerMenu(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            style: BorderStyle.none
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              // color: Colors.green[800],
              size: 32
            ),
            const SizedBox(height: 8),
            Text("Add Photo", style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold
            )),
          ],
        ),
      ),
    );
  }

  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _processImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _processImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80, // Reduces file size for faster API uploads
    );

    if (image != null) {
      // Re-using the organ dialog from our previous step
      String? selectedOrgan = await _showOrganDialog();

      if (selectedOrgan != null) {
        setState(() {
          _selectedPhotos.add(
            PlantPhoto(path: image.path, organ: selectedOrgan),
          );
        });
      }
    }
  }

  Future<String?> _showOrganDialog() async {
    final List<String> options = ['Leaf', 'Flower', 'Fruit', 'Bark', "I don't know (Auto)"];
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Identify the organ'),
          content: const Text('Which part of the plant is in this photo?'),
          actions: options.map((String organ) {
            return TextButton(
              onPressed: () => Navigator.pop(context, organ),
              child: Text(organ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildIdentifyButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          disabledBackgroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _selectedPhotos.isEmpty ? null : () {
          // Logic to send _selectedPhotos to the API
        },
        child: const Text("Identify Plant", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text('Plant Scanner', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
      elevation: 0.0,
      centerTitle: true,
    );
  }
}