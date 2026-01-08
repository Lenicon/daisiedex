class PlantResult {
  final String id; // Add this
  String nickname;
  String notes;
  final List<String> imagePaths;
  final String scientificName;
  final String authorship;
  final String family;
  final List<String> commonNames;

  PlantResult({
    String? id, // Optional in constructor
    required this.nickname,
    this.notes = '',
    required this.imagePaths,
    required this.scientificName,
    required this.authorship,
    required this.family,
    required this.commonNames,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(); // Generate ID if not provided
}