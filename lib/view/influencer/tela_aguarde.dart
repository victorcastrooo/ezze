import 'package:flutter/material.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import 'package:parceiroezze/view/tela_login.dart';

class Aguarde extends StatefulWidget {
  const Aguarde({super.key});

  @override
  State<Aguarde> createState() => _AguardeState();
}

class _AguardeState extends State<Aguarde> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(image: AssetImage('./assets/images/ezze_roxo.png')),
              const SizedBox(
                height: 75,
              ),
              const Image(
                image: AssetImage('./assets/images/icon_aguarde.png'),
                width: 150,
              ),
              const SizedBox(
                height: 4,
              ),
              const GradientAnimationText(
                text: Text(
                  'Aguarde sua liberação pelos administradores.',
                  style: TextStyle(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                colors: [
                  Color.fromRGBO(113, 0, 150, 1),
                  Colors.indigo,
                ],
                duration: Duration(seconds: 5),
              ),
              const SizedBox(
                height: 125,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TelaLogin()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(113, 0, 150, 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      Text(
                        "Voltar ao Início",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
