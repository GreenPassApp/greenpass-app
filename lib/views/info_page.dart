import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Information'.tr(),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListElements.listPadding(ListElements.groupText('Legal'.tr())),
              Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
              ListElements.horizontalLine(height: 0.0),
              _linkElement(context, 'Privacy'.tr(), 'https://greenpassapp.eu/privacy'),
              ListElements.horizontalLine(height: 0.0),
              _linkElement(context, 'Imprint'.tr(), 'https://greenpassapp.eu/imprint'),
              ListElements.horizontalLine(height: 0.0),
              _linkElement(context, 'Open Source Licenses'.tr(), 'https://greenpassapp.eu/legal/opensource'),
              Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
              ListElements.listPadding(ListElements.groupText('General information'.tr())),
              Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
              ListElements.horizontalLine(height: 0.0),
              _linkElement(context, 'What can the app do?'.tr(), 'TODO'),
              ListElements.horizontalLine(height: 0.0),
              _linkElement(context, 'FAQ about the app'.tr(), 'TODO'),
              ListElements.horizontalLine(height: 0.0),
              _linkElement(context, 'Country information'.tr(), 'TODO'),
              ListElements.horizontalLine(height: 0.0),
              ListElements.listElement(
                mainText: 'Go through the tutorial again'.tr(),
                action: () => launch('TODO'),
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 15.0)),
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
