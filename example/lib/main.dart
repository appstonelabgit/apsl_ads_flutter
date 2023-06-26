import 'dart:io';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

const IAdIdManager adIdManager = TestAdIdManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApslAds.instance.initialize(
    isShowAppOpenOnAppStateChange: false,
    adIdManager,
    unityTestMode: true,
    adMobAdRequest: const AdRequest(),
    admobConfiguration: RequestConfiguration(testDeviceIds: []),
    fbTestingId: '73f92d66-f8f6-4978-999f-b5e0dd62275a',
    fbTestMode: true,
    showAdBadge: Platform.isIOS,
    fbiOSAdvertiserTrackingEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Easy Ads Example',
      home: HomeScreen(),
    );
  }
}
