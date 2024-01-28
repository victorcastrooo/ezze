// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parceiroezze/view/tela_carregando.dart';
import 'package:parceiroezze/view/tela_editarperfil.dart';
import 'package:parceiroezze/view/tela_login.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user!.uid)
              .get();

      setState(() {
        userData = userDataSnapshot.data();
        isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
    );
  }

  void _navigateToEditarPerfil(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaEditarPerfil()),
    );

    // Recarrega os dados do usuário ao retornar da tela de edição
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, ${userData?['nomeCompleto']}"),
        actions: [
          IconButton(
            onPressed: () async {
              await _logout(context);
            },
            icon: const Icon(Icons.exit_to_app),
          ),
          IconButton(
            onPressed: () {
              _navigateToEditarPerfil(context);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const TelaCarregando()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (userData != null)
                    Text(
                        "Bem-vindo à Tela Principal,  ${userData?['nomeCompleto']}"),
                  if (userData != null) ...[
                    const SizedBox(height: 20),
                    Text("Nome Completo: ${userData?['nomeCompleto']}"),
                    Text("CPF: ${userData?['cpf']}"),
                    Text("WhatsApp: ${userData?['whatsapp']}"),
                    Text("Instagram: ${userData?['instagram']}"),
                    Text("Endereço: ${userData?['endereco']}"),
                    Text("Número: ${userData?['numero']}"),
                    Text("Bairro: ${userData?['bairro']}"),
                    Text("Cidade: ${userData?['cidade']}"),
                    Text("Estado: ${userData?['estado']}"),
                  ],
                ],
              ),
      ),
    );
  }
}
