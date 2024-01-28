// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parceiroezze/view/tela_login.dart';
import 'package:social_media_flutter/social_media_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://flutter.dev');

class EstabelecimentoCard2 extends StatelessWidget {
  final Map<String, dynamic> data;

  const EstabelecimentoCard2(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibe a imagem
            if (data['imageUrl'] != null)
              Image.network(
                data['imageUrl'],
                width: MediaQuery.of(context).size.height,
                height: 150,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),

            const SizedBox(height: 10),

            // Exibe os outros dados
            GestureDetector(
              onTap: () {
                launchUrl(_url);
              },
              child: SocialWidget(
                placeholderText: '${data['arrobaInsta']}',
                iconData: SocialIconsFlutter.instagram,
                iconColor: const Color.fromRGBO(113, 0, 150, 0.8),
                link: 'https://www.instagram.com/${data['arrobaInsta']}/',
                iconSize: 20,
                placeholderStyle: const TextStyle(
                    color: Color.fromRGBO(113, 0, 150, 0.8), fontSize: 18),
              ),
            ),
            Text(
              '${data['nomeFantasia']}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromRGBO(113, 0, 150, 0.8)),
            ),

            // Adicione outros campos conforme necessário
          ],
        ),
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const TelaLogin()),
  );
}

class TelaInicialInfluencer extends StatefulWidget {
  @override
  State<TelaInicialInfluencer> createState() => _TelaInicialInfluencerState();
}

class _TelaInicialInfluencerState extends State<TelaInicialInfluencer> {
  String nome = '';
  @override
  void initState() {
    super.initState();
    _carregarNomeDoAdmin(); // Chama a função para carregar o nome do administrador ao iniciar a tela
  }

  Future<void> _carregarNomeDoAdmin() async {
    // Use FirebaseAuth para obter o usuário atual
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Use FirebaseFirestore para obter os dados do usuário a partir do Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      // Atualize o estado com o nome do administrador
      setState(() {
        nome = snapshot[
            'nomeCompleto']; // Supondo que o campo no Firestore é 'nome'
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
            "Seja Bem Vindo Parceiro",
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
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            color: const Color.fromRGBO(113, 0, 150, 1),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Olá, $nome", style: const TextStyle(color: Colors.white))
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('estabelecimentos')
                  .snapshots(),
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

                final estabelecimentos = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: estabelecimentos.length,
                  itemBuilder: (context, index) {
                    final estabelecimentoData =
                        estabelecimentos[index].data() as Map<String, dynamic>;
                    return EstabelecimentoCard2(estabelecimentoData);
                  },
                );
              },
            ),
          )
        ]));
  }
}
