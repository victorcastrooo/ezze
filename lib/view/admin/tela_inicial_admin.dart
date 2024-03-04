import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parceiroezze/view/admin/tela_solicitacao_nova.dart';
import 'package:parceiroezze/view/admin/tela_novo_estabelecimento.dart';
import 'package:parceiroezze/view/admin/tela_lista_usuarios.dart';
import 'package:parceiroezze/view/admin/tela_lista_esta.dart';
import 'package:parceiroezze/view/admin/tela_solicitacao_aprovada.dart';
import 'package:parceiroezze/view/admin/tela_solicitacao_negada.dart';
import 'package:parceiroezze/view/tela_login.dart';

class TelaInicialAdmin extends StatefulWidget {
  const TelaInicialAdmin({Key? key}) : super(key: key);

  @override
  State<TelaInicialAdmin> createState() => _TelaInicialAdminState();
}

class _TelaInicialAdminState extends State<TelaInicialAdmin> {
  String nomeDoAdmin = ''; // Variável para armazenar o nome do administrador

  @override
  void initState() {
    super.initState();
    _carregarNomeDoAdmin(); // Chama a função para carregar o nome do administrador ao iniciar a tela
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
    );
  }

  Future<void> _carregarNomeDoAdmin() async {
    // Use FirebaseAuth para obter o usuário atual
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Use FirebaseFirestore para obter os dados do usuário a partir do Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('adminstradores')
          .doc(user.uid)
          .get();

      // Atualize o estado com o nome do administrador
      setState(() {
        nomeDoAdmin =
            snapshot['nome']; // Supondo que o campo no Firestore é 'nome'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(113, 0, 150, 1),
        elevation: 0,
        title: const Text(
          "Administração",
          style: TextStyle(color: Colors.white),
        ), // Atualiza dinamicamente o nome do administrador
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await _logout(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color.fromRGBO(113, 0, 150, 1),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Olá, $nomeDoAdmin",
                    style: const TextStyle(color: Colors.white))
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const Text(
                  'Parceiros',
                  style: TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
                ),
                const Divider(),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_search,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text('Parceiros',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListaUsuarios(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_add,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text('Novas Solitações',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NovaSolicitacao(),
                          ));
                    },
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_add,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text('Solitações Aprovadas',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AprovadoSolicitacao(),
                          ));
                    },
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_add,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text('Solitações Negadas',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NegadaSolicitacao(),
                          ));
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Estabelecimento',
                  style: TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
                ),
                const Divider(),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.store,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text(
                      'Estabelecimentos',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListaEstabelecimentos()),
                      );
                    },
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.add_business,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text('Novo Estabelecimento',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NovoEstabelecimento(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
