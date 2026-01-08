import 'dart:io';

import 'package:floradex/services/storage_service.dart';
import 'package:flutter/material.dart';

class Floradex extends StatefulWidget {
  const Floradex({super.key});

  @override
  State<Floradex> createState() => _FloradexState();
}

class _FloradexState extends State<Floradex> {
  // List<dynamic> _savedPlants = [];
  List<dynamic> _filteredPlants = [];

  @override
  void initState(){
    super.initState();
    StorageService.load();
    if (_filteredPlants.isEmpty) setState(()=>_filteredPlants = StorageService.savedPlants);
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

          Expanded(child: _filteredPlants.isEmpty
            ? const Center(child: Text("No plants collected yet!", style: TextStyle(color: Colors.black54),))
            : GridView.builder(
              padding: EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8
              ),
              itemCount: _filteredPlants.length,
              itemBuilder: (context, index) {
                final plant = _filteredPlants[index];
                return _buildCollectionCard(plant);
              },

            )
          )

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
              image: DecorationImage(
                image: FileImage(File(plant['firstImage'])),
                fit: BoxFit.cover
              )
            ),
          )
        ),
        const SizedBox(height: 8),
        Text(
          plant['nickname'] ?? 'Unnamed' ,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize:16
          ),
        )
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
            onChanged: (value) => setState(()=>_filteredPlants = StorageService.runSearch(value)),
            decoration: InputDecoration(
              filled: true,
              hint: Text('Search collected plant...', style: TextStyle(color: Colors.black54)),
              // fillColor: Color.fromARGB(255, 247, 220, 238),
              contentPadding: EdgeInsets.all(15),
              prefixIcon: Icon(Icons.search),
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
      title: Text(
        'Collections',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      // backgroundColor: Color.fromARGB(255, 247, 220, 238),
      elevation: 0.0,
      // shadowColor: Colors.pink,
    );
  }
}