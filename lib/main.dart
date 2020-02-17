import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Map<PermissionGroup, PermissionStatus> requestPermissions;
  PermissionStatus locationPermission;
  LocationData _startLocation;
  LocationData _currentLocation;
  double _lat,_lng;
  bool numberFound = false, _autoValidate = false, checkingForNumbers = true;
  final _numbersKey = GlobalKey<FormState>();
  String _num1, _num2, _num3, _num4, _num5;
  StreamSubscription<LocationData> _locationSubscription;
  Location _locationService  = new Location();
  bool _permission = false;
  String error;

  requestPermissionsHandler() async {
    await PermissionHandler().requestPermissions([PermissionGroup.location, PermissionGroup.sms]);
//    await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    initPlatformState();

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    await _locationService.changeSettings(accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");
        if (_permission) {
          location = await _locationService.getLocation();

          _locationSubscription = _locationService.onLocationChanged().listen((LocationData result) async {
            if(mounted){
              setState(() {
                _currentLocation = result;
                _lat = _currentLocation.latitude;
                _lng = _currentLocation.longitude;
              });
            }
          });
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if(serviceStatusResult){
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    }
    setState(() {
      _startLocation = location;
    });
    debugPrint(_startLocation.toString());
    if(_currentLocation == null || _startLocation == null){
      initPlatformState();
    }
  }

  @override
  void initState() {
    requestPermissionsHandler();
    getNumbers();
    super.initState();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  Widget mainUi(){
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: checkingForNumbers == true ? loadingUI() : dashboardUi(),
    );
  }

  Widget dashboardUi(){
    return Column(
      children: <Widget>[
        SizedBox(height: 40.0,),
        Text(
          'Your Current Location:',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 15.0,),
        Text(
          'Latitude: $_lat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 15.0,),
        Text(
          'Longitude: $_lng',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 30.0,),
      ],
    );
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

  Widget addNumbersUi() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(left:15.0, right: 15.0),
        child: SingleChildScrollView(
          child: Form(
            key: _numbersKey,
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
                      'Add Numbers',
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
      ),
    );
  }

  String validateMobile(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  setNumbers() async {
    debugPrint("Setting Numbers Now");
    SharedPreferences userDetails = await SharedPreferences.getInstance();
    userDetails.setString("num1", _num1);
    userDetails.setString("num2", _num2);
    userDetails.setString("num3", _num3);
    userDetails.setString("num4", _num4);
    userDetails.setString("num5", _num5);
    uiChanger();
  }

  uiChanger(){
    setState(() {
      numberFound = true;
      print(_num1);
      print(_num2);
      print(_num3);
      print(numberFound);
    });
  }

  getNumbers() async {
    SharedPreferences numberDetails = await SharedPreferences.getInstance();
    setState(() {
      _num1  = numberDetails.getString("num1");
      _num2 = numberDetails.getString("num2");
      _num3 = numberDetails.getString("num3");
      _num4 = numberDetails.getString("num4");
      _num5 = numberDetails.getString("num5");
    });
    numbersChecker();
  }

  numbersChecker(){
  print("Number 1 " +_num1.toString());
  print("Number 2 " +_num2.toString());
  print("Number 3 " +_num3.toString());
    if(_num1 == "null" || _num2 == "null" || _num3 == "null"){
      setState(() {
        numberFound = false;
      });
    } else {
      setState(() {
        checkingForNumbers = false;
        numberFound = true;
      });
    }
  }

  void _validateInputs() {
    print('Validationg');
    if (_numbersKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _numbersKey.currentState.save();
      setNumbers();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
        debugPrint(_autoValidate.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: numberFound == false ? mainUi() : addNumbersUi(),
    );
  }
}
