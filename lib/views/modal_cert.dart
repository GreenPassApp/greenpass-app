import 'package:country_codes/country_codes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/consts/vibration.dart';
import 'package:greenpass_app/elements/colored_card.dart';
import 'package:greenpass_app/elements/flag_element.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulation_result.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulations_provider.dart';
import 'package:intl/intl.dart';

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

    if (cert.success && RegulationsProvider.getUserSetting() != RegulationsProvider.defaultCountry) {
      RegulationResult res = RegulationsProvider.getUserRegulation().validate(cert.certificate!);
      cardColor = RegulationsProvider.getCardColor(res);
    }

    // there should be no yellow color in the validation process
    if (cardColor == GPColors.yellow) cardColor = GPColors.red;



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
                ColoredCard.buildCard(
                  backgroundColor: cardColor,
                  padding: const EdgeInsets.all(20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
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
                                'Invalid'.tr(),
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
                                    'This QR code is invalid. Please try to scan another one.'.tr(),
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
                ),
                if (cert.success) ...[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesome5Solid.user,
                            size: 30,
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
                        )
                      ),
                      subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(cert.certificate!.personInfo.dateOfBirth),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0
                        )
                      ),
                    ),
                  ),
                ],
                if (cert.success) ...[
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 46.0),
                    child: (RegulationsProvider.getUserSetting() != RegulationsProvider.defaultCountry) ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FlagElement.buildFlag(flag: RegulationsProvider.getUserSetting()),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0)),
                        Flexible(
                          child: Text('Validation according to the regulations in {} (Last update: {})'.tr(args: [
                            CountryCodes.detailsForLocale(Locale.fromSubtags(countryCode: RegulationsProvider.getUserSetting())).localizedName!,
                            DateFormat('dd.MM.yyyy').format(RegulationsProvider.getUserRegulation().validFrom)
                          ]) + '\n' + 'All information without guarantee'.tr(),
                            textAlign: TextAlign.start,
                            style: TextStyle(color: GPColors.dark_grey),
                          ),
                        ),
                      ],
                    )

                    : Text('There is no validation according to country regulations'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: GPColors.dark_grey),
                    ),
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
