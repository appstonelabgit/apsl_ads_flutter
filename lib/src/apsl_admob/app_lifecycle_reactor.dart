// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:apsl_ads_flutter/src/apsl_admob/apsl_admob_app_open_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages the app lifecycle to display app open ads.
/// It listens to app state changes and triggers the ad display whenever
/// the app comes to the foreground.
class AppLifecycleReactor {
  // Reference to the manager handling app open ads for AdMob.
  final ApslAdmobAppOpenAd appOpenAdManager;

  /// Constructs the lifecycle reactor with a provided [appOpenAdManager].
  AppLifecycleReactor({required this.appOpenAdManager});

  /// Initiates the listener for app state changes.
  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  /// Internal handler for app state changes.
  /// Triggers ad display when the app transitions to the foreground.
  void _onAppStateChanged(AppState appState) {
    if (appState == AppState.foreground) {
      appOpenAdManager.show();
    }
  }
}
