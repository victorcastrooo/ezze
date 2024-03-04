// ignore_for_file: unused_import, unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parceiroezze/widget/textField.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';

class CadastrarFatura extends StatefulWidget {
  final Map<String, dynamic> estabelecimento;
  CadastrarFatura({Key? key, required this.estabelecimento}) : super(key: key);

  @override
  State<CadastrarFatura> createState() => _CadastrarFaturaState();
}

class _CadastrarFaturaState extends State<CadastrarFatura> {
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _diavencimento = TextEditingController();
  late DateTime _selectedDueDate;
  late DateTime _selectedMonthlyDueDate;
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDueDate = DateTime.now();
    _selectedMonthlyDueDate = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contrato App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cadastrando Contrato:'),
            Text('${widget.estabelecimento['nomeFantasia']}'),
            TextField(
              controller: _servicesController,
              decoration: InputDecoration(labelText: 'Serviços'),
            ),
            TextField(
              controller: _diavencimento,
              decoration: InputDecoration(labelText: 'Dia de Vencimento'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _selectDueDate(context),
              child: Text('Selecione a Validade do Contrato'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Data Selecionada: ${DateFormat('dd/MM/yyyy').format(_selectedMonthlyDueDate)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _saveToFirebase(),
              child: Text('Salvar no Firebase'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    Locale myLocale = Localizations.localeOf(context);

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.utc(2000, 1, 1),
      lastDate: DateTime.utc(2101, 12, 31),
      locale: myLocale,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // your color
            hintColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedMonthlyDueDate) {
      setState(() {
        _selectedMonthlyDueDate = picked;
      });
    }
  }

  void _saveToFirebase() {
    if (_servicesController.text.isNotEmpty && _diavencimento.text.isNotEmpty) {
      // Converte o número inteiro de vencimento mensal para um objeto DateTime
      int diaVencimento = int.parse(_diavencimento.text);

      // Obtém a data atual
      DateTime currentDate = DateTime.now();

      // Obtém a data de vencimento do contrato
      DateTime vencimentoContrato = _selectedMonthlyDueDate;

      // Cria uma lista de datas mensais até a data de vencimento do contrato
      List<DateTime> datasMensais = [];

      // Calcula a primeira data de vencimento mensal
      DateTime primeiraData =
          DateTime(currentDate.year, currentDate.month, diaVencimento);

      // Adiciona um mês se a primeira data for no mesmo mês do vencimento do contrato
      if (primeiraData.isBefore(vencimentoContrato) ||
          primeiraData.month == vencimentoContrato.month) {
        primeiraData =
            DateTime(currentDate.year, currentDate.month + 1, diaVencimento);
      }

      // Adiciona a primeira data de vencimento mensal
      datasMensais.add(primeiraData);

      // Calcula as datas mensais até o vencimento do contrato
      while (datasMensais.last.isBefore(vencimentoContrato)) {
        DateTime proximaData = datasMensais.last.add(Duration(days: 30));
        datasMensais
            .add(DateTime(proximaData.year, proximaData.month, diaVencimento));
      }

      // Salva no Firebase
      FirebaseFirestore.instance.collection('contratos').add({
        'servicos': _servicesController.text,
        'vencimentoMensal': diaVencimento,
        'vencimentoContrato': _selectedMonthlyDueDate,
        'datasMensais':
            datasMensais.map((date) => date.toIso8601String()).toList(),
        'idEsta': '${widget.estabelecimento['uid']}',
      }).then((value) {
        print("Contrato salvo no Firebase com ID: ${value.id}");
        _resetFields();
        _showSnackBar(
          'Contrato salvo com sucesso!',
          Colors.green,
        );
        Navigator.pop(context);
      }).catchError((error) {
        print("Erro ao salvar contrato: $error");
      });
    } else {
      print("Preencha todos os campos antes de salvar.");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetFields() {
    _servicesController.clear();
    setState(() {
      _selectedMonthlyDueDate = DateTime.now();
    });
  }
}
