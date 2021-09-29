import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:greenpass_app/services/update_check/android_update_check_result.dart';
import 'package:greenpass_app/services/update_check/update_check.dart';
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateNotification extends StatefulWidget {
  const UpdateNotification({Key? key}) : super(key: key);

  @override
  _UpdateNotificationState createState() => _UpdateNotificationState();
}

class _UpdateNotificationState extends State<UpdateNotification> {
  bool _updating = false;
  double _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    AndroidUpdateCheckResult updateRes = UpdateCheck.androidUpdateCheckResult!;

    String? changelog;
    if (updateRes.changelog != null) {
      if (updateRes.changelog!.containsKey(context.locale.languageCode))
        changelog = updateRes.changelog![context.locale.languageCode];
      else if (updateRes.changelog!.containsKey(context.fallbackLocale?.languageCode))
        changelog = updateRes.changelog![context.fallbackLocale!.languageCode];
    }

    return WillPopScope(
      onWillPop: () async { return !_updating; },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Update available'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: _updating ? Container() : IconButton(
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
                if (_updating) ...[
                  ListElements.listPadding(
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Downloading...'.tr()),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0)),
                        SizedBox(
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                          width: 10.0,
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                  ListElements.listPadding(
                    LinearProgressIndicator(
                      backgroundColor: GPColors.light_grey,
                      value: _downloadProgress,
                    ),
                  ),
                ] else ...[
                  ListElements.listPadding(
                    Text(
                      'A new version of the app is available. Would you like to update now?'.tr(),
                      style: TextStyle(
                        color: GPColors.green,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  ListElements.listPadding(
                    Text(
                      'New version: {} (Last update: {})'.tr(args: [updateRes.newestVersion, DateFormat('dd.MM.yyyy').format(updateRes.updatedAt)]),
                      style: TextStyle(color: GPColors.dark_grey),
                    ),
                  ),
                  if (changelog != null) ...[
                    Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
                    ListElements.listPadding(
                      Text(
                        changelog,
                        style: TextStyle(color: GPColors.almost_black),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: _updating ? null : IntrinsicHeight(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        'Visit our website if you want to update manually'.tr(),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => launch('https://greenpassapp.eu/'),
                    ),
                  ),
                ],
              ),
              IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: GPColors.light_grey,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(),
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: Text('Not now'.tr()),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      VerticalDivider(width: 0.0),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(),
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: Text(
                            'Download update'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            setState(() {
                              _downloadProgress = 0.0;
                              _updating = true;
                              try {
                                OtaUpdate().execute(
                                  updateRes.downloadUrl,
                                  destinationFilename: 'GreenPass_Update_v' + updateRes.newestVersion.replaceAll('.', '_') + '.apk',
                                  sha256checksum: updateRes.sha256Checksum,
                                ).listen(
                                  (OtaEvent event) {
                                    if (event.status == OtaStatus.DOWNLOADING) {
                                      try {
                                        setState(() => _downloadProgress = double.parse(event.value!) / 100.0);
                                      } catch (_) {
                                        // Do nothing
                                      }
                                    } else if (event.status != OtaStatus.INSTALLING) {
                                      // Must be an error
                                      setState(() {
                                        _updating = false;
                                        _showError();
                                      });
                                    }
                                  },
                                );
                              } catch (_) {
                                setState(() {
                                  _updating = false;
                                  _showError();
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred while downloading the update. Please try again later.'.tr()),
      ),
    );
  }
}
