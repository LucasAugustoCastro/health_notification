import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'CustomWidget/my_text_field.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if(!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado om sucesso!')),
        );
        Navigator.pushReplacementNamed(context, '/home');

      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        } else if (e.code == 'wrong-password') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = const TextStyle(color: Colors.grey, fontSize: 12.0);
    TextStyle linkStyle = const TextStyle(color: Colors.blue);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0
        ),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sign In",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: defaultStyle,
                        children: <TextSpan>[
                          const TextSpan(text: "Não tem um conta? "),
                          TextSpan(
                              text: 'Registre-se',
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(context, '/register');
                                }),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  MyTextField(
                    myController: _emailController,
                    fieldName: "Digite seu email",
                    myIcon: Icons.email,
                  ),
                  MyTextField(
                    myController: _passwordController,
                    fieldName: "Digite sua senha",
                    myIcon: Icons.lock,
                    obscureText: true,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _loginUser,
          child: const Center(
            child: Text('Login'),
          ),
        ),
      ),
    );
  }
}
