import 'package:flutter/material.dart';
import 'package:pedometer_app/features/settings_page/settings_page.dart';
import 'package:pedometer_app/models/app_model.dart';
import 'package:pedometer_app/services/shared_preferences_service.dart';
import 'package:pedometer_app/services/steps_counter_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late bool paused;
  late int steps;
  late Duration duration;

  bool loadingAppState = true;
  bool loadingPreferences = true;

  final double averageStepDistance = 0.0007;

  late final StepCounterService stepCounterService;

  Future<void> initData() async {
    var preferences = await SharedPreferencesService.getInstance();
    paused = preferences.paused;
    steps = preferences.steps;
    duration = preferences.duration;
  }

  @override
  void initState() {
    super.initState();

    Provider.of<AppModel>(context, listen: false)
        .loadFromPrefs()
        .then((value) => setState(() {
              loadingAppState = false;
            }));
    initData().then((value) => setState(() {
          loadingPreferences = false;
        }));

    Permission.activityRecognition.request().then((status) {
      if (status.isGranted) {
        stepCounterService = StepCounterService();
        stepCounterService.stepsStream.listen((streamRecord) {
          setState(() {
            steps = streamRecord.$1;
            duration = streamRecord.$2;
          });
        });
      }
    });
  }

  void onStepsStreamControlPressed() async {
    var preferences = await SharedPreferencesService.getInstance();
    setState(() {
      paused = !paused;
    });
    preferences.paused = paused;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void onSettingsActionPressed() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
    }

    return (loadingAppState || loadingPreferences)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Material Pedometer'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: onSettingsActionPressed,
                )
              ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(10),
                child: Consumer<AppModel>(
                  builder: (context, appState, child) {
                    final progress = steps / appState.dailyGoal;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$steps of ${appState.dailyGoal} steps',
                            style: theme.textTheme.headlineMedium),
                        LinearProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          borderRadius:
                              const BorderRadius.all(Radius.elliptical(5, 5)),
                          minHeight: 20,
                        ),
                        Text(
                            '${(averageStepDistance * steps).toStringAsFixed(2)} km',
                            style: theme.textTheme.headlineSmall),
                        Text(duration.toString())
                      ],
                    );
                  },
                )),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: onStepsStreamControlPressed,
              label: Text(paused == false ? 'Pause' : 'Start'),
              icon: Icon(paused == false ? Icons.pause : Icons.play_arrow),
            ),
          );
  }
}
