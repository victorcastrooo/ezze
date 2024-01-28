// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parceiroezze/view/admin/tela_inicial_admin.dart';
import 'package:parceiroezze/widget/textField.dart';

class Admin {
  String nomeCompleto = '';
}

class TelaCadastroAdmin extends StatefulWidget {
  const TelaCadastroAdmin({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TelaCadastroState createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastroAdmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nomeController = TextEditingController();

  Future<void> _registerWithEmailAndPassword() async {
    try {
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final uid = authResult.user?.uid;

      Admin admin = Admin()..nomeCompleto = nomeController.text;

      await FirebaseFirestore.instance
          .collection('adminstradores')
          .doc(uid)
          .set({
        'email': emailController.text,
        'nomeCompleto': admin.nomeCompleto,
        'id': uid,
      });

      // Navegar para a próxima tela (TelaPrincipal) após o cadastro bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaInicialAdmin()),
      );
    } catch (e) {
      // Lidar com erros de registro
      print('Erro de registro: $e');
    }
  }

  bool termAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(113, 0, 150, 1),
      body: Container(
        padding: const EdgeInsets.all(25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Seja Parceiro",
                style: TextStyle(
                    color: Color.fromARGB(255, 94, 197, 212),
                    fontSize: 20,
                    fontWeight: FontWeight.w100),
              ),
              const SizedBox(
                height: 15,
              ),
              const Image(
                image: AssetImage(
                  'assets/images/logo_full_branca.png',
                ),
                height: 55,
              ),
              const SizedBox(height: 30),
              FormText(label: "E-mail", controller: emailController),
              const SizedBox(height: 15),
              FormText(label: "Password", controller: passwordController),
              const SizedBox(height: 15),
              FormText(label: "Nome Completo", controller: nomeController),
              const SizedBox(height: 15),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _registerWithEmailAndPassword();
                },
                child: const Text("Cadastrar"),
              ),
              const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}
