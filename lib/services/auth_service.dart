import 'package:firebase_auth/firebase_auth.dart';

class AuthService{

authCreateUSer(String? email,String? password)async{
  UserCredential userCredential = await FirebaseAuth
      .instance
      .createUserWithEmailAndPassword(
      email: email!,
      password: password!);
  return userCredential;
}

  checkAuthUser(String? email, String? password)async{
    UserCredential userCredential = await FirebaseAuth
        .instance
        .signInWithEmailAndPassword(
        email: email!,
        password: password!);
  return userCredential;
  }

  logOutAuth()async{
    await FirebaseAuth.instance.signOut();
  }
}