import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/services/my_certs/my_cert.dart';
import 'package:greenpass_app/services/my_certs/my_certs.dart';

class SortPasses extends StatefulWidget {
  final List<GreenCertificate> certs;

  const SortPasses({Key? key, required this.certs}) : super(key: key);

  @override
  _SortPassesState createState() => _SortPassesState(certs: certs);
}

class _SortPassesState extends State<SortPasses> {
  final List<GreenCertificate> certs;

  _SortPassesState({required this.certs});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await MyCerts.setCertList([
          for (GreenCertificate cert in certs)
            MyCert(qrCode: cert.rawData)
        ]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Sort passes'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              FontAwesome5Solid.arrow_left,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: IgnorePointer(
          ignoring: certs.length <= 1,
          child: ReorderableListView(
            header: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 32.0),
                    child: Text(
                      'Press and hold a certificate in this list to move it'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: GPColors.dark_grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            children: [
              for (int i = 0; i < certs.length; i++) ...[
                Container(
                  key: Key(i.toString()),
                  child: PassInfo.getSmallSortCard(i, certs[i]),
                ),
              ],
            ],
            onReorder: (int oldIdx, int newIdx) {
              setState(() {
                if (oldIdx < newIdx) {
                  newIdx -= 1;
                }
                GreenCertificate cert = certs.removeAt(oldIdx);
                certs.insert(newIdx, cert);
              });
            },
          ),
        ),
      ),
    );
  }
}
