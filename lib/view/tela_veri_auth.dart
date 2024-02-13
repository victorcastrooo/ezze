// ignore_for_file: use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parceiroezze/view/admin/tela_inicial_admin.dart';
import 'package:parceiroezze/view/influencer/tela_inicial_influencer.dart';
import 'package:parceiroezze/view/tela_login.dart';

class VerificarAutenticacao extends StatelessWidget {
  const VerificarAutenticacao({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro de autenticação: ${snapshot.error}'),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc((snapshot.data as User).uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (userSnapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                          'Erro ao verificar o documento do usuário: ${userSnapshot.error}'),
                    ),
                  );
                } else {
                  if (userSnapshot.hasData && userSnapshot.data != null) {
                    // Usuário está na coleção 'usuarios'
                    return ListaEstabelecimentosInfluencer();
                  } else {
                    return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection(
                              'adminstradores') // Corrigido o nome da coleção
                          .doc((snapshot.data as User).uid)
                          .get(),
                      builder: (context, adminSnapshot) {
                        if (adminSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (adminSnapshot.hasError) {
                          return Scaffold(
                            body: Center(
                              child: Text(
                                  'Erro ao verificar o documento do administrador: ${adminSnapshot.error}'),
                            ),
                          );
                        } else {
                          if (adminSnapshot.hasData &&
                              adminSnapshot.data != null) {
                            // Usuário é um administrador
                            return const TelaInicialAdmin();
                          } else {
                            // Usuário não encontrado nas coleções
                            return const TelaLogin();
                          }
                        }
                      },
                    );
                  }
                }
              },
            );
          }
          return const TelaLogin();
        }
      },
    );
  }
}
