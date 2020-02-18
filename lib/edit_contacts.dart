import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


class editContacts extends StatefulWidget {
  @override
  _editContactsState createState() => _editContactsState();
}

class _editContactsState extends State<editContacts> {


  final _editContactsKey = GlobalKey<FormState>();
  String _num1, _num2, _num3, _num4, _num5;
  bool _autoValidate = false, checkingForNumbers = true;


  String validateMobile(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  Widget loadingUI(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 50.0,),
          Text(
            'Please Wait..Checking for numbers',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget mainUI() {
    return SingleChildScrollView(
      child: Form(
        key: _editContactsKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30.0,),
              Text(
                'Please Enter Atleast 3 Numbers',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 15.0,),
              TextFormField(
                enableInteractiveSelection: true,
                enabled: true,
                initialValue: _num1.toString() == "" ? "" : _num1.toString(),
                validator: validateMobile,
                keyboardType: TextInputType.phone,
                onSaved: (val){
                  setState(() {
                    _num1 = val;
                  });
                },
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                decoration: new InputDecoration(
                  labelText: 'First Number',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  fillColor: Colors.black,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                ),
              ),
              SizedBox(height: 15.0,),
              TextFormField(
                enableInteractiveSelection: true,
                enabled: true,
                initialValue: _num2.toString() == "" ? "" : _num2.toString(),
                validator: validateMobile,
                keyboardType: TextInputType.phone,
                onSaved: (val){
                  setState(() {
                    _num2 = val;
                  });
                },
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                decoration: new InputDecoration(
                  labelText: 'Second Number',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  fillColor: Colors.black,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                ),
              ),
              SizedBox(height: 15.0,),
              TextFormField(
                enableInteractiveSelection: true,
                enabled: true,
                initialValue: _num3.toString() == "" ? "" : _num3.toString(),
                validator: validateMobile,
                keyboardType: TextInputType.phone,
                onSaved: (val){
                  setState(() {
                    _num3 = val;
                  });
                },
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                decoration: new InputDecoration(
                  labelText: 'Third Number',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  fillColor: Colors.black,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                ),
              ),
              SizedBox(height: 15.0,),
              TextFormField(
                enableInteractiveSelection: true,
                enabled: true,
                initialValue: _num4.toString() == "" ? "" : _num4.toString(),
                keyboardType: TextInputType.phone,
                onSaved: (val){
                  setState(() {
                    _num4 = val;
                  });
                },
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                decoration: new InputDecoration(
                  labelText: 'Fourth Number (Optional)',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  fillColor: Colors.black,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                ),
              ),
              SizedBox(height: 15.0,),
              TextFormField(
                enableInteractiveSelection: true,
                enabled: true,
                initialValue: _num5.toString() == "" ? "" : _num5.toString(),
                keyboardType: TextInputType.phone,
                onSaved: (val){
                  setState(() {
                    _num5 = val;
                  });
                },
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                decoration: new InputDecoration(
                  labelText: 'Fifth Number (Optional)',
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black,width: 2.0),
                  ),
                  fillColor: Colors.black,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                ),
              ),
              SizedBox(height: 25.0,),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.70,
                height: 48.0,
                child: RaisedButton(
                  elevation: 18.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  onPressed: (){
                    _validateInputs();
                  },
                  color: Colors.blue,
                  child: Text(
                    'Save Numbers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80.0,),
            ],
          ),
        ),
      ),
    );
  }

  void _validateInputs() {
    print('Validationg');
    if (_editContactsKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _editContactsKey.currentState.save();
      setNumbers();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
        debugPrint(_autoValidate.toString());
      });
    }
  }

  setNumbers() async {
    SharedPreferences userDetails = await SharedPreferences.getInstance();
    userDetails.setString("num1", _num1);
    userDetails.setString("num2", _num2);
    userDetails.setString("num3", _num3);
    userDetails.setString("num4", _num4);
    userDetails.setString("num5", _num5);
    setState(() {
      checkingForNumbers = false;
    });
    Fluttertoast.showToast(
        msg: "Contacts Updated!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.of(context).pushNamed("/home");
  }

  getNumbers() async {
    SharedPreferences numberDetails = await SharedPreferences.getInstance();
    setState(() {
      _num1  = numberDetails.getString("num1");
      _num2 = numberDetails.getString("num2");
      _num3 = numberDetails.getString("num3");
      _num4 = numberDetails.getString("num4");
      _num5 = numberDetails.getString("num5");
      checkingForNumbers = false;
    });
  }

  Future<bool> backButtonHandler() {
    return null;
  }

  @override
  void initState() {
    getNumbers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: backButtonHandler,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Edit Contacts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.pink,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: checkingForNumbers == true ? loadingUI() : mainUI(),
          ),
        ),
      ),
    );
  }
}
