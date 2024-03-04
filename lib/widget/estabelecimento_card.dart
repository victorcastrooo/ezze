import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parceiroezze/view/admin/tela_lista_esta.dart';
import 'package:parceiroezze/view/influencer/tela_ver_disponibilidades_influencer.dart';
import 'package:parceiroezze/view/tela_carregando.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EstabelecimentoCardInflu extends StatefulWidget {
  final Map<String, dynamic> data;

  EstabelecimentoCardInflu(this.data, {Key? key}) : super(key: key);

  @override
  State<EstabelecimentoCardInflu> createState() =>
      _EstabelecimentoCardInfluState();
}

class _EstabelecimentoCardInfluState extends State<EstabelecimentoCardInflu> {
  late String textButton;

  @override
  void initState() {
    super.initState();

    _updateTextButton();
  }

  void _updateTextButton() {
    // Listen for changes in the parceria status
    _verificarParceriaStream().listen((parceriaExistente) {
      if (parceriaExistente) {
        // Verifica o status da parceria
        _verificarStatusParceria(widget.data).then((status) {
          if (status == 'Pendente') {
            setState(() {
              textButton = "Pendente";
            });
          } else if (status == 'Rejeitado') {
            setState(() {
              textButton = "Rejeitado";
            });
          } else if (status == 'Aprovado') {
            setState(() {
              textButton = "Disponibilidades";
            });
          }
        });
      } else {
        setState(() {
          textButton = "Solicitar Parceria";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Uri _url =
        Uri.parse('https://www.instagram.com/${widget.data['arrobaInsta']}/');
    Uri _enderecoUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.data['endereco']}+${widget.data['numero']}+${widget.data['cidade']}+${widget.data['cep']}');
    Uri _whatsUrl =
        Uri.parse('https://wa.me/+${widget.data['telefoneresponsavel']}');

    return StreamBuilder<bool>(
      stream: _verificarParceriaStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TelaCarregando();
        } else {
          bool parceriaExistente = snapshot.data ?? false;

          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.data['imageUrl'] != null)
                    Image.network(
                      widget.data['imageUrl'],
                      width: MediaQuery.of(context).size.height,
                      height: 150,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.network(
                              widget.data['imageUrlLogo'],
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
                                  '${widget.data['nomeFantasia']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Color.fromRGBO(113, 0, 150, 0.8)),
                                ),
                                Text(
                                  '@${widget.data['arrobaInsta']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black38),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                launchUrl(_url);
                              },
                              color: const Color.fromARGB(255, 94, 197, 212),
                              icon: const Icon(FontAwesomeIcons.instagram),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                launchUrl(_enderecoUrl);
                              },
                              color: const Color.fromARGB(255, 94, 197, 212),
                              icon: const Icon(Icons.location_on_outlined),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                launchUrl(_whatsUrl);
                              },
                              color: const Color.fromARGB(255, 94, 197, 212),
                              icon: const Icon(FontAwesomeIcons.whatsapp),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                              ),
                              onPressed: () {
                                if (parceriaExistente) {
                                  // Verifica o status da parceria
                                  _verificarStatusParceria(widget.data)
                                      .then((status) {
                                    if (status == 'Pendente') {
                                      // Se o status for Aguardando, exibe o texto "Em análise"

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Status de Parceria'),
                                            content: Column(
                                              children: [
                                                Text(
                                                  'A parceria está em análise.',
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (status == 'Rejeitado') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Status de Parceria'),
                                            content: Column(
                                              children: [
                                                Text(
                                                  'A parceria foi rejeitada, aguarde 30 dias e tente novamente',
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VerDisponibilidadeInfluencer(
                                                  estabelecimento: widget.data),
                                        ),
                                      );
                                    }
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Termos de Parceria'),
                                        content: Column(
                                          children: [
                                            Text(
                                              'Aqui estão os termos de parceria...',
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              _adicionarParceria();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Aceitar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancelar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    parceriaExistente
                                        ? Icons.remove_red_eye
                                        : Icons.add,
                                    color: Color.fromARGB(255, 94, 197, 212),
                                  ),
                                  Text(
                                    textButton,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 94, 197, 212),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<String?> _verificarStatusParceria(Map<String, dynamic> data) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('parceria')
        .where('idEstabelecimento', isEqualTo: '${data['uid']}')
        .where('idParceiro',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['statusParceria'];
    } else {
      return null;
    }
  }

  Stream<bool> _verificarParceriaStream() {
    return FirebaseFirestore.instance
        .collection('parceria')
        .where('idEstabelecimento', isEqualTo: '${widget.data['uid']}')
        .where('idParceiro',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString())
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.isNotEmpty);
  }

  void _adicionarParceria() {
    // Substitua os valores abaixo pelos dados reais que você deseja adicionar

    // Adiciona um documento à coleção 'parceria'
    FirebaseFirestore.instance.collection('parceria').add({
      'idParceiro': FirebaseAuth.instance.currentUser?.uid.toString(),
      'idEstabelecimento': '${widget.data['uid']}',
      'statusParceria': 'Pendente', // ou 'aprovado', dependendo da sua lógica
      // Adicione outros campos necessários
    }).then((value) {
      print('Parceria adicionada com sucesso!');
    }).catchError((error) {
      print('Erro ao adicionar parceria: $error');
    });
  }

  void launchUrl(Uri url) async {
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }
}
