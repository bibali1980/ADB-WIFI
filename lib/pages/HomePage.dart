import 'dart:io';
import 'package:adb_wifi/Classes/PreferenceUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:root/root.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const methodChannel = const MethodChannel('com.adbwifi/adbwifichannel');

  String actualButtonOnOffString = "START";
  Color actualButtonColor = Colors.grey;
  String message = 'adb wifi STOPPED';

  bool isSwitched = PreferenceUtils.getBool("IsSwitched", false);
  bool isStarted = PreferenceUtils.getBool("IsStarted", false);
  String internalIP = PreferenceUtils.getString("InternalIP", "");

  void startAdbWifiButtonClick(BuildContext context) async{
    try{
      if(isStarted == false){
        bool isRooted = await Root.isRooted();
        if(isRooted){

          String internalIP = '';
          for (var interface in await NetworkInterface.list()) {
            for (var addr in interface.addresses) {
              if(addr.address.startsWith('192')){
                internalIP = addr.address;
                break;
              }
            }
          }

          if(internalIP != ''){
            await Root.exec(cmd: "setprop service.adb.tcp.port 5555");
            await Root.exec(cmd: "stop adbd");
            await Root.exec(cmd: "start adbd");

            PreferenceUtils.setString("InternalIP", internalIP);

            setState(() {
              actualButtonOnOffString = "STOP";
              actualButtonColor = Colors.green;
              message = 'On your computer run\nadb connect '+internalIP+':5555';
            });

            if(isSwitched == true){
              PreferenceUtils.setBool("IsSwitched", true);
            }

            isStarted = true;
            PreferenceUtils.setBool("IsStarted", true);

            await methodChannel.invokeMethod("startService");
          }else{
            showSnackBar(context,'Phone is NOT connected');
          }
        }else{
          showSnackBar(context,'Please give the app root permissions');
        }
      }else{

        await Root.exec(cmd: "setprop service.adb.tcp.port -1");
        await Root.exec(cmd: "stop adbd");
        await Root.exec(cmd: "start adbd");

        setState(() {
          actualButtonOnOffString = "START";
          actualButtonColor = Colors.grey;
          message = 'adb wifi STOPPED';
        });

        isStarted = false;
        PreferenceUtils.setBool("IsStarted", false);

        await methodChannel.invokeMethod("stopService");

      }
    }catch(ex){
      showSnackBar(context,'Error: '+ex.toString());
    }
  }

  void showSnackBar(BuildContext context,String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message,), padding: EdgeInsets.only(bottom: 10.0, right: 10.0, left: 10.0, top: 0.0),));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    isSwitched = PreferenceUtils.getBool("IsSwitched", false);
    isStarted = PreferenceUtils.getBool("IsStarted", false);
    internalIP = PreferenceUtils.getString("InternalIP", "");

    if(isStarted == true){
      setState(() {
        actualButtonOnOffString = "STOP";
        actualButtonColor = Colors.green;
        message = 'On your computer run\nadb connect '+internalIP+':5555';
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //appBar: AppBar(title: Text('ADB Wifi'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 0,
                child: Container(
                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                    child: MaterialButton(
                      onPressed: () {
                        startAdbWifiButtonClick(context);
                      },
                      color: actualButtonColor,
                      textColor: Colors.white,
                      child: Text(actualButtonOnOffString),
                      padding: EdgeInsets.all(50),
                      shape: CircleBorder(),
                      elevation: 50.0,
                    )
                )
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Keep Screen ON'),
                    Switch(
                      value: isSwitched,
                      onChanged: (value) async{
                        if(value == true){
                          List<dynamic> data = <dynamic>[];
                          data = await methodChannel.invokeMethod("isWriteSettingsAllowed");
                          if(data[0].toString() == 'true'){
                            isSwitched = value;
                            PreferenceUtils.setBool("IsSwitched", isSwitched);
                          }else{
                            value = !value;
                          }
                        }
                        setState(() {
                          isSwitched = value;
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }

}

