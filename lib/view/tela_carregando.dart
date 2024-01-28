import 'package:flutter/material.dart';

class TelaCarregando extends StatelessWidget {
  const TelaCarregando({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(26, 0, 0, 0),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // Indicador de progresso
            CircularProgressIndicator(
              // Cor do indicador de progresso
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color.fromRGBO(113, 0, 150, 1)),
            ),

            // Adicione um espaçamento abaixo do indicador de progresso
            SizedBox(height: 20),

            // Texto indicando que a página está carregando
            Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(113, 0, 150, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
