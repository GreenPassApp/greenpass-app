import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/connectivity/share_certificate.dart';
import 'package:greenpass_app/connectivity/share_certificate_result.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/local_storage/my_certs/my_cert_share.dart';
import 'package:greenpass_app/local_storage/my_certs/my_certs.dart';
import 'package:greenpass_app/views/share_info_page.dart';

class SharePage extends StatefulWidget {
  final GreenCertificate cert;

  const SharePage({required this.cert, Key? key}) : super(key: key);

  @override
  _SharePageState createState() => _SharePageState(cert);
}

class _SharePageState extends State<SharePage> {
  GreenCertificate cert;
  MyCertShare? share;

  bool selectDate = false;
  bool sendingData = false;
  DateTime selectedTime;
  TextEditingController? _selectedTimeController;

  final DateFormat dFormat = DateFormat('dd.MM.yyyy, HH:mm');

  _SharePageState(this.cert)
    : this.share = MyCerts.getShareInfo(cert.rawData),
      this.selectedTime = cert.expiresAt;

  @override
  void initState() {
    super.initState();

    if (share != null) {
      selectDate = true;
      selectedTime = share!.validUntil;
    }

    this._selectedTimeController = TextEditingController(
      text: dFormat.format(selectedTime)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Share certificate'.tr(),
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
      body: (selectDate ? _selectTimePage() : _noLinkPage()),
    );
  }

  Widget _noLinkPage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No link generated yet'.tr(),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
          Text(
            'When sharing a certificate, the most necessary information is stored on a server for a freely selectable period of time.'.tr(),
            textAlign: TextAlign.center,
          ),
          const Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
          ElevatedButton(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Share certificate'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            onPressed: () => setState(() => selectDate = true),
          ),
        ],
      ),
    );
  }

  Widget _selectTimePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'By when should the shared certificate be available?'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(padding: const EdgeInsets.symmetric(vertical: 22.0)),
                DateTimeField(
                  controller: this._selectedTimeController,
                  readOnly: true,
                  resetIcon: null,
                  enabled: !sendingData,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Date and time'.tr(),
                    errorMaxLines: 8,
                  ),
                  format: dFormat,
                  validator: _validateInput,
                  autovalidateMode: AutovalidateMode.always,
                  onShowPicker: (context, currentValue) async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: cert.expiresAt,
                    );
                    if (date != null) {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                  onChanged: (date) {
                    setState(() {
                      this.selectedTime = date!;
                    });
                  },
                ),
                const Padding(padding: const EdgeInsets.symmetric(vertical: 22.0)),
                if (sendingData) ...[
                  CircularProgressIndicator(),
                ] else ...[
                  ElevatedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        (share == null ? 'Generate link'.tr() : 'Change expiration time'.tr()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    onPressed: _validateInput(selectedTime) != null ? null : () async {
                      if (!sendingData) {
                        setState(() {
                          sendingData = true;
                        });
                        if (share == null)
                          _createLink();
                        else
                          _changeLink();
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createLink() async {
    ShareCertificateResult? res = await ShareCertificate.insert(cert.rawData, selectedTime);
    if (res == null) {
      setState(() {
        sendingData = false;
      });
      PlatformAlertDialog.showAlertDialog(
        context: context,
        title: 'Error'.tr(),
        text: 'An error occurred while generating the share link. Please try again later.'.tr(),
        dismissButtonText: 'Ok'.tr()
      );
    } else {
      MyCertShare share = MyCertShare(
        url: res.url,
        token: res.jwt,
        validUntil: selectedTime,
      );
      await MyCerts.setShareInfo(cert.rawData, share);
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ShareInfoPage(cert: cert)
      ));
    }
  }

  Future<void> _changeLink() async {
    if (await ShareCertificate.update(cert.rawData, selectedTime, share!.token)) {
      MyCertShare newShare = MyCertShare(
        url: share!.url,
        token: share!.token,
        validUntil: selectedTime,
      );
      await MyCerts.setShareInfo(cert.rawData, newShare);
      Navigator.of(context).pop();
    } else {
      setState(() {
        sendingData = false;
      });
      PlatformAlertDialog.showAlertDialog(
        context: context,
        title: 'Error'.tr(),
        text: 'An error occurred while updating the expiration time. Please try again later.'.tr(),
        dismissButtonText: 'Ok'.tr()
      );
    }
  }

  String? _validateInput(DateTime? value) {
    if (value != null) {
      if (value.isBefore(DateTime.now()))
        return 'The selected time must be in the future.'.tr();
      if (value.isAfter(cert.expiresAt))
        return 'The selected time must not be after the expiration date of the certificate. Please select an earlier date!'.tr();
    }
    return null;
  }
}
