// ignore_for_file: prefer_final_fields, sized_box_for_whitespace, avoid_print, prefer_interpolation_to_compose_strings, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_flutter/social_media_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListaEstabelecimentos extends StatefulWidget {
  const ListaEstabelecimentos({Key? key}) : super(key: key);

  @override
  State<ListaEstabelecimentos> createState() => _ListaEstabelecimentosState();
}

class _ListaEstabelecimentosState extends State<ListaEstabelecimentos> {
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
                    return EstabelecimentoCard(estabelecimentoData);
                  },
                );
              },
            ),
          ),
          Card(
            elevation: 2.0,
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

class EstabelecimentoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const EstabelecimentoCard(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uri _url = Uri.parse('https://www.instagram.com/${data['arrobaInsta']}/');
    Uri _enderecoUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${data['endereco']}+${data['numero']}+${data['cidade']}+${data['cep']}');
    Uri _whatsUrl = Uri.parse('https://wa.me/+${data['telefoneresponsavel']}');

    return Card(
      color: const Color.fromRGBO(255, 255, 255, 1),
      elevation: 1,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['imageUrl'] != null)
              Image.network(
                data['imageUrl'],
                width: MediaQuery.of(context).size.height,
                height: 150,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.network(
                        data['imageUrlLogo'],
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data['nomeFantasia']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color.fromRGBO(113, 0, 150, 0.8)),
                          ),
                          Text(
                            '@${data['arrobaInsta']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w100,
                                color: Colors.black38),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          launchUrl(_url);
                        },
                        color: const Color.fromARGB(255, 94, 197, 212),
                        icon: const Icon(SocialIconsFlutter.instagram),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          launchUrl(_enderecoUrl);
                        },
                        color: const Color.fromARGB(255, 94, 197, 212),
                        icon: const Icon(Icons.location_on_outlined),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          launchUrl(_whatsUrl);
                        },
                        color: const Color.fromARGB(255, 94, 197, 212),
                        icon: const Icon(FontAwesomeIcons.whatsapp),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Color.fromARGB(255, 94, 197, 212),
                            ),
                            Text(
                              "Editar Perfil",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 94, 197, 212)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void launchUrl(Uri url) async {
  if (await canLaunch(url.toString())) {
    await launch(url.toString());
  } else {
    throw 'Não foi possível abrir o URL: $url';
  }
}
