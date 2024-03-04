import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerDisponibilidadeInfluencer extends StatefulWidget {
  VerDisponibilidadeInfluencer({Key? key, required this.estabelecimento})
      : super(key: key);

  final Map<String, dynamic> estabelecimento;

  @override
  State<VerDisponibilidadeInfluencer> createState() =>
      _VerDisponibilidadeEstaState();
}

class _VerDisponibilidadeEstaState extends State<VerDisponibilidadeInfluencer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> aceitarDisponibilidade(String documentId) async {
    try {
      // Obtém o usuário logado
      User? user = _auth.currentUser;

      // Obtém os dados novamente para acessar a disponibilidade específica
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('disponibilidades')
          .doc(documentId)
          .get();

      Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;

      // Move a disponibilidade para a coleção 'visitas' e adiciona o campo 'idParceiro'
      await FirebaseFirestore.instance.collection('visitas').add({
        'data': dados['data'],
        'quantidade': dados['quantidade'],
        'idParceiro': user?.uid,
      });

      // Exclui a disponibilidade da coleção atual
      await FirebaseFirestore.instance
          .collection('disponibilidades')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Erro ao aceitar disponibilidade: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disponibilidades'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('disponibilidades')
            .where('empresaId', isEqualTo: '${widget.estabelecimento['uid']}')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<Map<String, dynamic>> dados = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            itemCount: dados.length,
            itemBuilder: (context, index) {
              dynamic rawData = dados[index]['data'];
              DateTime data;

              if (rawData is Timestamp) {
                data = rawData.toDate();
              } else {
                data = DateTime.parse(rawData);
              }

              String dataFormatada = DateFormat('dd/MM/yyyy').format(data);

              return ListTile(
                title: Text('Data: $dataFormatada'),
                subtitle: Text('Quantidade: ${dados[index]['quantidade']}'),
                trailing: ElevatedButton(
                  onPressed: () =>
                      aceitarDisponibilidade(snapshot.data!.docs[index].id),
                  child: Text('Aceitar'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
