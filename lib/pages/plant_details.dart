

import 'dart:io';

import 'package:floradex/main.dart';
import 'package:floradex/models/plant_result.dart';
import 'package:floradex/services/storage_service.dart';
import 'package:flutter/material.dart';

class PlantDetailScreen extends StatefulWidget {
  final PlantResult plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _notesController;
  // late String _originalNickname; // To find the record in the file later
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.plant.nickname);
    _notesController = TextEditingController(text: widget.plant.notes);
    // _originalNickname = widget.plant.nickname;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Plant Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: _showcasePlant(),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 60),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10, 
            )]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Row(
            children:[
              _backButton(context),
              const SizedBox(width: 10),
              _updateButton(),
            ]
          )],
        ),
      ),
    );
  }

  SingleChildScrollView _showcasePlant() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // REUSE your collage logic here
          _buildDynamicCollage(widget.plant.imagePaths),
          const SizedBox(height: 16),
          
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(labelText: 'Nickname', border: OutlineInputBorder()),
          ),
          
          const SizedBox(height: 16),

          _infoRow("Scientific Name", widget.plant.scientificName),
          _infoRow("Authorship", widget.plant.authorship),
          _infoRow("Family", widget.plant.family),
          _infoRow("Common Names", widget.plant.commonNames.join(", ")),

          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _isSaving ? null : _showDeleteConfirmation,
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text("Delete from Collection", style: TextStyle(color: Colors.red)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _backButton(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Back", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      ),
    );
  }

  Expanded _updateButton() {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          disabledBackgroundColor: Colors.grey
        ),
        onPressed: _isSaving ? null : _handleUpdate,
        child: Text(_isSaving ? "Updating..." : "Update Details", style: TextStyle(color: Colors.white)),
      ),
    );
  }


  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.start,
          backgroundColor: Colors.white,
          title: const Text("Delete Plant?"),
          content: const Text("This will permanently remove this plant from your collection and cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.pop(context);
                
                await StorageService.deletePlant(widget.plant.id);
                
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context); 
                  snackbarKey.currentState?.showSnackBar(
                    const SnackBar(content: Text("Plant removed from collection"), duration: Durations.short4)
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => _isSaving = true);
    try {
      widget.plant.nickname = _nicknameController.text;
      widget.plant.notes = _notesController.text;

      await StorageService.updatePlant(widget.plant);
      
      // Global refresh so the grid updates
      await StorageService.load();

      if (mounted) {
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(content: Text("Changes saved!"), duration: Durations.short4)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorDialog("Update failed: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ... (Paste your _buildDynamicCollage, _imageWrapper, _infoRow, and _showErrorDialog here)
  Widget _buildDynamicCollage(List<String> paths) {
    double height = 200; // Total height for the banner
    int count = paths.length;

    // if (count == 0) return const SizedBox.shrink();

    // Layout for 1 Image: Full screen width
    if (count == 1) {
      return SizedBox(
        height: height,
        child: Row(
          children:[Expanded(flex:1, child:_imageWrapper(paths[0], height))]
        )
      );
    }

    // Layout for 2 Images: Two equal columns
    if (count == 2) {
      return SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(child: _imageWrapper(paths[0], height)),
            const SizedBox(width: 2),
            Expanded(child: _imageWrapper(paths[1], height)),
          ],
        ),
      );
    }

    // Layout for 3 Images: Large left, two stacked on the right
    if (count == 3) {
      return SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(flex: 4, child: _imageWrapper(paths[0], height)),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _imageWrapper(paths[1], height / 2)),
                  const SizedBox(height: 2),
                  Expanded(child: _imageWrapper(paths[2], height / 2)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Layout for 4 or 5 Images: Large left, three stacked on the right
    // (Matches your 4th diagram with the "+" overlay logic)
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 5, child: _imageWrapper(paths[0], height)),
          const SizedBox(width: 2),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(flex:2,child: _imageWrapper(paths[1], height / 3)),
                const SizedBox(height: 2),
                Expanded(flex:2,child: _imageWrapper(paths[2], height / 3)),
                const SizedBox(height: 2),
                Expanded(
                  // flex: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _imageWrapper(paths[3], height / 3),
                      if (count > 4)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              "+${count - 4}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to handle the File Image and fit
  Widget _imageWrapper(String path, double height) {
    return Image.file(
      File(path),
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18)),
          const Divider(),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Transform.translate(offset: Offset(0, 2), child: Text("Error", style: TextStyle(fontWeight: FontWeight.bold),)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}