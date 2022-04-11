import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// providers
import '../providers/auth_provider.dart';

// utils
import '../utils/time_converter.dart';

// widgets
import '../widgets/custom_form_field.dart';
import '../widgets/custom_progress_indicator.dart';

class DataEntryScreen extends StatelessWidget {
  static const routeName = 'data-entry-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back_ios))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Icon(Icons.date_range),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Water Tank Information',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 270),
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.60),
                          height: 1.4,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      GoogleSignInAccount googleAccount =
                          authProvider.googleAcount;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(googleAccount.photoUrl),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            '${googleAccount.email}',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              DataEntryForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class DataEntryForm extends StatefulWidget {
  @override
  _DataEntryFormState createState() => _DataEntryFormState();
}

class _DataEntryFormState extends State<DataEntryForm> {
  bool _loading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  String id;

  void submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    toggleLoading();
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .signUp(['tank-1']);
      Navigator.of(context).pop();
      return;
    } catch (e) {
      print(e);
    }
    toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                  flex: 2,
                  child: CustomFormField(
                    label: 'Tank Id',
                    child: TextFormField(
                      controller: TextEditingController(text: '$id'),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'tank id',
                        suffixText: '',
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (String value) {
                        return null;
                      },
                      onSaved: (String value) {
                        setState(() {
                          id = value;
                        });
                      },
                    ),
                  )),
              Expanded(
                child: SizedBox(
                  width: 0,
                ),
              ),
              RaisedButton(
                elevation: 1,
                color: Color.fromARGB(255, 0, 60, 192),
                child: _loading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CustomProgressIndicatior())
                    : Text(
                        'Let\'t go',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
                onPressed: () {
                  //toggleLoading();
                  submit();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
