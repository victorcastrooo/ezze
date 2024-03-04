import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerContrato extends StatefulWidget {
  final Map<String, dynamic> estabelecimento;
  VerContrato({Key? key, required this.estabelecimento}) : super(key: key);

  @override
  State<VerContrato> createState() => _VerContratoState();
}

class _VerContratoState extends State<VerContrato> {
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _getContrato() async {
    // Realize uma consulta no Firestore para obter o contrato correspondente ao idEsta
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('contratos')
        .where('idEsta', isEqualTo: widget.estabelecimento['uid'])
        .limit(1)
        .get();

    // Retorna o primeiro documento encontrado (ou null se nenhum documento for encontrado)
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Contrato'),
      ),
      body: FutureBuilder(
        future: _getContrato(),
        builder: (context,
            AsyncSnapshot<QueryDocumentSnapshot<Map<String, dynamic>>?>
                snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return Center(child: Text('Contrato não encontrado'));
          }

          // Dados do contrato
          var contratoData = snapshot.data!.data();
          var dateFormat = DateFormat('dd/MM/yyyy');

          // Obtém a data de vencimento do contrato
          DateTime vencimentoContrato =
              contratoData['vencimentoContrato'].toDate();

// Obtém a data atual
          DateTime currentDate = DateTime.now();

// Calcula a diferença em dias
          int diasRestantes = vencimentoContrato.difference(currentDate).inDays;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Serviços: ${contratoData['servicos']}'),
              Text('Vencimento Mensal: ${contratoData['vencimentoMensal']}'),
              Text(
                  'Vencimento Contrato: ${dateFormat.format(contratoData['vencimentoContrato'].toDate())}'),
              Text('Dias Restantes: $diasRestantes'),
              Text(
                  'Datas Mensais: ${contratoData['datasMensais'].map((date) => dateFormat.format(DateTime.parse(date))).join(', ')}'),

              // Adicione mais widgets conforme necessário para exibir outros detalhes
            ],
          );
        },
      ),
    );
  }
}
