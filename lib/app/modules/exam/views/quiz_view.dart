import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizView extends StatefulWidget {
  final String subject;
  final int grade;
  final int duration;

  const QuizView({
    Key? key,
    required this.subject,
    required this.grade,
    required this.duration,
  }) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> with WidgetsBindingObserver {
  Timer? _timer;
  int _timeLeft = 0;
  int _currentQuestionIndex = 0;
  List<Map<String, dynamic>> _questions = [];
  Map<int, String> _answers = {};
  bool _isFinished = false;
  int _penaltyCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timeLeft = widget.duration * 60; // Convert to seconds
    _generateQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_isFinished) {
      _addPenalty();
    }
  }

  void _addPenalty() async {
    if (_isFinished) return;
    
    _penaltyCount++;
    
    // Show warning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Peringatan!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Anda telah keluar dari aplikasi ujian!\nPenalti: +5 poin\nTotal keluar: $_penaltyCount kali',
            style: const TextStyle(
              fontSize: 16, 
              height: 1.5,
              color: Color(0xFF475569),
            ),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Kembali ke Ujian',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );

    // Add penalty to Firebase
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        await userDoc.update({
          'penaltyPoints': FieldValue.increment(5),
        });
      }
    } catch (e) {
      print('Error adding penalty: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  void _generateQuestions() {
    _questions = [
      // Matematika
      {
        'question': 'Berapakah hasil dari 15 + 27?',
        'options': ['40', '42', '45', '47'],
        'correct': '42',
      },
      {
        'question': 'Berapakah hasil dari 8 × 7?',
        'options': ['54', '56', '58', '60'],
        'correct': '56',
      },
      // Bahasa Indonesia
      {
        'question': 'Kalimat efektif adalah?',
        'options': [
          'Kalimat yang panjang',
          'Kalimat dengan banyak kata sulit',
          'Kalimat yang jelas, padat, dan tepat',
          'Kalimat yang menggunakan bahasa asing'
        ],
        'correct': 'Kalimat yang jelas, padat, dan tepat',
      },
      // IPA
      {
        'question': 'Organ tubuh manusia yang berfungsi untuk bernapas adalah?',
        'options': ['Jantung', 'Paru-paru', 'Hati', 'Ginjal'],
        'correct': 'Paru-paru',
      },
      {
        'question': 'Planet terdekat dengan matahari adalah?',
        'options': ['Venus', 'Mars', 'Merkurius', 'Bumi'],
        'correct': 'Merkurius',
      },
      // IPS
      {
        'question': 'Siapakah presiden pertama Indonesia?',
        'options': ['Soekarno', 'Soeharto', 'Habibie', 'Megawati'],
        'correct': 'Soekarno',
      },
      {
        'question': 'Benua terbesar di dunia adalah?',
        'options': ['Afrika', 'Amerika', 'Asia', 'Eropa'],
        'correct': 'Asia',
      },
      // Geografi
      {
        'question': 'Ibu kota Jawa Tengah adalah?',
        'options': ['Surabaya', 'Semarang', 'Yogyakarta', 'Solo'],
        'correct': 'Semarang',
      },
      // Bahasa Inggris
      {
        'question': 'Bahasa Inggris dari "rumah" adalah?',
        'options': ['Home', 'House', 'Building', 'Place'],
        'correct': 'House',
      },
      {
        'question': 'Bahasa Inggris dari "sekolah" adalah?',
        'options': ['Class', 'School', 'Study', 'Learn'],
        'correct': 'School',
      },
      // PKN
      {
        'question': 'Undang-Undang Dasar 1945 disahkan pada tanggal?',
        'options': ['1 Juni', '17 Agustus', '18 Agustus', '20 Mei'],
        'correct': '18 Agustus',
      },
    ];
  }

  void _finishQuiz() {
    setState(() {
      _isFinished = true;
    });
    _timer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Ujian Selesai',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultItem(
                Icons.subject_rounded,
                'Mata Pelajaran',
                widget.subject,
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: 12),
              _buildResultItem(
                Icons.quiz_rounded,
                'Soal Dijawab',
                '${_answers.length}/${_questions.length}',
                const Color(0xFF059669),
              ),
              const SizedBox(height: 12),
              _buildResultItem(
                Icons.warning_rounded,
                'Penalti',
                '$_penaltyCount kali keluar aplikasi',
                Colors.red,
              ),
              const SizedBox(height: 12),
              _buildResultItem(
                Icons.score_rounded,
                'Total Penalti Poin',
                '${_penaltyCount * 5}',
                Colors.orange,
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Back to subject list
                Get.back();// Back to exam view
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFEF4444),
              ),
              SizedBox(height: 16),
              Text(
                'Memuat soal ujian...',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        if (!_isFinished) {
          _addPenalty();
          return true; 
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            '${widget.subject} - Kelas ${widget.grade}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: const Color(0xFFE2E8F0),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _timeLeft < 300 
                    ? const Color(0xFFEF4444) 
                    : const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_timeLeft < 300 
                        ? const Color(0xFFEF4444) 
                        : const Color(0xFFEF4444)).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_timeLeft),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress Ujian',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Soal ${_currentQuestionIndex + 1} dari ${_questions.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _penaltyCount > 0 
                                ? const Color(0xFFEF4444).withOpacity(0.1)
                                : const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _penaltyCount > 0 ? Icons.warning_rounded : Icons.check_circle_rounded,
                                size: 16,
                                color: _penaltyCount > 0 
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Penalti: $_penaltyCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _penaltyCount > 0 
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Question Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'PERTANYAAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFEF4444),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion['question'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Options Section
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion['options'].length,
                  itemBuilder: (context, index) {
                    final option = currentQuestion['options'][index];
                    final isSelected = _answers[_currentQuestionIndex] == option;
                    final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _answers[_currentQuestionIndex] = option;
                            });
                            HapticFeedback.lightImpact();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFFEF4444).withOpacity(0.08)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFFCBD5E1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      optionLabel,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected 
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected 
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFF475569),
                                      fontWeight: isSelected 
                                          ? FontWeight.w600 
                                          : FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Navigation Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex--;
                            });
                            HapticFeedback.lightImpact();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF475569),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.arrow_back_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Sebelumnya',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                    
                    Expanded(
                      flex: _currentQuestionIndex > 0 ? 1 : 1,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentQuestionIndex < _questions.length - 1) {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          } else {
                            _finishQuiz();
                          }
                          HapticFeedback.lightImpact();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentQuestionIndex < _questions.length - 1 
                                  ? 'Selanjutnya' 
                                  : 'Selesai',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentQuestionIndex < _questions.length - 1 
                                  ? Icons.arrow_forward_rounded 
                                  : Icons.check_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}