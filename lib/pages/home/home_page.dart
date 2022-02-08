import 'package:chating/constants/string_constant.dart';
import 'package:chating/pages/login/login_page.dart';
import 'package:chating/pages/registration/register_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ));
              },
              child: Text(
                '${loginScreen}',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegistrationPage(),
                ));
              },
              child: Text(
                '${newUser}? ${registerScreen}',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),

            ),

          ],
        ),
      ),
    );
  }
}
