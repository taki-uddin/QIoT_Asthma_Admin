import 'package:flutter/material.dart';
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/services/api/authentication.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String deviceType = 'web';
  bool _obscureText = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      deviceType = "web";
    });
  }

  void onSignIn() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      Map<String, dynamic> signInResult = await Authentication.signIn(
        email,
        password,
        null,
        deviceType,
      );

      bool signInSuccess = signInResult['success'] ?? false;
      Map<String, dynamic>? responseData = signInResult['data'];
      String? errorMessage = signInResult['error'];

      if (signInSuccess) {
        SessionStorageHelpers.setStorage('loginState', 'true');
        SessionStorageHelpers.setStorage(
            'accessToken', responseData?['accessToken']);
        print(responseData?['payload'][0]['user']['_id']);
        SessionStorageHelpers.setStorage(
            'userID', responseData?['payload'][0]['user']['_id']);
        Navigator.popAndPushNamed(context, '/dashboard');
      } else {
        // Authentication failed
        print('Authentication failed: $errorMessage');
      }
    } else {
      print('Invalid form');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenSize.width * 0.5,
                  height: screenSize.height,
                  child: Center(
                    child: Image.asset(
                      'assets/images/appLogo/appLogo_3x-nobg.png',
                      width: screenSize.width * 0.2,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.5,
                  height: screenSize.height,
                  child: Center(
                    child: Container(
                      width: screenSize.width * 0.32,
                      height: screenSize.height * 0.56,
                      decoration: BoxDecoration(
                        color: const Color(0XFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF28293D).withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: screenSize.height * 0.04),
                          const Text(
                            'Sign in to your account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004283),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 52, vertical: 16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email ID',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      setState(() {
                                        _isEmailValid = RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value);
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email ID is required';
                                      } else if (!_isEmailValid) {
                                        return 'Enter valid Email ID';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: screenSize.height * 0.02),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder(),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: Icon(
                                          _obscureText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.visiblePassword,
                                    onChanged: (value) {
                                      setState(() {
                                        _isPasswordValid = RegExp(
                                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?]).{8,}$')
                                            .hasMatch(value);
                                      });
                                    },
                                    obscureText: _obscureText,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      } else if (!_isPasswordValid) {
                                        return 'Minimum 8 characters, \nMinimum 1 special character, \nMinimum 1 numerical character, \nMinimum 1 uppercase & lowercase character';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: screenSize.height * 0.04),
                                  ElevatedButton(
                                    onPressed: () {
                                      onSignIn();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size(screenSize.width * 1.0,
                                          screenSize.height * 0.06),
                                      foregroundColor: const Color(0xFFFFFFFF),
                                      backgroundColor: const Color(0xFF004283),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 15),
                                    ),
                                    child: const Text('Sign In'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF6C6C6C),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
