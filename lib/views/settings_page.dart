import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/first_app_launch.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:greenpass_app/services/settings.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _travelMode = Settings.getTravelMode();
  bool _hidePassDetails = Settings.getHidePassDetails();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Settings'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            color: Colors.black,
            icon: Icon(FontAwesome5Solid.arrow_left),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListElements.listPadding(ListElements.groupText('Settings'.tr())),
                Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                if (context.locale.languageCode != 'en') ...[
                  ListElements.horizontalLine(height: 0.0),
                  ListElements.checkboxElement(
                    title: 'Travel Mode'.tr(),
                    subtitle: 'All certificate information is displayed in English'.tr(),
                    onChanged: (_) => setState(() => _travelMode = !_travelMode),
                    value: _travelMode,
                  ),
                ],
                ListElements.horizontalLine(height: 0.0),
                ListElements.checkboxElement(
                  title: 'Only show QR code'.tr(),
                  subtitle: 'All detailed information about your certificate will be hidden'.tr(),
                  onChanged: (_) => setState(() => _hidePassDetails = !_hidePassDetails),
                  value: _hidePassDetails,
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
                ListElements.listPadding(ListElements.groupText('General information'.tr())),
                Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                ListElements.horizontalLine(height: 0.0),
                _linkElement(context, 'Visit our website'.tr(), 'https://greenpassapp.eu/'),
                ListElements.horizontalLine(height: 0.0),
                _linkElement(context, 'About the app'.tr(), 'https://greenpassapp.eu/about'),
                ListElements.horizontalLine(height: 0.0),
                ListElements.listElement(
                  mainText: 'Go through the tutorial again'.tr(),
                  action: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FirstAppLaunch.getFirstLaunchScreen(false)),
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
                ListElements.listPadding(ListElements.groupText('Legal'.tr())),
                Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                ListElements.horizontalLine(height: 0.0),
                _linkElement(context, 'Privacy'.tr(), 'https://greenpassapp.eu/privacy'),
                ListElements.horizontalLine(height: 0.0),
                _linkElement(context, 'Imprint'.tr(), 'https://greenpassapp.eu/imprint'),
                ListElements.horizontalLine(height: 0.0),
                _linkElement(context, 'Open Source Licenses'.tr(), 'https://greenpassapp.eu/legal/opensource'),
                Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
                Center(
                  child: FractionallySizedBox(
                    child: Image(image: AssetImage('assets/images/oerk_ooe_logo.png')),
                    widthFactor: 0.5,
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        String version = '...';
                        if (snapshot.hasData)
                          version = (snapshot.data as PackageInfo).version;
                        return Text(
                          'App version: {}'.tr(args: [version]),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: GPColors.dark_grey),
                        );
                      },
                    ),
                  ],
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 15.0)),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        await Settings.setTravelMode(_travelMode);
        await Settings.setHidePassDetails(_hidePassDetails);
        return true;
      },
    );
  }

  static Widget _linkElement(BuildContext context, String name, String url) {
    return ListElements.listElement(
      mainText: name,
      trailing: Icon(
        FontAwesome5Solid.external_link_alt,
        color: Theme.of(context).primaryColor,
        size: 18.0,
      ),
      action: () => launch(url),
    );
  }
}