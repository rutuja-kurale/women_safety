import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intent/extra.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/edit_contacts.dart';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;
import 'package:women_safety_app/about_page.dart';
import 'package:women_safety_app/police_station_page.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:intl/intl.dart' show DateFormat;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new MyHomePage(),
        '/edit': (BuildContext context) => new editContacts(),
        '/about': (BuildContext context) => new About(),
        '/police': (BuildContext context) => new PoliceAddess(),
      },
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
  final assetsAudioPlayer = AssetsAudioPlayer();
  bool isPlaying = false, isRecording = false;
  String _message, _recordingFilePath;
  List<String> recipents = new List<String>();
  static const platform = const MethodChannel('sendSms');
//  static const platform1 = const MethodChannel('sendAudio');
  FlutterSound flutterSound = new FlutterSound();
  t_CODEC _codec = t_CODEC.CODEC_AAC;
  bool _isRecording = false;
  List <String> _path = [null, null, null, null, null, null, null];
  StreamSubscription _recorderSubscription;
  static const timeout = const Duration(seconds: 10);
  static const ms = const Duration(milliseconds: 1);

  requestPermissionsHandler() async {
    await PermissionHandler().requestPermissions([PermissionGroup.location, PermissionGroup.sms,
      PermissionGroup.phone, PermissionGroup.storage, PermissionGroup.microphone]);
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
                _message = "I need Urgent Help!! \n This is my location \n" + "http://maps.google.com/maps?q=$_lat,$_lng&z=17&hl=en";
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
    flutterSound.stopRecorder();
    _locationSubscription.cancel();
    super.dispose();
  }

  Widget mainUi(){
    return dashboardUi();
  }

  Widget dashboardUi(){
    return Column(
      children: <Widget>[
        SizedBox(height: 40.0,),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 80.0,
          child: RaisedButton(
            elevation: 18.0,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0),
            ),
            onPressed: (){
              if(_num1.toString() == null || _num2.toString() == null || _num3.toString() == null){
                Fluttertoast.showToast(
                    msg: "Please add atleast 3 numbers",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              } else {
                sendDirectSmsToAll();
                android_intent.Intent()
                  ..setAction(android_action.Action.ACTION_CALL)
                  ..setData(Uri(scheme: "tel", path: "+91$_num1"))
                  ..startActivity().catchError((e) => print(e));
              }
            },
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Help Me!!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21.0,
                  ),
                ),
                SizedBox(width: 10.0,),
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 30.0,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30.0,),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 80.0,
          child: RaisedButton(
            elevation: 18.0,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
            ),
            onPressed: (){
              android_intent.Intent()
                ..setAction(android_action.Action.ACTION_CALL)
                ..setData(Uri(scheme: "tel", path: "103"))
                ..startActivity().catchError((e) => print(e));
            },
            color: Colors.pink,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Call Helpline No',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21.0,
                  ),
                ),
                SizedBox(width: 10.0,),
                Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 30.0,
                ),
              ],
            ),
            ),
        ),
        SizedBox(height: 30.0,),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 80.0,
          child: RaisedButton(
            elevation: 18.0,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
            ),
            onPressed: (){
              if(isPlaying == false) {
                assetsAudioPlayer.open(
                  "assets/audio/siren.mp3",
                );
                assetsAudioPlayer.play();
                setState(() {
                  isPlaying = true;
                });
              } else {
                assetsAudioPlayer.stop();
                setState(() {
                  isPlaying = false;
                });
              }
              startRecording();
            },
            color: Colors.yellow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Sound Alarm!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21.0,
                  ),
                ),
                SizedBox(width: 10.0,),
                Icon(
                  Icons.notifications_active,
                  color: Colors.black,
                  size: 30.0,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30.0,),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 80.0,
          child: RaisedButton(
            elevation: 18.0,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
            ),
            onPressed: (){
              Fluttertoast.showToast(
                  msg: "Getting Nearby Police Station",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              Navigator.of(context).pushNamed("/police");
            },
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Police Station Near Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21.0,
                  ),
                ),
                SizedBox(width: 10.0,),
                Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 30.0,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 50.0,),
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
    return Padding(
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
              SizedBox(height: 250.0,),
            ],
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
    SharedPreferences userDetails = await SharedPreferences.getInstance();
    userDetails.setString("num1", _num1);
    userDetails.setString("num2", _num2);
    userDetails.setString("num3", _num3);
    userDetails.setString("num4", _num4);
    userDetails.setString("num5", _num5);
    setState(() {
      recipents.add(_num1);
      recipents.add(_num2);
      recipents.add(_num3);
      recipents.add(_num4);
      recipents.add(_num5);
    });
    numbersChecker();
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
    if(_num1 == null || _num2 == null|| _num3 == null){
      setState(() {
        print('If Condition');
        numberFound = false;
//        checkingForNumbers = false;
      });
    } else {
      setState(() {
        print('Else Condition');
//        checkingForNumbers = true;
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

  Future<Null> sendDirectSmsToAll()async {
    print("Sending SMS");
    try {
      if(_num1.toString() != null){
        final String result1 = await platform.invokeMethod('send',<String,dynamic>{"phone":"+91"+ _num1,"msg":_message});
        print(result1);
      }
      if(_num2.toString() != null){
        final String result2 = await platform.invokeMethod('send',<String,dynamic>{"phone":"+91"+ _num2,"msg":_message});
        print(result2);
      }
      if(_num3.toString() != null){
        final String result3 = await platform.invokeMethod('send',<String,dynamic>{"phone":"+91"+ _num3,"msg":_message});
        print(result3);
      }
      if(_num4.toString() != null){
        final String result4 = await platform.invokeMethod('send',<String,dynamic>{"phone":"+91"+ _num4,"msg":_message});
        print(result4);
      }
      if(_num5.toString() != null){
        final String result5 = await platform.invokeMethod('send',<String,dynamic>{"phone":"+91"+ _num5,"msg":_message});
        print(result5);
      }
      Fluttertoast.showToast(
          msg: "SMS Sent with location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } on PlatformException catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
          msg: "Failed to send the SMS " + e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<bool> backButtonHandler() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: new Text('You want to close app now?'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text(
                'No',
                style: const TextStyle(color: Colors.black, fontSize: 19.0),
              ),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.pop(context);
                exit(0);
              },
              child: new Text(
                'Ok',
                style: const TextStyle(color: Colors.black, fontSize: 19.0),
              ),
            ),
          ],
        ));
  }

  void startRecording() async {
    try {

      Directory tempDir = await getTemporaryDirectory();

      String path = await flutterSound.startRecorder(
        uri: '${tempDir.path}/sound.aac',
        codec: _codec,
      );
      print('startRecorder: $path');

      setState(() {
        _recordingFilePath = path;
        isRecording = true;
      });
      startTimeout([int milliseconds]) {
        var duration = milliseconds == null ? timeout : ms * milliseconds;
        return new Timer(duration, stopRecording);
      }
      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
//        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
//        print(txt);

//        this.setState(() {
//          this._recorderTxt = txt.substring(0, 8);
//        });

        this.setState(() {
          this._isRecording = true;
          this._path[_codec.index] = path;
        });

      });
    } catch (err) {
      print ('startRecorder error: $err');
      this.setState(() {
        this._isRecording = false;
      });
    }
  }

  void stopRecording() async {
    try {
      String result = await flutterSound.stopRecorder();
      print ('stopRecorder: $result');
      print(_recordingFilePath);

      if ( _recorderSubscription != null ) {
        _recorderSubscription.cancel ();
        _recorderSubscription = null;
      }
      this.setState(() {
        isRecording = false;
      });
      sendVoiceRecording();
    } catch (err) {
      print ('stopRecorder error: $err');
      this.setState(() {
        this._isRecording = false;
      });
    }
  }

  sendVoiceRecording() async {
    print('sending via sms nad file is:   $_recordingFilePath');
    android_intent.Intent()
      ..setAction(android_action.Action.ACTION_SEND)
      ..putExtra(Extra.EXTRA_PACKAGE_NAME, "com.android.mms.ui.ComposeMessageActivity")
      ..putExtra("address", "$_num1")
      ..setData(Uri(scheme: 'content',
          path:
          _recordingFilePath))
      ..setType('audio/aac')
      ..startActivity().catchError((e) => print(e));

//    final String result1 = await platform1.invokeMethod('sendAudio',
//        <String,dynamic>{"uri":_recordingFilePath, "phone": "+91$_num1"});
  }

  Widget _selectPopup() => PopupMenuButton<int>(
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 1,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.info_outline,
              color: Colors.black,
            ),
            SizedBox(width: 20.0,),
            Text(
              'About',
              style: TextStyle(
                color: Colors.black,
                fontSize: 19.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

      PopupMenuItem(
        value: 2,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.contact_phone,
              color: Colors.black,
            ),
            SizedBox(width: 20.0,),
            Text(
              'Update Contact',
              style: TextStyle(
                color: Colors.black,
                fontSize: 19.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      )
    ],
//    initialValue: 2,
    onCanceled: () {
      print("You have canceled the menu.");
    },
    onSelected: (value) {
      switch (value) {
        case 1: {
          Navigator.of(context).pushNamed("/about");
        }
        break;
        case 2: {
          if(numberFound == false){
            Fluttertoast.showToast(
                msg: "Please add contacts first",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          } else {
            Navigator.of(context).pushNamed("/edit");
          }
        }
        break;
      }
    },
    icon: Icon(
      Icons.more_vert,
      color: Colors.white,
      size: 30.0,),
    offset: Offset(0, 100),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: backButtonHandler,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Women Safety',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.pink,
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: _selectPopup(),
              ),
            ],
          ),
          body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/back_safe.png"), fit: BoxFit.fill),
              ),
            child: numberFound == true ? mainUi() : addNumbersUi(),
          ),
        ),
      ),
    );
  }
}
