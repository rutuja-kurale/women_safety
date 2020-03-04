package com.astutesoftsoln.women_safety_app;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;
import android.telephony.PhoneNumberUtils;
import android.telephony.SmsManager;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.net.Uri;
import android.content.pm.PackageManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.Context;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.app.PendingIntent;
import android.app.PendingIntent.CanceledException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Random;



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
                  sendMMS(num,uri,result);
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

      Uri contentUri = (new Uri.Builder())
              .authority("com.astutesoftsoln.women_safety_app.MmsFileProvider")
              .path(uri)
              .scheme(ContentResolver.SCHEME_CONTENT)
              .build();
      SmsManager smsManager = SmsManager.getDefault();
      smsManager.sendMultimediaMessage(getApplicationContext(), contentUri, phoneNo, null, null);
//      Intent sendIntent = new Intent(Intent.ACTION_SEND);
//      sendIntent.setType("audio/aac");
//      sendIntent.putExtra("address", phoneNo);
//      sendIntent.putExtra(Intent.EXTRA_STREAM, uri);
//      startActivity(sendIntent);
      result.success("MMS Sent");
    } catch (Exception ex) {
      ex.printStackTrace();
      result.error("Err","MMS Not Sent","");
    }
  }

}
