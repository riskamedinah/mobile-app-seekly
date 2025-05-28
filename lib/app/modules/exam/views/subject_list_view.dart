import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz_view.dart';

class SubjectListView extends StatelessWidget {
  final int grade;

  const SubjectListView({Key? key, required this.grade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjects = _getSubjectsForGrade(grade);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelas $grade - Mata Pelajaran'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Mata Pelajaran',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kelas $grade',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: subjects.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _buildSubjectCard(subject);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Periksa apakah sedang dalam mode ujian
          if (Get.isRegistered<bool>(tag: 'examMode') && Get.find<bool>(tag: 'examMode')) {
            Get.snackbar(
              'Sedang dalam Ujian',
              'Selesaikan ujian terlebih dahulu sebelum membuka yang lain.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red[100],
              colorText: Colors.black,
            );
            return;
          }

          // Jika tidak sedang ujian, navigasi ke halaman QuizView
          Get.to(() => QuizView(
                subject: subject['name'],
                grade: grade,
                duration: subject['duration'],
              ));

          // Tandai bahwa pengguna masuk ke mode ujian
          Get.put<bool>(true, tag: 'examMode');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: subject['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  subject['icon'],
                  color: subject['color'],
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${subject['duration']} menit',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${subject['questions']} soal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSubjectsForGrade(int grade) {
    return [
      {
        'name': 'Pengetahuan Umum',
        'icon': Icons.school,
        'color': Colors.deepOrange,
        'duration': 60,
        'questions': 10,
      },
    ];
  }
}
