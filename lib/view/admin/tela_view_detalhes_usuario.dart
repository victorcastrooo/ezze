import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class UsuarioDetailScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const UsuarioDetailScreen({super.key, required this.usuario});

  @override
  _UsuarioDetailScreenState createState() => _UsuarioDetailScreenState();
}

class _UsuarioDetailScreenState extends State<UsuarioDetailScreen> {
  late bool _status;
  double _userRating = 0.0;
  bool _isEditing = true;

  // Controladores para campos editáveis
  TextEditingController _nomeCompletoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.usuario['status'];
    _userRating = (widget.usuario['rating'] ?? 0).toDouble();
    _nomeCompletoController.text = widget.usuario['nomeCompleto'];
    _emailController.text = widget.usuario['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Usuário'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _saveStatus();
                sendNotification(
                    title: "Teste", body: "Ok", token: widget.usuario['token']);
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campos editáveis
            TextFormField(
              controller: _nomeCompletoController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'Nome Completo'),
            ),
            TextFormField(
              controller: _emailController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            Row(
              children: [
                const Text('Status:'),
                Switch(
                  activeColor: Color.fromRGBO(113, 0, 150, 1),
                  inactiveThumbColor: Color.fromRGBO(113, 0, 150, 1),
                  value: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
              ],
            ),
            // Adiciona o widget RatingBar
            RatingBar.builder(
              initialRating: _userRating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _userRating = rating;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Enviar Notificação"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveStatus() async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.usuario['id'])
        .update({
      'status': _status,
      'rating': _userRating,
      'nomeCompleto': _nomeCompletoController.text,
      'email': _emailController.text,
    });

    // Atualiza o estado para redesenhar a tela
    setState(() {
      widget.usuario['status'] = _status;
      widget.usuario['nomeCompleto'] = _nomeCompletoController.text;
      widget.usuario['email'] = _emailController.text;
    });

    // Envia a notificação
    await sendNotification(
      title: "Status Atualizado",
      body:
          "Seu status foi alterado para ${_status ? 'ativo' : 'inativo'}. Sua avaliação é $_userRating estrelas.",
      token:
          "cEtKL9-gQiCepsN0Oh0qas:APA91bHX9jR8TcosbvSs4kN6U_DdDNSrsn740JA-m_pK4ZsNLDBYcCSyBLPtrH487EPqalq6d9Dn8l-xReTqlCkdQTZrkdLDj68sT5t5LKyjoP_Erzdsf9GAs9uS0hQLtxergvhWNVoJ",
    );
  }

  static Future<bool> sendNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendNotification');
    try {
      final response = await callable.call(<String, dynamic>{
        'title': title,
        'body': body,
        'token': token,
      });

      if (response.data == null) return false;
      return true;
    } catch (e) {
      return false;
    }
  }
}
