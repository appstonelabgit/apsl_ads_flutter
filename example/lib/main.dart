import 'dart:async';
import 'dart:io';

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
    fbTestingId: "DB4376A4F649F3EECA878BB77ED7BA08",
    adMobAdRequest: const AdRequest(),
    admobConfiguration: RequestConfiguration(testDeviceIds: []),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Ads"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitleWidget(context, title: 'App Open'),
            AdListTile(
              networkName: 'Admob AppOpen',
              onTap: () => _showAd(AdNetwork.admob, AdUnitType.appOpen),
            ),
            const ApslSequenceNativeAd(templateType: TemplateType.small),
            const Divider(thickness: 2),
            _sectionTitleWidget(context, title: 'Interstitial'),
            AdListTile(
              networkName: 'Admob Interstitial',
              onTap: () => _showAd(AdNetwork.admob, AdUnitType.interstitial),
            ),
            AdListTile(
              networkName: 'Facebook Interstitial',
              onTap: () => _showAd(AdNetwork.facebook, AdUnitType.interstitial),
            ),
            AdListTile(
              networkName: 'Unity Interstitial',
              onTap: () => _showAd(AdNetwork.unity, AdUnitType.interstitial),
            ),
            AdListTile(
              networkName: 'Show Interstitial one by one',
              onTap: () => _showAvailableAd(AdUnitType.interstitial),
            ),
            const Divider(thickness: 2),
            _sectionTitleWidget(context, title: 'Rewarded'),
            AdListTile(
              networkName: 'Admob Rewarded',
              onTap: () => _showAd(AdNetwork.admob, AdUnitType.rewarded),
            ),
            AdListTile(
              networkName: 'Facebook Rewarded',
              onTap: () => _showAd(AdNetwork.facebook, AdUnitType.rewarded),
            ),
            AdListTile(
              networkName: 'Unity Rewarded',
              onTap: () => _showAd(AdNetwork.unity, AdUnitType.rewarded),
            ),
            AdListTile(
              networkName: 'Show Rewarded one by one',
              onTap: () => _showAvailableAd(AdUnitType.rewarded),
            ),
            const ApslSequenceBannerAd(
              priorityAdNetworks: [
                AdNetwork.unity,
                AdNetwork.admob,
                AdNetwork.facebook,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitleWidget(BuildContext context, {String title = ""}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAd(AdNetwork adNetwork, AdUnitType adUnitType) {
    if (ApslAds.instance.showAd(adUnitType,
        adNetwork: adNetwork,
        shouldShowLoader: Platform.isAndroid,
        context: context,
        delayInSeconds: 1)) {
      // Canceling the last callback subscribed
      _streamSubscription?.cancel();
      // Listening to the callback from showRewardedAd()
      _streamSubscription = ApslAds.instance.onEvent.listen((event) {
        if (event.adUnitType == adUnitType) {
          _streamSubscription?.cancel();
          goToNextScreen(adNetwork: adNetwork);
        }
      });
    } else {
      goToNextScreen(adNetwork: adNetwork);
    }
  }

  void _showAvailableAd(AdUnitType adUnitType) {
    if (ApslAds.instance.showAd(adUnitType)) {
      // Canceling the last callback subscribed
      _streamSubscription?.cancel();
      // Listening to the callback from showRewardedAd()
      _streamSubscription = ApslAds.instance.onEvent.listen((event) {
        if (event.adUnitType == adUnitType) {
          _streamSubscription?.cancel();
          goToNextScreen();
        }
      });
    } else {
      goToNextScreen();
    }
  }

  void goToNextScreen({AdNetwork? adNetwork}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(adNetwork: adNetwork),
      ),
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
