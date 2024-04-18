import 'package:flutter/material.dart';
import 'package:pedometer_app/models/app_model.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Consumer<AppModel>(builder: (context, appState, child) {
            return Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Daily goal', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: appState.dailyGoal.toString()),
                      onSubmitted: (value) => appState.dailyGoal = int.parse(value),
                ),
              ],
            );
          }),
        ));
  }
}
