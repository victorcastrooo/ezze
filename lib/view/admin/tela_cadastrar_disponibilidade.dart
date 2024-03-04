// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parceiroezze/view/utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CadastrarDisponibilidade extends StatefulWidget {
  CadastrarDisponibilidade({Key? key, required this.estabelecimento})
      : super(key: key);

  final Map<String, dynamic> estabelecimento;
  @override
  State<CadastrarDisponibilidade> createState() =>
      _CadastrarDisponibilidadeState();
}

class _CadastrarDisponibilidadeState extends State<CadastrarDisponibilidade> {
  @override
  void initState() {
    super.initState();
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<DateTime> _selectedDates = [];
  Map<DateTime, int> quantidadeMap = {};
  Map<DateTime, String> periodoMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text(
          '${widget.estabelecimento['nomeFantasia']}',
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TableCalendar(
                locale: 'pt_BR',
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color.fromRGBO(113, 0, 150, 1),
                  ),
                  todayTextStyle: TextStyle(color: Colors.black87),
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(29, 112, 0, 150),
                  ),
                ),
                firstDay: kToday,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedDates.add(selectedDay);

                      // Se a data já foi selecionada, mantém os valores
                      if (!quantidadeMap.containsKey(selectedDay)) {
                        quantidadeMap[selectedDay] = 0;
                        periodoMap[selectedDay] = 'Diurno';
                      }
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const Text(
                'Disponibilidades Selecionadas',
                style: TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: _buildSelectedDatesList(),
              ),
              ElevatedButton(
                onPressed: () {
                  saveDataToFirebase();
                },
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> list = ['Diurno', 'Noturno'];

  List<Widget> _buildSelectedDatesList() {
    return _selectedDates.map((DateTime date) {
      return ListTile(
        title: Card(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _deleteDate(date);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.8,
                      child: TextFormField(
                        initialValue: quantidadeMap[date].toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          quantidadeMap[date] = int.tryParse(value) ?? 0;
                        },
                        style: const TextStyle(color: Colors.black54),
                        decoration: InputDecoration(
                          filled: false,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                              strokeAlign: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              strokeAlign: 1,
                              color: Color.fromARGB(180, 0, 0, 0),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black87,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          labelText: "Quantidade",
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(137, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width / 2.8,
                      initialSelection: periodoMap[date],
                      textStyle: const TextStyle(color: Colors.black54),
                      onSelected: (String? value) {
                        setState(() {
                          periodoMap[date] = value!;
                        });
                      },
                      dropdownMenuEntries:
                          list.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _deleteDate(DateTime date) {
    setState(() {
      _selectedDates.remove(date);
      quantidadeMap.remove(date);
      periodoMap.remove(date);
    });
  }

  Future<void> saveDataToFirebase() async {
    CollectionReference disponibilidadeCollection =
        FirebaseFirestore.instance.collection('disponibilidades');

    for (DateTime date in _selectedDates) {
      Map<String, dynamic> data = {
        'data': date,
        'quantidade': quantidadeMap[date],
        'periodo': periodoMap[date],
        'empresaId': widget.estabelecimento['uid'],
      };

      await disponibilidadeCollection.add(data);
    }

    setState(() {
      _selectedDates.clear();
      quantidadeMap.clear();
      periodoMap.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disponibilidades Salvas'),
      ),
    );
  }
}
