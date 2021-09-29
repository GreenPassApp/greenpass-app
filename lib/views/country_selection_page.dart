import 'package:country_codes/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/flag_element.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:greenpass_app/services/country_regulations/regulations_provider.dart';
import 'package:greenpass_app/services/outdated_check.dart';

class CountrySelectionPage extends StatefulWidget {
  const CountrySelectionPage({Key? key}) : super(key: key);

  @override
  _CountrySelectionPageState createState() => _CountrySelectionPageState();
}

class _CountrySelectionPageState extends State<CountrySelectionPage> {
  bool isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Country selection'.tr(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (OutdatedCheck.isOutdated) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: OutdatedCheck.getInfoCard(),
              ),
            ],
            _infoText("Based on your current country selection, your QR codes will be validated according to that country's specifications.".tr()),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
            ListElements.listPadding(
              ListElements.groupText('Current selection'.tr())
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
            ListElements.horizontalLine(height: 0),
            _countryListElement(code: RegulationsProvider.getUserSetting()),

            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
            ListElements.listPadding(
              ListElements.groupText('European Union'.tr())
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
            if (RegulationsProvider.getUserSetting().toLowerCase() != 'eu') ...[
              ListElements.horizontalLine(height: 0),
              _countryListElement(code: 'EU'),
            ],
            for (String c in _countryListOrderedByName()) ...[
              ListElements.horizontalLine(height: 0),
              _countryListElement(code: c),
            ],
            Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
            _infoText('Work is currently underway to add the regulations for all other EU countries!'.tr()),
          ],
        ),
      ),
    );
  }

  static Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 32.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: GPColors.dark_grey,
        ),
      ),
    );
  }

  Widget _countryListElement({required String code, GestureTapCallback? action}) {
    Locale l = Locale.fromSubtags(countryCode: code);
    CountryDetails? c;
    try {
      c = CountryCodes.detailsForLocale(l);
    } catch (_) {
      // stay null
    }

    String name;
    if (c == null)
      name = code.toLowerCase() == 'eu' ? 'European Union'.tr() : 'Unknown'.tr();
    else
      name = c.localizedName!;

    return IgnorePointer(
      ignoring: OutdatedCheck.isOutdated,
      child: Opacity(
        opacity: OutdatedCheck.isOutdated ? 0.5 : 1.0,
        child: ListElements.listElement(
          icon: FlagElement.buildFlag(flag: code),
          mainText: name,
          secondaryText: '(' + code.toUpperCase() + ')',
          action: () async {
            if (!isUpdating) {
              isUpdating = true;
              await RegulationsProvider.setUserSetting(code);
              Navigator.of(context).pop();
            }
          }
        ),
      ),
    );
  }

  static List<String> _countryListOrderedByName() {
    List<String> codes = RegulationsProvider.getCurrentRegulations().keys.toList();
    codes.removeWhere((c) => c == RegulationsProvider.getUserSetting());
    codes.sort((c1, c2) {
      Locale l1 = Locale.fromSubtags(countryCode: c1);
      Locale l2 = Locale.fromSubtags(countryCode: c2);
      CountryDetails? d1;
      CountryDetails? d2;
      try {
        d1 = CountryCodes.detailsForLocale(l1);
      } catch (_) {
        return 1;
      }
      try {
        d2 = CountryCodes.detailsForLocale(l2);
      } catch (_) {
        return -1;
      }
      return d1.localizedName!.compareTo(d2.localizedName!);
    });
    return codes;
  }
}
