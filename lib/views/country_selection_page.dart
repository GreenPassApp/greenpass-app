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
  Map<String, List<String?>> availableRegions = RegulationsProvider.getAvailableRegions();

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
            _countryListElement(code: RegulationsProvider.getUserSelection().countryCode),

            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
            ListElements.listPadding(
              ListElements.groupText('European Union'.tr())
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
            if (RegulationsProvider.getUserSelection().countryCode.toLowerCase() != 'eu') ...[
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

  Widget _countryListElement({required String code}) {
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
        child: availableRegions.containsKey(code) ? ListElements.expandableListElement(
          context: context,
          icon: FlagElement.buildFlag(flag: code),
          expanded: RegulationsProvider.getUserSelection().countryCode == code,
          mainText: name,
          secondaryText: '(' + code.toUpperCase() + ')',
          children: [
            for (String? subregion in _subregionListOrderedByName(availableRegions[code]!)) ...[
              ListElements.horizontalLine(height: 1),
              ListElements.listElement(
                secondaryText: RegulationsProvider.getSubregionTranslation(subregion, context.locale),
                icon: Icon(null),
                trailing: RegulationsProvider.getUserSelection().countryCode == code && RegulationsProvider.getUserSelection().subregionCode == subregion ? Icon(
                  MaterialIcons.check,
                  color: Theme.of(context).primaryColor,
                ) : null,
                action: () async {
                  await _saveSelection(code, subregion);
                },
              ),
            ],
          ],
        ) : ListElements.listElement(
          icon: FlagElement.buildFlag(flag: code),
          mainText: name,
          secondaryText: '(' + code.toUpperCase() + ')',
          trailing: RegulationsProvider.getUserSelection().countryCode == code ? Icon(
            MaterialIcons.check,
            color: Theme.of(context).primaryColor,
          ) : null,
          action: () async {
            await _saveSelection(code, null);
          },
        ),
      ),
    );
  }

  Future<void> _saveSelection(String countryCode, String? subregion) async {
    if (!isUpdating) {
      isUpdating = true;
      await RegulationsProvider.selectRegion(countryCode, subregion);
      Navigator.of(context).pop();
    }
  }

  List<String?> _subregionListOrderedByName(List<String?> subregions) {
    List<String?> res = List.from(subregions);

    res.sort((r1, r2) {
      if (r1 == null) return -1;
      if (r2 == null) return 1;
      return RegulationsProvider.getSubregionTranslation(r1, context.locale).compareTo(RegulationsProvider.getSubregionTranslation(r2, context.locale));
    });

    return res;
  }

  List<String> _countryListOrderedByName() {
    List<String> codes = availableRegions.keys.toList();
    codes.removeWhere((c) => c == RegulationsProvider.getUserSelection().countryCode);
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
