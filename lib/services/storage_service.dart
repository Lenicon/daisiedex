import 'dart:convert';
import 'dart:io';
import 'package:floradex/models/plant_result.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const int maxFileSize = 20 * 1024 * 1024; // 20 MB in bytes

  static List<dynamic> savedPlants = [];

  // 2. This can now be called from ANY file: StorageService.load();
  static Future<void> load() async {
    final directory = await getApplicationDocumentsDirectory();
    List<dynamic> allPlants = [];
    
    final files = directory.listSync().where((file) => file.path.contains('collection_'));

    for (var file in files) {
      if (file is File) {
        String content = await file.readAsString();
        allPlants.addAll(jsonDecode(content));
      }
    }
    
    // Update the global list
    savedPlants = allPlants;
  }


  static Future<void> savePlant(PlantResult result) async {
    final directory = await getApplicationDocumentsDirectory();
    int fileIndex = 1;
    File targetFile;

    // Find the current active file
    while (true) {
      targetFile = File('${directory.path}/collection_$fileIndex.json');
      if (await targetFile.exists()) {
        int size = await targetFile.length();
        if (size < maxFileSize) break; // Use this file
        fileIndex++; // File too big, move to next index
      } else {
        await targetFile.create();
        await targetFile.writeAsString('[]'); // Initialize empty list
        break;
      }
    }

    // Read current content, add new result, and write back
    List<dynamic> currentList = jsonDecode(await targetFile.readAsString());
    currentList.add({
      'nickname': result.nickname,
      'firstImage': result.imagePaths.first,
      'scientificName': result.scientificName,
      'authorship': result.authorship,
      'family': result.family,
      'commonNames': result.commonNames,
      'notes': result.notes
      // Add other fields you want to save
    });

    await targetFile.writeAsString(jsonEncode(currentList));
  }

  static Future<List<dynamic>> getAllSavedPlants() async {
    final directory = await getApplicationDocumentsDirectory();
    List<dynamic> allPlants = [];
    
    // List all files in the directory starting with 'collection_'
    final files = directory.listSync().where((file) => file.path.contains('collection_'));

    for (var file in files) {
      if (file is File) {
        String content = await file.readAsString();
        allPlants.addAll(jsonDecode(content));
      }
    }
    return allPlants;
  }


  static Future<String> saveImagePermanently(String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = p.basename(tempPath); // Gets the filename (e.g., image.jpg)
    
    // Create a 'photos' subfolder if it doesn't exist
    final folder = Directory('${directory.path}/photos');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final permanentPath = '${folder.path}/$name';
    
    // Copy the file from temp to permanent storage
    final File tempFile = File(tempPath);
    final File newFile = await tempFile.copy(permanentPath);

    return newFile.path; // Return the new path to save in JSON
  }
}