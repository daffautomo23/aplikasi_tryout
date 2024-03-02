import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email tidak boleh kosong';
                  } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),

              // Register button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Register user
                    var response = await http.post(
                      Uri.parse('https://api-test.eksam.cloud/api/v1/auth/register'),
                      body: jsonEncode({
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'password': _passwordController.text,
                      }),
                      headers: {'Content-Type': 'application/json',
                        'Authorization': 'Bearer 438|6Rw4bCK3mhcUlFVZkWNGILZEnFTn6rHmgdXPN1dee065117d'},

                    );

                    if (response.statusCode == 200) {
                      // Registration successful
                      print('Registrasi berhasil!');
                      // Navigate to Login page
                      Navigator.pushNamed(context, '/login');
                    } else {
                      // Registration failed
                      var error = jsonDecode(response.body)['error'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  }
                },
                child: Text('Register'),
              ),

              // Login button
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Sudah memiliki akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Lakukan proses login
                    var response = await http.post(
                      Uri.parse('https://api-test.eksam.cloud/api/v1/auth/login'),
                      body: jsonEncode({
                        'email': _emailController.text,
                        'password': _passwordController.text,
                      }),
                      headers: {'Content-Type': 'application/json',
                        'Authorization': 'Bearer 438|6Rw4bCK3mhcUlFVZkWNGILZEnFTn6rHmgdXPN1dee065117d'},
                    );

                    if (response.statusCode == 200) {
                      // Login berhasil
                      print('Login berhasil!');
                      Navigator.pushNamed(context, '/soal');
                    } else {
                      // Login gagal
                      var error = jsonDecode(response.body)['error'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Question {
  final String id;
  final String pertanyaan;
  final String jawabanA;
  final String jawabanB;
  final String jawabanC;
  final String jawabanD;
  final String jawabanBenar;

  Question({
    required this.id,
    required this.pertanyaan,
    required this.jawabanA,
    required this.jawabanB,
    required this.jawabanC,
    required this.jawabanD,
    required this.jawabanBenar,
  });
}

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  late List<Question> questions;
  int currentIndex = 0;
  int correctAnswers = 0;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    // Load questions from local database or API
    questions = [
      Question(
        id: "1",
        pertanyaan: "Apa ibukota negara Indonesia?",
        jawabanA: "Jakarta",
        jawabanB: "Bandung",
        jawabanC: "Surabaya",
        jawabanD: "Medan",
        jawabanBenar: "Jakarta",
      ),
      Question(
        id: "2",
        pertanyaan: "Berapakah 1 + 1?",
        jawabanA: "3",
        jawabanB: "4",
        jawabanC: "2",
        jawabanD: "5",
        jawabanBenar: "2",
      ),
      // Add more questions as needed
    ];

    setState(() {});
  }

  void navigateToNextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      setState(() {
        selectedAnswer = null; // Reset selected answer for the new question
      });
    }
  }

  void navigateToPreviousQuestion() {
    if (currentIndex > 0) {
      currentIndex--;
      setState(() {
        selectedAnswer = null; // Reset selected answer for the previous question
      });
    }
  }

  void _showReportDialog(BuildContext context) async {
    String laporan = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Laporkan Soal'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Keterangan laporan'),
                  onChanged: (value) => laporan = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                reportQuestion(laporan); // Call directly without awaiting
                Navigator.pop(context);
              },
              child: Text('Laporkan'),
            ),
          ],
        );
      },
    );
  }

  void reportQuestion(String laporan) async {
    final body = json.encode({
      'tryout_question_id': questions[currentIndex].id, // Replace with the relevant ID
      'laporan': laporan,
    });

    // Send the POST request
    final response = await http.post(
      Uri.parse('https://api-test.eksam.cloud/api/v1/tryout/lapor-soal/create'),
      body: body,
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer 4|7xzuxry4Ja10sVHCHNixrDvXxy4SmFD9pwpfTvy51a054d29',},
    );

    // Handle the response
    if (response.statusCode == 200) {
      // Report sent successfully (implement logic for success)
      print('Report sent successfully!');
    } else {
      // Handle error (e.g., display error message)
      print('Failed to send report: ${response.statusCode}');
    }
  }

  void checkAnswer() {
    if (selectedAnswer != null) {
      if (selectedAnswer == questions[currentIndex].jawabanBenar) {
        correctAnswers++;
      }
    }
  }

  void finishTest() {
    // Call checkAnswer to ensure the final answer is checked
    checkAnswer();

    if (currentIndex == questions.length - 1) {
      // Display result to the user when it's the last question
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hasil Pengerjaan'),
            content: Text('Jawaban Benar: $correctAnswers / ${questions.length}'),
            actions: [

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () async {
                  await logout(); // Await the completion of the logout Future

                  if (true) { // Assuming logout is successful after completion
                    // Directly navigate to the login page using pushReplacementNamed
                    Navigator.of(context).pushReplacementNamed('/login');
                    correctAnswers = 0;
                    selectedAnswer = null;
                  } else {
                    print('Logout successful.'); // Handle logout error (optional)
                  }
                },
                child: Text('Logout'),
              ),


            ],
          );
        },
      );
    } else {
      // Proceed to the next question
      navigateToNextQuestion();
      selectedAnswer = null; // Reset selectedAnswer for the new question
    }
  }

// Add logout function
  Future<void> logout() async {
    // Implement your logout logic here
    // Make a POST request to https://api-test.eksam.cloud/api/v1/auth/logout
    // Handle the response and clear user data if successful

    // Example using http package with token:
    final response = await http.post(
      Uri.parse('https://api-test.eksam.cloud/api/v1/auth/logout'),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer 438|6Rw4bCK3mhcUlFVZkWNGILZEnFTn6rHmgdXPN1dee065117d',
      },
    );

    if (response.statusCode == 200) {
      print('Logout successful.');
      // Clear user data (e.g., tokens, user information)
    } else {
      print('Failed to logout. Error: ${response.statusCode}');
      // Handle logout error (optional)
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengerjaan Soal'),
      ),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pertanyaan ${currentIndex + 1}:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              questions[currentIndex].pertanyaan,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text('Pilih jawaban:'),
            SizedBox(height: 8.0),
            // Use a Column instead of RadioListTile to prevent overlapping options
            Column(
              children: [
                buildAnswerOption('A', questions[currentIndex].jawabanA),
                buildAnswerOption('B', questions[currentIndex].jawabanB),
                buildAnswerOption('C', questions[currentIndex].jawabanC),
                buildAnswerOption('D', questions[currentIndex].jawabanD),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: navigateToPreviousQuestion,
                  child: Text('Back'),
                ),
                ElevatedButton(
                  onPressed: finishTest,
                  child: currentIndex == questions.length - 1
                      ? Text('Selesai')
                      : Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _showReportDialog(context),
              child: Text('Lapor Soal'),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildAnswerOption(String option, String answerText) {
    return RadioListTile(
      title: Text(answerText),
      value: answerText,
      groupValue: selectedAnswer,
      onChanged: (value) {
        setState(() {
          selectedAnswer = value.toString();
        });
      },
    );
  }
}


// Existing code from the provided prompt

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tryout',
      initialRoute: '/register', // Set Register as the initial route
      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/soal': (context) => QuestionPage(), // Add SoalPage route
      },
    );
  }
}

