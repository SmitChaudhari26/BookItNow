// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false; // 🔹 to show progress indicator

  /// 🔹 Login
  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCred.user!.uid;

      // Fetch user from Firestore
      DocumentSnapshot doc = await _firestore
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        AppUser appUser = AppUser.fromMap(
          doc.data() as Map<String, dynamic>,
          uid,
        );
        print("✅ Logged in as ${appUser.email}");
      }

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String msg = "";
      if (e.code == "user-not-found") {
        msg = "No user found with this email.";
      } else if (e.code == "wrong-password") {
        msg = "Incorrect password.";
      } else {
        msg = e.message ?? "Login failed.";
      }
      _showError(msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Signup
  Future<void> _signup() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCred.user!.uid;

      // Create AppUser and store in Firestore
      AppUser newUser = AppUser(
        userId: uid,
        email: _emailController.text.trim(),
        password: _passwordController.text
            .trim(), // ⚠️ not safe to store plain passwords
      );

      await _firestore.collection("users").doc(uid).set(newUser.toMap());

      print("✅ User saved to Firestore: ${newUser.email}");

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String msg = "";
      if (e.code == "email-already-in-use") {
        msg = "This email is already registered.";
      } else if (e.code == "weak-password") {
        msg = "Password is too weak (min 6 chars).";
      } else {
        msg = e.message ?? "Signup failed.";
      }
      _showError(msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Error Snackbar
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),

            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(onPressed: _login, child: Text("Login")),
                      TextButton(onPressed: _signup, child: Text("Signup")),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
