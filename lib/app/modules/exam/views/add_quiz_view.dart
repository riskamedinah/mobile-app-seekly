import 'package:flutter/material.dart';

class AddQuizView extends StatelessWidget {
  final int grade;
  const AddQuizView({Key? key, required this.grade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Ujian Kelas $grade'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Text(
          'Form tambah ujian untuk kelas $grade',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
