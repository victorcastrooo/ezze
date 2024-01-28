// ignore_for_file: prefer_final_fields, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parceiroezze/view/tela_login.dart';

class TelaEditarPerfil extends StatefulWidget {
  const TelaEditarPerfil({Key? key}) : super(key: key);

  @override
  _TelaEditarPerfilState createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _whatsappController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();
  TextEditingController _enderecoController = TextEditingController();
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _bairroController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();
  TextEditingController _estadoController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user!.uid)
              .get();

      setState(() {
        userData = userDataSnapshot.data();
        _nomeController.text = userData?['nomeCompleto'] ?? '';
        _cpfController.text = userData?['cpf'] ?? '';
        _whatsappController.text = userData?['whatsapp'] ?? '';
        _instagramController.text = userData?['instagram'] ?? '';
        _enderecoController.text = userData?['endereco'] ?? '';
        _numeroController.text = userData?['numero'] ?? '';
        _bairroController.text = userData?['bairro'] ?? '';
        _cidadeController.text = userData?['cidade'] ?? '';
        _estadoController.text = userData?['estado'] ?? '';
      });
    }
  }

  Future<void> _updateUserData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .update({
          'nomeCompleto': _nomeController.text,
          'cpf': _cpfController.text,
          'whatsapp': _whatsappController.text,
          'instagram': _instagramController.text,
          'endereco': _enderecoController.text,
          'numero': _numeroController.text,
          'bairro': _bairroController.text,
          'cidade': _cidadeController.text,
          'estado': _estadoController.text,
        });

        // Aguarde a atualização do perfil antes de recarregar os dados
        await user?.reload();

        // Recarregue os dados do usuário após a atualização
        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TelaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil"),
        actions: [
          IconButton(
            onPressed: () async {
              await _logout(context);
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (userData != null) ...[
                const SizedBox(height: 20),
                Text(
                    "Bem-vindo à Tela de Edição, ${userData?['nomeCompleto']}"),
              ],
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome Completo'),
                validator: (value) {
                  // Implemente validação do CPF conforme necessário
                  return null;
                },
              ),
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(labelText: 'CPF'),
                validator: (value) {
                  // Implemente validação do CPF conforme necessário
                  return null;
                },
              ),
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(labelText: 'Nome Completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _estadoController.text.isNotEmpty &&
                        estados.contains(_estadoController.text)
                    ? _estadoController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _estadoController.text = newValue!;
                  });
                },
                items: estados.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              // Adicione outros campos conforme necessário

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _updateUserData(context);
                },
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
