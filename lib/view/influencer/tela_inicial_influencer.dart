// ignore_for_file: prefer_final_fields, sized_box_for_whitespace, avoid_print, prefer_interpolation_to_compose_strings, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parceiroezze/widget/estabelecimento_card.dart';

class ListaEstabelecimentosInfluencer extends StatefulWidget {
  const ListaEstabelecimentosInfluencer({Key? key}) : super(key: key);

  @override
  State<ListaEstabelecimentosInfluencer> createState() =>
      _ListaEstabelecimentosState();
}

class _ListaEstabelecimentosState
    extends State<ListaEstabelecimentosInfluencer> {
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Todas as Categorias";
  StreamController<List<DocumentSnapshot>> _searchResultsController =
      StreamController<List<DocumentSnapshot>>();

  @override
  void dispose() {
    _searchResultsController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Estabelecimentos',
          style: TextStyle(color: Color.fromRGBO(113, 0, 150, 0.8)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _searchResultsController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                List<DocumentSnapshot> estabelecimentos =
                    snapshot.data ?? <DocumentSnapshot>[];

                return ListView.builder(
                  itemCount: estabelecimentos.length,
                  itemBuilder: (context, index) {
                    final estabelecimentoData =
                        estabelecimentos[index].data() as Map<String, dynamic>;
                    return EstabelecimentoCardInflu(estabelecimentoData);
                  },
                );
              },
            ),
          ),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.30,
                    child: TextField(
                      onChanged: (value) {
                        _updateSearchResults(value);
                      },
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black54),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _updateSearchResults('');
                          },
                        ),
                        filled: false,
                        fillColor: const Color.fromARGB(255, 94, 197, 212),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 94, 197, 212),
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 94, 197, 212),
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 94, 197, 212),
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        labelText: 'Pesquisar',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 94, 197, 212),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_alt_outlined),
                    onSelected: (String selectedCategory) {
                      setState(() {
                        _selectedCategory = selectedCategory;
                      });
                      _updateSearchResults(_searchController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Todas as Categorias',
                          child: Text('Todas as Categorias'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Gastronomia',
                          child: Text('Gastronomia'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Saúde',
                          child: Text('Saúde'),
                        ),
                        // Adicione mais categorias conforme necessário
                      ];
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _updateSearchResults(String searchTerm) async {
    try {
      QuerySnapshot querySnapshot;

      if (searchTerm.isEmpty) {
        if (_selectedCategory == "Todas as Categorias") {
          print("Fetching all establishments");
          querySnapshot = await FirebaseFirestore.instance
              .collection('estabelecimentos')
              .get();
        } else {
          print("Fetching establishments for category: $_selectedCategory");
          querySnapshot = await FirebaseFirestore.instance
              .collection('estabelecimentos')
              .where('cat', isEqualTo: _selectedCategory)
              .get();
        }
      } else {
        if (_selectedCategory == "Todas as Categorias") {
          querySnapshot = await FirebaseFirestore.instance
              .collection('estabelecimentos')
              .where('nomeFantasia', isGreaterThanOrEqualTo: searchTerm)
              .where('nomeFantasia', isLessThanOrEqualTo: searchTerm + '\uf8ff')
              .get();
        } else {
          querySnapshot = await FirebaseFirestore.instance
              .collection('estabelecimentos')
              .where('cat', isEqualTo: _selectedCategory)
              .where('nomeFantasia', isGreaterThanOrEqualTo: searchTerm)
              .where('nomeFantasia', isLessThanOrEqualTo: searchTerm + '\uf8ff')
              .get();
        }
      }

      print("Number of results: ${querySnapshot.size}");

      _searchResultsController.add(querySnapshot.docs);
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _updateSearchResults('');
  }
}
