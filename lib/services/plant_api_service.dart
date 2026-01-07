import 'package:floradex/env/env.dart';
import 'package:floradex/models/plant_photo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'dart:io';

Future<void> identifyPlant(List<PlantPhoto> selectedPhotos) async {
  String apiKey = Env.plantKey; // Replace with your key
  const String project = 'all';
  final uri = Uri.parse('https://my-api.plantnet.org/v2/identify/$project?api-key=$apiKey');

  // 1. Create the Multipart request
  var request = http.MultipartRequest('POST', uri);

  // 2. Loop through your photos and add only the ones that have a path
  for (var photo in selectedPhotos) {
    // Add the image file
    var file = await http.MultipartFile.fromPath('images', photo.path);
    request.files.add(file);
    
    // Add the corresponding organ label (must be lowercase)
    request.fields['organs'] = photo.organ.toLowerCase();
    }

  try {
    // 3. Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      
      // Accessing the scientific name from your example output:
      String topResult = data['results'][0]['species']['scientificNameWithoutAuthor'];
      print('Identified as: $topResult');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Connection error: $e');
  }
}