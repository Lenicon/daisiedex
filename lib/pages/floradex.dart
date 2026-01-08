import 'dart:io';

import 'package:floradex/models/plant_result.dart';
import 'package:floradex/pages/plant_details.dart';
import 'package:floradex/services/storage_service.dart';
import 'package:flutter/material.dart';

class Floradex extends StatefulWidget {
  const Floradex({super.key});

  @override
  State<Floradex> createState() => _FloradexState();
}

class _FloradexState extends State<Floradex> {
  // List<dynamic> _savedPlants = [];
  // static List<dynamic> filteredPlants = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    StorageService.load();
    // if (filteredPlants.isEmpty) setState(()=>filteredPlants = StorageService.savedPlants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: Column(
        children: [
          searchField(),

          const SizedBox(height: 20),

          Expanded(
            child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: StorageService.plantsNotifier,
            builder: (context, allPlants, child) {
              final query = _searchController.text.toLowerCase();
                final filteredResults = allPlants.where((plant) {
                  final nickname = (plant['nickname'] ?? '').toString().toLowerCase();
                  return nickname.contains(query);
                }).toList();

                if (filteredResults.isEmpty) {
                  return const Center(
                    child: Text(
                      "No plants found!",
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

              return GridView.builder(
                    padding: const EdgeInsets.all(20.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final plantData = filteredResults[index];

                      // Map JSON to PlantResult object for the Details screen
                      final plantObj = PlantResult(
                        id: plantData['id'], // ID is crucial for updating/deleting
                        nickname: plantData['nickname'] ?? 'Unnamed',
                        notes: plantData['notes'] ?? "",
                        imagePaths: List<String>.from(plantData['imagePaths'] ?? []),
                        authorship: plantData['authorship'] ?? "",
                        scientificName: plantData['scientificName'] ?? "",
                        family: plantData['family'] ?? "",
                        commonNames: List<String>.from(plantData['commonNames'] ?? []),
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => PlantDetailScreen(plant: plantObj),
                            ),
                          );
                        },
                        child: _buildCollectionCard(plantData),
                      );
                    },
                  );
                },
            ),
          ),
        ],
      ),
    );
  }


  // BUILDER FUNCTIONS

  Widget _buildCollectionCard(dynamic plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
              image: DecorationImage(
                image: FileImage(File(plant['firstImage'])),
                fit: BoxFit.cover
              )
            ),
          )
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            plant['nickname'] ?? 'Unnamed',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }


  Container searchField() {
    return Container(
          margin: EdgeInsets.only(top: 30, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color.fromARGB(12, 29, 22, 23),
              blurRadius: 40,
              spreadRadius: 0.0
            )]
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(()=>{}),
            decoration: InputDecoration(
              filled: true,
              hint: Text('Search collected plant...', style: TextStyle(color: Colors.black54)),
              // fillColor: Color.fromARGB(255, 247, 220, 238),
              contentPadding: EdgeInsets.all(15),
              prefixIcon: Icon(Icons.search),
              // Clear button appears when typing
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            ),
          ),
        );
  }


  

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      title: ValueListenableBuilder<List<dynamic>>(
        valueListenable: StorageService.plantsNotifier,
        builder: (context, plants, child){

          return Text(
            'Collections (${plants.length})',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
        }
      ),
      // backgroundColor: Color.fromARGB(255, 247, 220, 238),
      elevation: 0.0,
      // shadowColor: Colors.pink,
    );
  }
}