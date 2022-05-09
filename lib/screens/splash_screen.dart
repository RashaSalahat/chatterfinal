import 'dart:async';

import 'package:chatter/screens/screens.dart';
import 'package:chatter/screens/sign_in_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import 'home_screen.dart';

// as a loading screen while the loading is happening:

class SplashScreen extends StatefulWidget {
  static Route get route => MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final StreamSubscription<firebase.User?>
      listener; // The Firebase User  // this listener give us the user

  @override
  void initState() {
    super.initState();
    _handleAuthenticatedState();
  }

// to handle Authentication
  Future<void> _handleAuthenticatedState() async {
    final auth = firebase.FirebaseAuth.instance;
    if (!mounted) {
      return;
    }
    listener = auth.authStateChanges().listen((user) async {
      // every time the auth stream changes : (The User log out)

      //this if user is not null
      // I think this would be in the register / sign up page

      //Are We loggged in  if yes Go to the home screen (put in the application)
      if (user != null) {
        // We are authenticated
        // get Stream user token

        // we need to call a stream authentication token
        // call Firebase cloud Functions and create a token for that

        //you call the function after you got it
        final callable =
            FirebaseFunctions.instance.httpsCallable('getStreamUserToken');

        // A lisy of features
        final results = await Future.wait([
          callable(),
          // delay to show loading indicator
          Future.delayed(const Duration(milliseconds: 700)),
        ]);

        // connect Stream user
        final client = StreamChatCore.of(context).client; // get our client

        // connect our user
        //We are connected to the stream api
        await client.connectUser(
          // when the user is signed in

          User(id: user.uid),
          results[0]!.data, // the first result

          //this is the stream api token
        );

        // authenticated
        // replace the whole splash screen
        Navigator.of(context).pushReplacement(HomeScreen.route);
      } else {
        // delay to show loading indicator
        await Future.delayed(const Duration(milliseconds: 700));

        /// loading animation
        // not authenticated
        Navigator.of(context).pushReplacement(SignInScreen.route);

        /// if the user is null // to be removed  // Not authenticated
        // replace
      }
    });
  }

  @override
//dispose : in the place where we are not authenticated or even authenticated //we dipose the splash screen
//
// in the event where we push the replacement
  void dispose() {
    print("Dispose called"); //
    // we call listener.cancel to prevent the stream  from taking care of the authentication process
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
