// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parceiroezze/view/influencer/tela_aguarde.dart';
import 'package:parceiroezze/view/tela_login.dart';
import 'package:parceiroezze/widget/textField.dart';

class Usuario {
  String nomeCompleto = '';
  String cpf = '';
  String whatsapp = '';
  String instagram = '';
  String endereco = '';
  String numero = '';
  String bairro = '';
  String cidade = '';
  String estado = '';
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({Key? key}) : super(key: key);

  @override
  _TelaCadastroState createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController enderecoController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController bairroController = TextEditingController();
  TextEditingController cidadeController = TextEditingController();
  String estadoSelecionado = 'Selecione um estado';
  List<String> estados = [
    'Selecione um estado',
    'Acre',
    'Alagoas',
    'Amapá',
    'Amazonas',
    'Bahia',
    'Ceará',
    'Distrito Federal',
    'Espírito Santo',
    'Goiás',
    'Maranhão',
    'Mato Grosso',
    'Mato Grosso do Sul',
    'Minas Gerais',
    'Pará',
    'Paraíba',
    'Paraná',
    'Pernambuco',
    'Piauí',
    'Rio de Janeiro',
    'Rio Grande do Norte',
    'Rio Grande do Sul',
    'Rondônia',
    'Roraima',
    'Santa Catarina',
    'São Paulo',
    'Sergipe',
    'Tocantins',
  ];

  Future<void> _registerWithEmailAndPassword() async {
    try {
      // Criar usuário no Firebase Authentication
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Obter o uid do usuário criado
      final uid = authResult.user?.uid;

      // Registro bem-sucedido, você pode acessar os dados do usuário aqui
      Usuario usuario = Usuario()
        ..nomeCompleto = nomeController.text
        ..cpf = cpfController.text
        ..whatsapp = whatsappController.text
        ..instagram = instagramController.text
        ..endereco = enderecoController.text
        ..numero = numeroController.text
        ..bairro = bairroController.text
        ..cidade = cidadeController.text
        ..estado = estadoSelecionado;

      // Salvar dados no Firestore associados ao uid do usuário
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'email': emailController.text,
        'nomeCompleto': usuario.nomeCompleto,
        'cpf': usuario.cpf,
        'whatsapp': usuario.whatsapp,
        'arrobaInsta': usuario.instagram,
        'endereco': usuario.endereco,
        'numero': usuario.numero,
        'bairro': usuario.bairro,
        'cidade': usuario.cidade,
        'estado': usuario.estado,
        'id': uid,
        'status': false,
      });

      // Navegar para a próxima tela (TelaPrincipal) após o cadastro bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Aguarde()),
      );
    } catch (e) {
      // Lidar com erros de registro
    }
  }

  bool termAccepted = false;

  void _showTermDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool termAccepted = false;

        return AlertDialog(
          title: const Text("Termos de Serviço"),
          content: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text("Leia e aceite os termos de serviço."),
              CheckboxListTile(
                title: const Text("Eu aceito os termos"),
                value: termAccepted,
                onChanged: (bool? value) {
                  setState(() {
                    termAccepted = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity
                    .leading, // Isso alinha o checkbox à esquerda do texto
                contentPadding: const EdgeInsets.all(
                    0), // Reduz o espaço interno do ListTile
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (termAccepted) {
                  Navigator.of(context).pop();
                  _performRegistration();
                } else {
                  // Exiba uma mensagem indicando que os termos devem ser aceitos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Você deve aceitar os termos de serviço."),
                    ),
                  );
                }
              },
              child: const Text("Aceitar"),
            ),
          ],
        );
      },
    );
  }

  void _performRegistration() {
    _registerWithEmailAndPassword();
  }

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
              FormText(label: "CPF", controller: cpfController),
              const SizedBox(height: 15),
              FormText(label: "WhatsApp", controller: whatsappController),
              const SizedBox(height: 15),
              FormText(label: "Instagram", controller: instagramController),
              const SizedBox(height: 15),
              FormText(label: "Endereço", controller: enderecoController),
              const SizedBox(height: 15),
              FormText(label: "Número", controller: numeroController),
              const SizedBox(height: 15),
              FormText(label: "Bairro", controller: bairroController),
              const SizedBox(height: 15),
              FormText(label: "Cidade", controller: cidadeController),
              const SizedBox(height: 15),
              DropdownButton<String>(
                value: estadoSelecionado,
                onChanged: (String? newValue) {
                  setState(() {
                    estadoSelecionado = newValue!;
                  });
                },
                items: estados.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 94, 197, 212)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _showTermDialog();
                },
                child: const Text("Cadastrar"),
              ),
              const SizedBox(height: 7),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaLogin()),
                  );
                },
                child: const Text(
                  'Já é Parceiro? Faça login!',
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
