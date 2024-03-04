import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerDisponibilidadeEsta extends StatefulWidget {
  VerDisponibilidadeEsta({super.key, required this.estabelecimento});

  final Map<String, dynamic> estabelecimento;

  @override
  State<VerDisponibilidadeEsta> createState() => _VerDisponibilidadeEstaState();
}

class _VerDisponibilidadeEstaState extends State<VerDisponibilidadeEsta> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disponibilidades'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(
                'disponibilidades') // Substitua 'suaColecao' pelo nome da sua coleção no Firestore
            .where('empresaId', isEqualTo: '${widget.estabelecimento['uid']}')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<Map<String, dynamic>> dados = snapshot.data!.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          return ListView.builder(
            itemCount: dados.length,
            itemBuilder: (context, index) {
              // Verifica se a data é do tipo Timestamp e a converte para DateTime
              dynamic rawData = dados[index]['data'];
              DateTime data;

              if (rawData is Timestamp) {
                data = rawData.toDate();
              } else {
                data = DateTime.parse(rawData);
              }

              // Formata a data no formato dd/MM/yyyy
              String dataFormatada = DateFormat('dd/MM/yyyy').format(data);
              return ListTile(
                title: Text('Data: $dataFormatada'),
                subtitle: Text('Quantidade: ${dados[index]['quantidade']}'),
              );
            },
          );
        },
      ),
    );
  }
}
