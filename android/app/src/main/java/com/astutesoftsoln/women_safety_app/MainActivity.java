package com.astutesoftsoln.women_safety_app;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.util.Log;
import android.content.Intent;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "sendSms";
  private static final String CHANNELL = "sendAudio";

  private MethodChannel.Result callResult;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if(call.method.equals("send")){
                  String num = call.argument("phone");
                  String msg = call.argument("msg");
                  sendSMS(num,msg,result);
                }else{
                  result.notImplemented();
                }
              }
            });

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNELL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if(call.method.equals("sendAudio")){
                  String uri = call.argument("uri");
                  String num = call.argument("phone");
                  sendMMS(uri,num,result);
                }else{
                  result.notImplemented();
                }
              }
            });

  }


  private void sendSMS(String phoneNo, String msg,MethodChannel.Result result) {
    try {
      SmsManager smsManager = SmsManager.getDefault();
      smsManager.sendTextMessage(phoneNo, null, msg, null, null);
      result.success("SMS Sent");
    } catch (Exception ex) {
      ex.printStackTrace();
      result.error("Err","Sms Not Sent","");
    }
  }


  private void sendMMS(String phoneNo, String uri,MethodChannel.Result result) {
    try {
//      SmsManager smsManager = SmsManager.getDefault();
//      smsManager.sendTextMessage(phoneNo, null, msg, null, null);
      Intent sendIntent = new Intent(Intent.ACTION_SEND);
      sendIntent.setClassName("com.android.mms", "com.android.mms.ui.ComposeMessageActivity");
      sendIntent.putExtra("address", phoneNo);
      sendIntent.putExtra(Intent.EXTRA_STREAM, uri);
      sendIntent.setType("audio/aac");
      startActivity(sendIntent);
      result.success("MMS Sent");
    } catch (Exception ex) {
      ex.printStackTrace();
      result.error("Err","MMS Not Sent","");
    }
  }


}
