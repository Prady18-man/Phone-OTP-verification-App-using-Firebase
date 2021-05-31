import 'package:firebase_auth/firebase_auth.dart';
import 'package:flu/screens/homescreen.dart';
import 'package:flutter/material.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class Loginscreen extends StatefulWidget {
  Loginscreen({Key? key}) : super(key: key);

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  MobileVerificationState currentstate =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  late String verificationId;
  bool showLoading = false;
  void signInWidthPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      //_scaffoldKey.currentState.showSnackBar(Snackbar(context:Text(e.message)));
    }
  }

  getMobileFormWidget(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(hintText: "Phone Number"),
        ),
        SizedBox(height: 16),
        TextButton(
            onPressed: () async {
              setState(() {
                showLoading = true;
              });
              await _auth.verifyPhoneNumber(
                  phoneNumber: phoneController.text,
                  verificationCompleted: (phoneAuthCredential) async {
                    setState(() {
                      showLoading = false;
                    });
                  },
                  verificationFailed: (verificationFailed) async {
                    showLoading = false;
                    /*  if(verificationFailed.message!=null){
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(verificationFailed.message.toString())));}
                  */
                  },
                  codeSent: (verificationId, resendingtoken) async {
                    setState(() {
                      showLoading = false;
                      currentstate =
                          MobileVerificationState.SHOW_OTP_FORM_STATE;
                      this.verificationId = verificationId;
                    });
                  },
                  codeAutoRetrievalTimeout: (verificationId) async {});
            },
            child: Text("Send")),
        Spacer()
      ],
    );
  }

  getOtpFormWidget(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(hintText: "Enter OTP"),
        ),
        SizedBox(height: 16),
        TextButton(
            onPressed: () async {
              PhoneAuthCredential phoneAuthCredential =
                  PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: otpController.text);
              signInWidthPhoneAuthCredential(phoneAuthCredential);
            },
            child: Text("Verify")),
        Spacer()
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: showLoading
              ? Center(child: CircularProgressIndicator())
              : currentstate == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                  ? getMobileFormWidget(context)
                  : getOtpFormWidget(context),
          padding: const EdgeInsets.all(16),
        ));
  }
}
