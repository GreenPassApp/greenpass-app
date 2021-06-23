import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/colored_card.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/my_certs/my_certs.dart';
import 'package:greenpass_app/my_certs/my_certs_result.dart';
import 'package:greenpass_app/views/pass_details.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'add_my_pass_page.dart';

class MyPassesPage extends StatefulWidget {
  const MyPassesPage({Key? key}) : super(key: key);

  @override
  _MyPassesPageState createState() => _MyPassesPageState();
}

class _MyPassesPageState extends State<MyPassesPage> {
  late PageController controller;
  int currentPage = 0;

  @override
  void initState() {
    controller = PageController(
      initialPage: 0,
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
    return SafeArea(
      child: FutureBuilder(
        future: MyCerts.getGreenCerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done
            && snapshot.hasData
            && snapshot.data != null) {
            MyCertsResult res = snapshot.data as MyCertsResult;

            if (res.invalidCertificatesDeleted != 0)
              Future.delayed(Duration.zero, () =>
                PlatformAlertDialog.showAlertDialog(
                  context: context,
                  title: 'Information',
                  text: res.invalidCertificatesDeleted.toString() + ' certificates were deleted due to their expiration.',
                  dismissButtonText: 'Ok'
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
            'No passes added yet',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
          Text(
            'Add your proof of vaccination, past infection or negative test now!',
            textAlign: TextAlign.center,
          ),
          const Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
          ElevatedButton(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Add QR code',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddMyPassPage()
            )).then((_) => FlutterStatusbarcolor.setStatusBarWhiteForeground(false)),
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
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return ColoredCard.buildCard(
                  padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 65.0),
                  backgroundColor: GPColors.blue,
                  child: InkWell(
                    child: Center(
                      child: child,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PassDetails(cert: certs[idx]))
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          certs[idx].personInfo.fullName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                        Text(
                          DateFormat('dd.MM.yyyy').format(certs[idx].personInfo.dateOfBirth),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10.0)),
                        AspectRatio(
                          aspectRatio: 1,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(const Radius.circular(4.0))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: PrettyQr(
                                      data: certs[idx].rawData,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10.0)),
                        PassInfo.getTypeText(
                          certs[idx],
                          textSize: 25.0,
                          additionalTextSize: 15.0,
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                        Text(
                          PassInfo.getDate(certs[idx]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
                        Text(
                          PassInfo.getDuration(certs[idx]),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
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
}