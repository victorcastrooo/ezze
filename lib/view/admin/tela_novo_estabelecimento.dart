// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parceiroezze/widget/textField.dart';

class Estabelecimento {
  String razaosocial = '';
  String nomefantasia = '';
  String cnpj = '';
  String telefoneresponsavel = '';
  String email = '';
  String password = '';
  String cep = '';
  String rua = '';
  String numero = '';
  String cidade = '';
  String endereco = '';
  String estado = '';
  String categoria = '';
  String arrobaInsta = '';
}

class NovoEstabelecimento extends StatefulWidget {
  const NovoEstabelecimento({Key? key}) : super(key: key);

  @override
  State<NovoEstabelecimento> createState() => _NovoEstabelecimentoState();
}

class _NovoEstabelecimentoState extends State<NovoEstabelecimento> {
  final ImagePicker _imagePicker = ImagePicker();
  final ImagePicker _imagePickerLogo = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _selectedImage;
  File? _selectedImageLogo;

  TextEditingController razaosocialController = TextEditingController();
  TextEditingController nomefantasiaController = TextEditingController();
  TextEditingController cnpjController = TextEditingController();
  TextEditingController telefoneresponsavelController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cepController = TextEditingController();
  TextEditingController ruaController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController cidadeController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  TextEditingController enderecoController = TextEditingController();
  TextEditingController arrobaInstaController = TextEditingController();
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
  TextEditingController catController = TextEditingController();
  String catSelecionado = 'Selecione uma Categoria';
  List<String> cat = [
    'Selecione uma Categoria',
    'Produto/Serviço',
    'Arte',
    'Música/banda',
    'Compras e Varejo',
    'Saúde/Beleza',
    'Mercearia',
    'Gastronomia',
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageLogo() async {
    final pickedFile =
        await _imagePickerLogo.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageLogo = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    try {
      if (_selectedImage == null) {
        return null;
      }

      final String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}.png';
      final Reference storageReference = _storage.ref().child(fileName);

      final UploadTask uploadTask = storageReference.putFile(_selectedImage!);
      await uploadTask.whenComplete(() => null);

      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<String?> _uploadImageLogo() async {
    try {
      if (_selectedImageLogo == null) {
        return null;
      }

      final String fileNameLogo =
          'logo/${DateTime.now().millisecondsSinceEpoch}.png';
      final Reference storageReference = _storage.ref().child(fileNameLogo);

      final UploadTask uploadTask =
          storageReference.putFile(_selectedImageLogo!);
      await uploadTask.whenComplete(() => null);

      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> _registerWithEmailAndPassword() async {
    try {
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final uid = authResult.user?.uid;

      final imageUrl = await _uploadImage();
      final imageUrlLogo = await _uploadImageLogo();

      final Estabelecimento estabelecimento = Estabelecimento()
        ..cep = cepController.text
        ..cidade = cidadeController.text
        ..cnpj = cnpjController.text
        ..email = emailController.text
        ..estado = estadoSelecionado
        ..nomefantasia = nomefantasiaController.text
        ..numero = numeroController.text
        ..password = passwordController.text
        ..razaosocial = razaosocialController.text
        ..rua = ruaController.text
        ..telefoneresponsavel = telefoneresponsavelController.text
        ..arrobaInsta = arrobaInstaController.text
        ..endereco = enderecoController.text
        ..categoria = catSelecionado;

      await _firestore.collection('estabelecimentos').doc(uid).set({
        'email': estabelecimento.email,
        'cnpj': estabelecimento.cnpj,
        'razaoSocial': estabelecimento.razaosocial,
        'nomeFantasia': estabelecimento.nomefantasia,
        'imageUrl': imageUrl,
        'imageUrlLogo': imageUrlLogo,
        'telefoneresponsavel': estabelecimento.telefoneresponsavel,
        'cidade': estabelecimento.cidade,
        'estado': estabelecimento.estado,
        'cat': estabelecimento.categoria,
        'arrobaInsta': estabelecimento.arrobaInsta,
        'numero': estabelecimento.numero,
        'cep': estabelecimento.cep,
        'endereco': estabelecimento.endereco
      });
    } catch (e) {
      print('Erro ao registrar: $e');
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
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.all(0),
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(113, 0, 150, 1),
        title: const Text(
          'Novo Estabelecimento',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: const Color.fromRGBO(113, 0, 150, 1),
      body: Container(
        padding: const EdgeInsets.all(25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormText(label: "E-mail", controller: emailController),
              const SizedBox(height: 15),
              FormText(label: "Senha", controller: passwordController),
              const SizedBox(height: 15),
              FormText(label: "Cnpj", controller: cnpjController),
              const SizedBox(height: 15),
              FormText(
                  label: "Razão Social", controller: razaosocialController),
              const SizedBox(height: 15),
              FormText(
                  label: "Nome Fantasia", controller: nomefantasiaController),
              const SizedBox(height: 15),
              FormText(
                  label: "Arroba Instagram", controller: arrobaInstaController),
              const SizedBox(height: 15),
              FormText(
                  label: "Telefone do Responsável",
                  controller: telefoneresponsavelController),
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
              FormText(label: "Cidade", controller: cidadeController),
              const SizedBox(height: 15),
              FormText(label: "Endereço", controller: enderecoController),
              const SizedBox(height: 15),
              FormText(label: "Número", controller: numeroController),
              const SizedBox(height: 15),
              DropdownButton<String>(
                value: catSelecionado,
                onChanged: (String? newValue) {
                  setState(() {
                    catSelecionado = newValue!;
                  });
                },
                items: cat.map<DropdownMenuItem<String>>((String value) {
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
                  _pickImage();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo),
                    Text("Escolher Foto"),
                  ],
                ),
              ),

              // Exibir a imagem selecionada
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: MediaQuery.of(context).size.height,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: () {
                  _pickImageLogo();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo),
                    Text("Escolher Logo"),
                  ],
                ),
              ),

              // Exibir a imagem selecionada
              _selectedImageLogo != null
                  ? Image.file(
                      _selectedImageLogo!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _showTermDialog();
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
