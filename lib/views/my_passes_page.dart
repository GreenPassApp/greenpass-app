import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/add_qr_code.dart';
import 'package:greenpass_app/elements/colored_card.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/services/country_regulations/regulation_result.dart';
import 'package:greenpass_app/services/country_regulations/regulations_provider.dart';
import 'package:greenpass_app/services/my_certs/my_certs.dart';
import 'package:greenpass_app/services/my_certs/my_certs_result.dart';
import 'package:greenpass_app/services/settings.dart';
import 'package:greenpass_app/views/pass_details.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math';


class MyPassesPage extends StatefulWidget {
  const MyPassesPage({Key? key}) : super(key: key);

  @override
  _MyPassesPageState createState() => _MyPassesPageState();
}

class _MyPassesPageState extends State<MyPassesPage> with AutomaticKeepAliveClientMixin<MyPassesPage> {
  late PageController controller;
  int currentPage = 0;

  @override
  void initState() {
    controller = PageController(
      initialPage: currentPage,
      viewportFraction: 0.9,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: FutureBuilder(
        future: MyCerts.getGreenCerts(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            MyCertsResult res = snapshot.data as MyCertsResult;

            if (res.invalidCertificatesDeleted != 0)
              Future.delayed(Duration.zero, () =>
                PlatformAlertDialog.showAlertDialog(
                  context: context,
                  title: 'Information'.tr(),
                  text:  '{} certificates were deleted due to their expiration.'.tr(args: [res.invalidCertificatesDeleted.toString()]),
                  dismissButtonText: 'Ok'.tr()
                )
              );

            if (res.certificates.isEmpty)
              return _noCertsPage();
            else
              return _certsPage(res.certificates, controller);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      ),
    );
  }

  Widget _noCertsPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No passes added yet'.tr(),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
          Text(
            'Add your proof of vaccination, past infection or negative test now!'.tr(),
            textAlign: TextAlign.center,
          ),
          const Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
          ElevatedButton(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Add QR code'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            onPressed: () => AddQrCode.openDialog(context).then((_) => setState(() {})),
          ),
        ],
      ),
    );
  }

  Widget _certsPage(List<GreenCertificate> certs, PageController controller) {
    controller = PageController(
      initialPage: (currentPage >= certs.length ? (certs.length - 1) : currentPage),
      viewportFraction: 0.9,
    );
    return Stack(
      children: [
        PageView.builder(
          controller: controller,
          onPageChanged: (val) {
            currentPage = val;
          },
          itemCount: certs.length,
          itemBuilder: (context, idx) {
            Color cardColor = GPColors.blue;
            Color textColor = Colors.white;
            RegulationResult? regRes;
            if (!RegulationsProvider.useDefaultCountry()) {
              regRes = RegulationsProvider.getUserRegulation().validate(certs[idx]);
              cardColor = RegulationsProvider.getCardColor(regRes);
              textColor = RegulationsProvider.getCardTextColor(regRes);
            }

            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return ColoredCard.buildCard(
                  padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 45.0),
                  backgroundColor: cardColor,
                  child: InkWell(
                    child: child,
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PassDetails(cert: certs[idx]))
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints.tightFor(height: max(380, constraints.maxHeight)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      certs[idx].personInfo.fullName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                                  FittedBox(
                                    child: Text(
                                      DateFormat('dd.MM.yyyy').format(certs[idx].personInfo.dateOfBirth),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                  if (Settings.getHidePassDetails()) ...[
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
                                  ] else ...[
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 10.0)),
                                  ],
                                  Flexible(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(const Radius.circular(4.0)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: PrettyQr(
                                                  data: certs[idx].rawData,
                                                  errorCorrectLevel: QrErrorCorrectLevel.L,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (Settings.getHidePassDetails()) ...[
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
                                  ] else ...[
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 10.0)),
                                  ],
                                  FittedBox(
                                    child: PassInfo.getTypeText(
                                      certs[idx],
                                      textSize: 25.0,
                                      additionalTextSize: 15.0,
                                      color: textColor,
                                      regulationResult: regRes,
                                      hideDetails: Settings.getHidePassDetails(),
                                      travelMode: Settings.getTravelMode(),
                                    ),
                                  ),
                                  if (!Settings.getHidePassDetails()) ...[
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                                    FittedBox(
                                      child: Text(
                                        PassInfo.getDate(certs[idx], travelMode: Settings.getTravelMode()),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
                                    FittedBox(
                                      child: Text(
                                        PassInfo.getDuration(certs[idx], travelMode: Settings.getTravelMode()),
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
                      color: Colors.white24,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 26.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesome5Solid.info_circle,
                            color: textColor,
                            size: 16.0,
                          ),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0)),
                          Flexible(
                            child: FittedBox(
                              child: Text(
                                Settings.translateTravelMode('Only valid with official photo identification', travelMode: Settings.getTravelMode()) +
                                    (!RegulationsProvider.useDefaultCountry() ? '\n' + Settings.translateTravelMode('Color validation without guarantee', travelMode: Settings.getTravelMode()) : ''),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SmoothPageIndicator(
              controller: controller,
              count: certs.length,
              effect: WormEffect(
                dotWidth: 10.0,
                dotHeight: 10.0,
                activeDotColor: GPColors.dark_grey,
                dotColor: GPColors.light_grey
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}