import 'dart:async';

import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

const AdsIdManager adIdManager = TestAdsIdManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApslAds.instance.initialize(
    isShowAppOpenOnAppStateChange: true,
    adIdManager,
    unityTestMode: true,
    fbTestMode: true,
    fbTestingId: "334B90C731BDB120067DE02818259A5A",
    adMobAdRequest: const AdRequest(),
    admobConfiguration: RequestConfiguration(
        testDeviceIds: ["334B90C731BDB120067DE02818259A5A"]),
    showAdBadge: false,
    fbiOSAdvertiserTrackingEnabled: true,
    preloadRewardedAds: false,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Apsl Ads Example',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Using it to cancel the subscribed callbacks
  StreamSubscription? _streamSubscription;

  // Builds the UI of the home screen, including the list of ad options.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Ads"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitleWidget(context, title: 'App Open'),
              AdListTile(
                networkName: 'Admob AppOpen',
                onTap: () =>
                    _showAd(AdUnitType.appOpen, adNetwork: AdNetwork.admob),
              ),
              const ApslSequenceNativeAd(templateType: TemplateType.small),
              const Divider(thickness: 2),
              // Interstitial Ads Section
              _sectionTitleWidget(context, title: 'Interstitial'),
              AdListTile(
                networkName: 'Admob Interstitial',
                onTap: () => _showAd(AdUnitType.interstitial,
                    adNetwork: AdNetwork.admob),
              ),
              AdListTile(
                networkName: 'Facebook Interstitial',
                onTap: () => _showAd(AdUnitType.interstitial,
                    adNetwork: AdNetwork.facebook),
              ),
              AdListTile(
                networkName: 'Unity Interstitial',
                onTap: () => _showAd(AdUnitType.interstitial,
                    adNetwork: AdNetwork.unity),
              ),

              AdListTile(
                networkName: 'Show Interstitial one by one',
                onTap: () => _showAd(AdUnitType.interstitial),
              ),
              AdListTile(
                networkName: 'Show on Navigation',
                onTap: () => _showAd(AdUnitType.interstitial, navigate: true),
              ),
              const Divider(thickness: 2),
              // Rewarded Ads Section
              _sectionTitleWidget(context, title: 'Rewarded'),
              AdListTile(
                networkName: 'Admob Rewarded',
                onTap: () =>
                    _loadAndShowRewardedAds(adNetwork: AdNetwork.admob),
              ),
              AdListTile(
                networkName: 'Facebook Rewarded',
                onTap: () =>
                    _loadAndShowRewardedAds(adNetwork: AdNetwork.facebook),
              ),
              AdListTile(
                networkName: 'Unity Rewarded',
                onTap: () =>
                    _loadAndShowRewardedAds(adNetwork: AdNetwork.unity),
              ),

              AdListTile(
                networkName: 'Show Rewarded one by one',
                onTap: () => _loadAndShowRewardedAds(adNetwork: AdNetwork.any),
              ),
              const ApslSequenceBannerAd(
                orderOfAdNetworks: [
                  AdNetwork.admob,
                  AdNetwork.unity,
                  AdNetwork.facebook,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Creates a ListTile widget with a title indicating the section of ads.
  Widget _sectionTitleWidget(BuildContext context, {String title = ""}) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Attempts to show an ad from the specified ad network and ad unit type.
  // If the ad is successfully shown, navigates to the next screen.
  void _showAd(
    AdUnitType adUnitType, {
    AdNetwork adNetwork = AdNetwork.any,
    bool navigate = false,
  }) {
    if (ApslAds.instance.showAd(adUnitType, adNetwork: adNetwork)) {
      if (navigate) {
        // Canceling the last callback subscribed
        _streamSubscription?.cancel();
        // Listening to the callback from showRewardedAd()
        _streamSubscription = ApslAds.instance.onEvent.listen((event) {
          if (event.adUnitType == adUnitType) {
            _streamSubscription?.cancel();
            _goToNextScreen(adNetwork: adNetwork);
          }
        });
      }
    } else {
      if (navigate) _goToNextScreen(adNetwork: adNetwork);
    }
  }

  void _loadAndShowRewardedAds({required AdNetwork adNetwork}) {
    ApslAds.instance.loadAndShowRewardedAd(
      context: context,
      adNetwork: adNetwork,
    );

    _streamSubscription?.cancel();
    _streamSubscription = ApslAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.rewarded) {
        if (event.type == AdEventType.adDismissed) {
        } else if (event.type == AdEventType.adFailedToShow) {
          _showCustomDialog(
            context,
            title: "Ads not available",
            description: "Please try again later.",
          );
        } else if (event.type == AdEventType.earnedReward) {
          _showCustomDialog(
            context,
            title: "Congratulations",
            description: "You earned rewards",
          );
        }
      }
    });
  }

  void _goToNextScreen({AdNetwork? adNetwork}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(adNetwork: adNetwork),
      ),
    );
  }

  void _showCustomDialog(BuildContext context,
      {required String title, required String description}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description),
                // Add more Widgets if needed.
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DetailScreen extends StatefulWidget {
  final AdNetwork? adNetwork;
  const DetailScreen({super.key, this.adNetwork = AdNetwork.admob});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://support.google.com/admob/answer/9234653?hl=en#:~:text=AdMob%20is%20a%20mobile%20ad,helping%20you%20serve%20ads%20globally."));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ApslAds Example")),
      body: WebViewWidget(
        controller: _webViewController,
      ),
    );
  }
}

class AdListTile extends StatelessWidget {
  final String networkName;
  final VoidCallback onTap;
  const AdListTile({super.key, required this.networkName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        networkName,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
