import 'package:chating/AuthScreen/LoginScreen.dart';
import 'package:chating/AuthScreen/RegisterScreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ));
              },
              child: Text(
                'LoginScreen',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegistrationScreen(),
                ));
              },
              child: Text(
                'new user? Register Screen',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),

            ),

          ],
        ),
      ),
    );
  }
}
