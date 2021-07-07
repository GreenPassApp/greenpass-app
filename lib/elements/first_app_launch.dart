import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:greenpass_app/connectivity/detect_country.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulations_provider.dart';
import 'package:greenpass_app/main.dart';
import 'package:greenpass_app/views/country_selection_page.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;

class FirstAppLaunch {
  static const String _firstAppLaunchKey = 'is_first_app_launch';
  static const String _tutorialPicsPrefix = 'assets/images/tutorial/';

  static Future<bool> isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_firstAppLaunchKey);
  }

  static Future<void> setFirstLaunchFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstAppLaunchKey, true);
  }

  static Widget getFirstLaunchScreen(bool isFirstLaunch) {
    bool accepted = false;

    return StatefulBuilder(
      builder: (context, setState) => IntroductionScreen(
        pages: [
          _getPageViewModel('Welcome!'.tr(), 'Glad to have you here! First click on **"Add QR code"** on the home screen'.tr(), 'tutorial-1-addqr.png'),
          _getPageViewModel('Scan your certificate'.tr(), '**Scan the QR code** of your proof of vaccination, past infection or negative test'.tr(), 'tutorial-2-scan.png'),
          _getPageViewModel('All information at a glance'.tr(), '**Click on your pass** to get to the detailed information of your certificate'.tr(), 'tutorial-3-show.png'),
          _getPageViewModel("Validate other people's certificates".tr(), 'Select **"Check Pass"** from the menu to validate QR codes from other people'.tr(), 'tutorial-5-validate.png'),
          if (isFirstLaunch) ...[
            PageViewModel(
              title: 'Privacy policy'.tr(),
              bodyWidget: Center(
                child:  MarkdownBody(
                  onTapLink: (text, href, title) => launch('https://greenpassapp.eu/privacy'),
                  data: 'Your data is only stored and processed **locally and offline on your device** and will be deleted when you uninstall the app.'.tr() + '\n\n'
                      + _getFeaturesText()
                      + 'All further information can be found in the [privacy policy]().'.tr(),
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(fontSize: 16.0),
                    a: TextStyle(color: Theme.of(context).primaryColor),
                    blockSpacing: 20.0,
                  ),
                ),
              ),
              footer: CheckboxListTile(
                title: Text('I accept the privacy policy'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (_) => setState(() => accepted = !accepted),
                value: accepted,
              ),
              decoration: PageDecoration(
                  bodyAlignment: Alignment.center,
                  descriptionPadding: const EdgeInsets.all(30.0),
                  titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ],
        next: Text('Next'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
        done: Text('Done'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
        skip: Text('Skip'.tr()),
        showSkipButton: true,
        dotsDecorator: DotsDecorator(
          activeColor: Theme.of(context).primaryColor
        ),
        showDoneButton: accepted || !isFirstLaunch,
        onDone: () async {
          if (isFirstLaunch) {
            await FirstAppLaunch.setFirstLaunchFlag();
            String? countryCode = DetectCountry.countryCode;
            if (countryCode == null || !RegulationsProvider.getCurrentRegulations().containsKey(countryCode)) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => MyHomePage()
              ));
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CountrySelectionPage()
              ));
            } else {
              await RegulationsProvider.setUserSetting(countryCode);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => MyHomePage()
              ));
            }
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  static PageViewModel _getPageViewModel(String title, String text, String imageName) {
    return PageViewModel(
      title: title,
      bodyWidget: Center(
        child: Image(image: AssetImage(_tutorialPicsPrefix + imageName)),
      ),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(
            textAlign: WrapAlignment.center,
            p: TextStyle(fontSize: 16.0)
          ),
        ),
      ),
      decoration: PageDecoration(
        bodyAlignment: Alignment.center,
        descriptionPadding: const EdgeInsets.all(60.0),
        titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)
      ),
    );
  }

  static String _getFeaturesText() {
    if (Platform.isIOS)
      return 'When using the **Apple Wallet** feature, personal data is stored and processed online for the shortest possible period of time. Of course, you will be informed about this in the app before using this feature.'.tr() + '\n\n';
    return '';
  }
}