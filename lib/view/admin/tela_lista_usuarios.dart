import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parceiroezze/view/admin/tela_view_detalhes_usuario.dart';

class ListaUsuarios extends StatefulWidget {
  const ListaUsuarios({Key? key}) : super(key: key);

  @override
  _ListaUsuariosState createState() => _ListaUsuariosState();
}

class _ListaUsuariosState extends State<ListaUsuarios> {
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Todas as Categorias";

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  late StreamController<List<DocumentSnapshot>> _searchResultsController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchResultsController =
        StreamController<List<DocumentSnapshot>>.broadcast();
    _subscribeToUsers();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection('adminstradores')
              .doc(user!.uid)
              .get();

      setState(() {
        userData = userDataSnapshot.data();
        isLoading = false;
      });
    }
  }

  void _subscribeToUsers() {
    FirebaseFirestore.instance.collection('usuarios').snapshots().listen(
      (QuerySnapshot snapshot) {
        _searchResultsController.add(snapshot.docs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Parceiros',
          style: TextStyle(
            color: Color.fromRGBO(113, 0, 150, 0.8),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _searchResultsController.stream,
              builder:
                  (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                var usuarios = snapshot.data!;

                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    var usuario =
                        usuarios[index].data() as Map<String, dynamic>;
                    bool isNewUser = usuario['status'] == true;

                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Row(
                          children: [
                            Image.network(
                              'https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      usuario['nomeCompleto'],
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(113, 0, 150, 0.8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    isNewUser
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.green,
                                                size: 15,
                                              ),
                                              Text(
                                                "Liberado",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w100,
                                                    color: Colors.green,
                                                    fontSize: 10),
                                              )
                                            ],
                                          )
                                        : const Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Icon(
                                                Icons.clear,
                                                color: Colors.red,
                                                size: 15,
                                              ),
                                              Text(
                                                "Aguardando",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w100,
                                                    color: Colors.red,
                                                    fontSize: 10),
                                              )
                                            ],
                                          ),
                                    // Adiciona a categoria como subtítulo
                                  ],
                                ),
                                Row(
                                  children: [
                                    _getCategoryIcon(usuario['cat']),
                                    usuario['rating'] == 0
                                        ? const Text('Não avaliado ainda')
                                        : IgnorePointer(
                                            ignoring:
                                                true, // Desativa a interação com os widgets filhos
                                            child: RatingBar.builder(
                                              itemSize: 20,
                                              initialRating: usuario['rating']
                                                      ?.toDouble() ??
                                                  0.0,
                                              minRating: 0,
                                              direction: Axis.horizontal,
                                              allowHalfRating: false,
                                              itemCount: 5,
                                              itemPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2.0),
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Color.fromARGB(
                                                    255, 255, 196, 0),
                                              ),
                                              onRatingUpdate: (rating) {},
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Marcar o usuário como "aberto" ao clicar nele
                          if (isNewUser) {
                            // Atualizar o status para indicar que o usuário foi aberto
                            FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(usuarios[index].id)
                                .update({'status': true});
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UsuarioDetailScreen(usuario: usuario),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
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
          print("Fetching all users");
          querySnapshot =
              await FirebaseFirestore.instance.collection('usuarios').get();
        } else {
          print("Fetching users for category: $_selectedCategory");
          querySnapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .where('cat', isEqualTo: _selectedCategory)
              .get();
        }
      } else {
        if (_selectedCategory == "Todas as Categorias") {
          querySnapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .where('nomeCompleto', isGreaterThanOrEqualTo: searchTerm)
              .where('nomeCompleto', isLessThanOrEqualTo: searchTerm + '\uf8ff')
              .get();
        } else {
          querySnapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .where('cat', isEqualTo: _selectedCategory)
              .where('nomeCompleto', isGreaterThanOrEqualTo: searchTerm)
              .where('nomeCompleto', isLessThanOrEqualTo: searchTerm + '\uf8ff')
              .get();
        }
      }

      print("Number of results: ${querySnapshot.size}");

      _searchResultsController.add(querySnapshot.docs);
    } catch (e) {
      print('Erro: $e');
    }
  }

  Icon _getCategoryIcon(String category) {
    // Mapeia as categorias para os ícones correspondentes
    switch (category) {
      case 'Produto/Serviço':
        return const Icon(Icons.shopping_cart,
            color: Color.fromARGB(255, 94, 197, 212));
      case 'Arte':
        return const Icon(Icons.palette,
            color: Color.fromARGB(255, 94, 197, 212));
      case 'Música/banda':
        return const Icon(Icons.music_note,
            color: Color.fromARGB(255, 94, 197, 212));
      case 'Compras e Varejo':
        return const Icon(Icons.shop, color: Color.fromARGB(255, 94, 197, 212));
      case 'Saúde':
        return const Icon(Icons.favorite,
            color: Color.fromARGB(255, 94, 197, 212));
      case 'Mercearia':
        return const Icon(
          Icons.local_grocery_store,
          color: Color.fromARGB(255, 94, 197, 212),
        );
      case 'Gastronomia':
        return const Icon(Icons.restaurant,
            color: Color.fromARGB(255, 94, 197, 212));
      default:
        return const Icon(Icons.help, color: Color.fromARGB(255, 94, 197, 212));
    }
  }
}
