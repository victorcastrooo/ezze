// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parceiroezze/view/admin/tela_inicial_admin.dart';
import 'package:parceiroezze/view/influencer/tela_aguarde.dart';
import 'package:parceiroezze/view/influencer/tela_cadastro.dart';
import 'package:parceiroezze/view/influencer/tela_inicial_influencer.dart';
import 'package:parceiroezze/widget/textField.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key}) : super(key: key);

  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late Future<void> _loginFuture;

  @override
  void initState() {
    super.initState();
    _loginFuture =
        Future.value(); // Initial value, can be changed based on your logic
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    setState(() {
      _loginFuture = _auth
          .signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((userCredential) async {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .get();

        if (userSnapshot.exists) {
          bool status =
              (userSnapshot.data() as Map<String, dynamic>?)?['status'] ??
                  false;

          if (status) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TelaInicialInfluencer(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Aguarde(),
              ),
            );
          }
        } else {
          DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
              .collection('adminstradores')
              .doc(userCredential.user!.uid)
              .get();

          if (adminSnapshot.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TelaInicialAdmin(),
              ),
            );
          } else {
            _showErrorDialog(context, 'Usuário não autorizado');
          }
        }
      }).catchError((e) {
        showFirebaseAuthErrorSnackbar(context, e);
      });
    });
  }

  void showFirebaseAuthErrorSnackbar(
      BuildContext context, FirebaseAuthException e) {
    String errorMessage = '';

    switch (e.code) {
      // ... (your existing error cases)
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(113, 0, 150, 1),
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/bg.jpg', // Replace with your image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          FutureBuilder<void>(
            future: _loginFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading screen while login is in progress
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                // Your existing content when login is complete
                return Container(
                  padding: const EdgeInsets.all(25),
                  color: const Color.fromRGBO(113, 0, 150, 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      const Image(
                        image: AssetImage('assets/images/logo_full_branca.png'),
                        height: 55,
                      ),
                      const SizedBox(height: 100),
                      FormText(label: "E-mail", controller: _emailController),
                      const SizedBox(height: 15),
                      FormText(
                          label: "Password", controller: _passwordController),
                      TextButton(
                        onPressed: () {
                          _signInWithEmailAndPassword(context);
                        },
                        child: const Text(
                          'Esqueceu a Senha?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      ElevatedButton(
                        onPressed: () {
                          _signInWithEmailAndPassword(context);
                        },
                        child: const Text("Login", style: TextStyle(color: const Color.fromRGBO(113, 0, 150, 1)),),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TelaCadastro(),
                            ),
                          );
                        },
                        child: const Text(
                          'Não é Parceiro? Cadastre-se Agora!',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
