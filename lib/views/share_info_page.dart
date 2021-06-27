import 'package:clipboard/clipboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/connectivity/share_certificate.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/local_storage/my_certs/my_cert_share.dart';
import 'package:greenpass_app/local_storage/my_certs/my_certs.dart';
import 'package:greenpass_app/views/share_page.dart';
import 'package:share_plus/share_plus.dart';

class ShareInfoPage extends StatefulWidget {
  final GreenCertificate cert;

  const ShareInfoPage({required this.cert, Key? key}) : super(key: key);

  @override
  _ShareInfoPageState createState() => _ShareInfoPageState(cert: cert);
}

class _ShareInfoPageState extends State<ShareInfoPage> {
  final GreenCertificate cert;

  bool isDeleting = false;

  _ShareInfoPageState({required this.cert});

  @override
  Widget build(BuildContext context) {
    MyCertShare share = MyCerts.getShareInfo(cert.rawData)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Shared certificate'.tr(),
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
        actions: [
          IconButton(
            icon: Icon(
              FontAwesome5Solid.share,
              color: Colors.black,
            ),
            onPressed: () => Share.share(share.fullUri, subject: 'GreenPass'),
          ),
          IconButton(
            icon: Icon(
              FontAwesome5Solid.trash_alt,
              color: Colors.black,
            ),
            onPressed: () => _deleteShareLink(context, share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PassInfo.getSmallPassCard(cert),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
              child: Text(
                'When sharing a certificate, the most necessary information is stored on a server for a freely selectable period of time.'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GPColors.dark_grey,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 25.0)),
            ListElements.listPadding(ListElements.groupText('Information about the shared certificate'.tr())),
            Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
            ListElements.horizontalLine(height: 0.0),
            _listElement('Share link'.tr(), share.fullUri, FontAwesome5Solid.copy, () {
              FlutterClipboard.copy(share.fullUri).then((value) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Copied link to clipboard.'.tr()),
                ),
              ));
            }),
            ListElements.horizontalLine(height: 0.0),
            _listElement('Link valid until'.tr(), DateFormat('dd.MM.yyyy, HH:mm').format(share.validUntil), FontAwesome5Solid.edit, () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SharePage(cert: cert)
              )).then((_) => setState(() {}));
            }),
            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(FontAwesome5Solid.trash_alt, size: 18.0),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(GPColors.red),
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0))
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Delete share link'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      onPressed: () => _deleteShareLink(context, share),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listElement(String name, String val, IconData icon, GestureTapCallback? action) {
    return ListElements.listElement(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: GPColors.almost_black,
              fontSize: 12.0,
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            val,
            style: TextStyle(
              color: GPColors.almost_black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: Icon(
        icon,
        color: GPColors.almost_black,
      ),
      action: action,
    );
  }

  void _deleteShareLink(BuildContext context, MyCertShare share) {
    PlatformAlertDialog.showAlertDialog(
      context: context,
      title: 'Delete share link?'.tr(),
      text: 'Are you sure you want to delete the share link? You can create a new link at any time.'.tr(),
      dismissButtonText: 'Cancel'.tr(),
      actionButtonText: 'Delete'.tr(),
      action: () async {
        if (!isDeleting) {
          isDeleting = true;
          if (await ShareCertificate.delete(share.token)) {
            await MyCerts.setShareInfo(cert.rawData, null);
            Navigator.of(context).pop();
          } else {
            PlatformAlertDialog.showAlertDialog(
              context: context,
              title: 'Error'.tr(),
              text: 'An error occurred while deleting the share link. Please try again later.'.tr(),
              dismissButtonText: 'Ok'.tr()
            );
            isDeleting = false;
          }
        }
      },
    );
  }
}