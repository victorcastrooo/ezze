import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NegadaSolicitacao extends StatefulWidget {
  const NegadaSolicitacao({Key? key}) : super(key: key);

  @override
  State<NegadaSolicitacao> createState() => _NegadaSSolicitacaoState();
}

class _NegadaSSolicitacaoState extends State<NegadaSolicitacao> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = ''; // Defina o valor inicial conforme necessário
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitações Rejeitadas'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parceria')
            .where('statusParceria', isEqualTo: "Rejeitado")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var solicitacoes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: solicitacoes.length,
            itemBuilder: (context, index) {
              var solicitacao =
                  solicitacoes[index].data() as Map<String, dynamic>;
              var idEstabelecimento = solicitacao['idEstabelecimento'];
              var idParceiro = solicitacao['idParceiro'];
              var statusParceria = solicitacao['statusParceria'];

              return FutureBuilder(
                future: _getDadosAsync(idEstabelecimento, idParceiro),
                builder: (context,
                    AsyncSnapshot<Map<String, String>> asyncSnapshot) {
                  if (!asyncSnapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  var dados = asyncSnapshot.data!;
                  var nomeEstabelecimento = dados['nomeEstabelecimento'];
                  var nomeUsuario = dados['nomeUsuario'];

                  return Card(
                    margin: EdgeInsets.all(10),
                    color: Colors.white,
                    shadowColor: Colors.white,
                    elevation: 0,
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estabelecimento',
                            style: TextStyle(
                                color: const Color.fromARGB(115, 44, 44, 44),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '$nomeEstabelecimento',
                            style: TextStyle(
                                color: Color.fromRGBO(113, 0, 150, 0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Parceiro',
                            style: TextStyle(
                                color: const Color.fromARGB(115, 44, 44, 44),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '$nomeUsuario',
                            style: TextStyle(
                                color: Color.fromRGBO(113, 0, 150, 0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      trailing: DropdownButton<String>(
                        value: _selectedStatus.isNotEmpty
                            ? _selectedStatus
                            : statusParceria,
                        items:
                            ['Pendente', 'Aprovado', 'Rejeitado'].map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          await _updateStatusParceria(idParceiro, value!);
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, String>> _getDadosAsync(
      String idEstabelecimento, String idParceiro) async {
    var estabelecimentoDoc = await FirebaseFirestore.instance
        .collection('estabelecimentos')
        .doc(idEstabelecimento)
        .get();

    var usuarioDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idParceiro)
        .get();

    var nomeEstabelecimento = estabelecimentoDoc['nomeFantasia'];
    var nomeUsuario = usuarioDoc['nomeCompleto'];

    return {
      'nomeEstabelecimento': nomeEstabelecimento,
      'nomeUsuario': nomeUsuario
    };
  }

  Future<void> _updateStatusParceria(
      String idParceiro, String novoStatus) async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('parceria').get();

      if (querySnapshot.docs.isNotEmpty) {
        var idDocumento = querySnapshot.docs[0].id;

        // Atualizar o statusParceria no documento encontrado
        await FirebaseFirestore.instance
            .collection('parceria')
            .doc(idDocumento)
            .update({'statusParceria': novoStatus});

        print('Status atualizado para: $novoStatus');

        // Se o status for "negado", agendar a exclusão após 1 minuto
        if (novoStatus == 'Rejeitado') {
          Timer(Duration(minutes: 43800), () {
            _deleteParceria(idDocumento);
          });
        }
      } else {
        print('Documento não encontrado para o ID do Parceiro: $idParceiro');
      }
    } catch (error) {
      print('Erro ao atualizar o status: $error');
    }
  }

  Future<void> _deleteParceria(String idDocumento) async {
    try {
      await FirebaseFirestore.instance
          .collection('parceria')
          .doc(idDocumento)
          .delete();

      print('Documento excluído após 1 minuto.');
    } catch (error) {
      print('Erro ao excluir o documento: $error');
    }
  }
}
