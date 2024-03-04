// ignore_for_file: unused_import, unused_element

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parceiroezze/view/admin/tela_cadastrar_disponibilidade.dart';
import 'package:parceiroezze/view/admin/tela_cadastrar_fatura.dart';
import 'package:parceiroezze/view/admin/tela_novo_estabelecimento.dart';
import 'package:parceiroezze/view/admin/tela_lista_esta.dart';
import 'package:parceiroezze/view/admin/tela_ver_disponibilidades_esta.dart';
import 'package:parceiroezze/view/admin/tela_vercontrato.dart';
import 'package:parceiroezze/view/tela_login.dart';

class TelaEstaCompl extends StatefulWidget {
  TelaEstaCompl({Key? key, required this.estabelecimento}) : super(key: key);

  final Map<String, dynamic> estabelecimento;

  @override
  State<TelaEstaCompl> createState() => _TelaEstaComplState();
}

class _TelaEstaComplState extends State<TelaEstaCompl> {
  String nomeDoAdmin = ''; // Variável para armazenar o nome do administrador

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "${widget.estabelecimento['nomeFantasia']}",
        ), // Atualiza dinamicamente o nome do administrador
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Card(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  elevation: 1,
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Image.network(
                        "${widget.estabelecimento['imageUrlLogo']}",
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
                            "${widget.estabelecimento['nomeFantasia']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color.fromRGBO(113, 0, 150, 0.8)),
                          ),
                          Text(
                            "@${widget.estabelecimento['arrobaInsta']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w100,
                                color: Colors.black38),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: StreamBuilder(
                    // Use a referência do Firestore para escutar as atualizações em tempo real
                    stream: FirebaseFirestore.instance
                        .collection('contratos')
                        .where('idEsta',
                            isEqualTo: '${widget.estabelecimento['uid']}')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Verifique se há erro ou se a consulta retornou documentos
                      if (snapshot.hasError) {
                        return Text("Erro ao carregar dados");
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // ou outro indicador de carregamento
                      }

                      // Verifique se há algum documento correspondente
                      if (snapshot.data!.docs.isNotEmpty) {
                        // Se existir, altere o texto e a rota do Card
                        return ListTile(
                          leading: const Icon(
                            Icons.post_add_outlined,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          title: const Text(
                            'Ver Contrato',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerContrato(
                                  estabelecimento: widget.estabelecimento,
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // Se não existir, mantenha o Card original
                        return ListTile(
                          leading: const Icon(
                            Icons.post_add_outlined,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          title: const Text(
                            'Cadastrar Fatura',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CadastrarFatura(
                                  estabelecimento: widget.estabelecimento,
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.more_time,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text(
                      'Cadastrar Disponibilidade',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CadastrarDisponibilidade(
                              estabelecimento: widget.estabelecimento),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 94, 197, 212),
                  child: ListTile(
                    leading: const Icon(
                      Icons.access_time_rounded,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: const Text(
                      'Ver Disponibilidade',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerDisponibilidadeEsta(
                              estabelecimento: widget.estabelecimento),
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
