import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/consts/vibration.dart';
import 'package:greenpass_app/elements/colored_card.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:greenpass_app/services/country_regulations/regulation_result.dart';
import 'package:greenpass_app/services/country_regulations/regulations_provider.dart';
import 'package:greenpass_app/services/settings.dart';
import 'package:intl/intl.dart';

import '../green_validator/model/validation_error_code.dart';

class ModalCert extends StatelessWidget {
  final ValidationResult cert;

  ModalCert({Key? key, required this.cert}) : super(key: key) {
    if (cert.success)
      GPVibration.success();
    else
      GPVibration.error();
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = cert.success ? GPColors.blue : GPColors.red;

    RegulationResult? res;
    if (cert.success && RegulationsProvider.useColorValidation()) {
      res = RegulationsProvider.getSelectedRuleset()!.validate(cert.certificate!);
      cardColor = RegulationsProvider.getCardColor(res);
    }

    // there should be no yellow color in the validation process
    if (cardColor == GPColors.yellow) cardColor = GPColors.red;

    Widget? validationNoticeWidget;
    if (cert.success) {
      if (RegulationsProvider.useColorValidation()) {
        validationNoticeWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: PassInfo.getCurrentRegulationInfo(context, travelMode: Settings.getTravelMode()),
            ),
          ],
        );
      } else {
        validationNoticeWidget = Text('There is no validation according to country regulations'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(color: GPColors.dark_grey, fontSize: 12.0),
        );
      }
    }

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: Text('Certificate'.tr()),
        ),
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
              children: [
                Padding(padding: const EdgeInsets.only(top: 16.0),),
                ColoredCard.buildCard(
                  backgroundColor: cardColor,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      if (RegulationsProvider.useColorValidation()) ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                            color: Colors.white24,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 26.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    child: Text(
                                      RegulationsProvider.getRuleTranslation(RegulationsProvider.getUserSelection().rule, context.locale).toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ColoredCard.buildIcon(
                              icon: cardColor == GPColors.red ? FontAwesome5Solid.times
                                  : (cardColor == GPColors.green ? FontAwesome5Solid.check : ColoredCard.getValidationIcon(cert))
                            ),
                          ),
                        ],
                      ),
                      if (cert.success) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            PassInfo.getTypeText(cert.certificate!),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              PassInfo.getDate(cert.certificate!),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(35.0),
                              child: Text(
                                PassInfo.getDuration(cert.certificate!),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              cert.errorCode == ValidationErrorCode.certificate_expired
                              ? 'Expired'.tr()
                              : 'Invalid'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  cert.errorCode == ValidationErrorCode.certificate_expired
                                  ? 'This certificate has expired. Please try to scan another one.'.tr()
                                  : 'This QR code is invalid. Please try to scan another one.'.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (cert.success) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesome5Solid.user,
                            size: 28.0,
                            color: GPColors.almost_black,
                          ),
                        ],
                      ),
                      title: Text(
                        cert.certificate!.personInfo.fullName,
                        style: TextStyle(
                          color: GPColors.almost_black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(cert.certificate!.personInfo.dateOfBirth),
                        style: TextStyle(
                          color: GPColors.dark_grey,
                          fontSize: 15.0
                        ),
                      ),
                    ),
                  ),
                  if (RegulationsProvider.useColorValidation() && res!.currentlyValid) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: PassInfo.getCalculatedRegulationResult(res),
                    ),
                  ],
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                    child: validationNoticeWidget,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
