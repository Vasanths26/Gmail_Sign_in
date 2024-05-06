import 'package:chat_app/provider/internet_auth.dart';
import 'package:chat_app/provider/signin_provider.dart';
import 'package:chat_app/screens/home.dart';
import 'package:chat_app/utils/next_screen.dart';
import 'package:chat_app/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldkey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(right: 40, left: 40, top: 90, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage("assets/download.png"),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 55.0),
                      child: Text(
                        "Log in to Netflix",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedLoadingButton(
                    controller: googleController,
                    successColor: Colors.red,
                    width: MediaQuery.of(context).size.width * 0.80,
                    color: Colors.red,
                    onPressed: () {
                      handleGoogleSignIn();
                    },
                    child: const Wrap(
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 14),
                        Text(
                          "Sign in with google",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      // ignore: use_build_context_synchronously
      openSnackbar(context, "Check your internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode, Colors.red);
          googleController.reset();
        } else {
          // checking wheather user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            } else {
              // user dosenot exist
              sp.saveDataToFirebase().then(
                    (value) => sp.saveDataToSharedPreferences().then(
                          (value) => sp.setSignIn().then((value) {
                            googleController.success();
                            handleAfterSignIn();
                          }),
                        ),
                  );
            }
          });
        }
      });
    }
  }

  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomeScreen());
    });
  }
}
