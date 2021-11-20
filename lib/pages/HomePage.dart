import 'dart:io';
import 'dart:ui';
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
  String message = 'adb wifi STOPPED';

  Color buttonOnColor = Colors.teal.shade700;
  Color buttonOffColor = Colors.blueGrey.shade300;
  Color actualButtonColor = Colors.blueGrey.shade300;

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
              actualButtonColor = buttonOnColor;
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
          actualButtonColor = buttonOffColor;
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
        actualButtonColor = buttonOnColor;
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
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(actualButtonColor),
                      padding: MaterialStateProperty.all(EdgeInsets.all(40)),
                      shape: MaterialStateProperty.all(CircleBorder()),
                      elevation: MaterialStateProperty.all(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0,0,0,10),
                              child: Icon(
                                Icons.power_settings_new,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            Text(
                              actualButtonOnOffString,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onPressed: () { startAdbWifiButtonClick(context); },
                  ),
                ),
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Keep Screen ON', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54),),
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
                      activeTrackColor: Colors.teal.shade200,
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(message, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54),),
            ),
          ],
        ),
      ),
    );
  }

}

