import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:greenpass_app/services/country_regulations/regulation_ruleset.dart';
import 'package:greenpass_app/services/country_regulations/regulation_selection.dart';
import 'package:greenpass_app/services/country_regulations/regulations_provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RuleSelectionModal extends StatefulWidget {
  const RuleSelectionModal({Key? key}) : super(key: key);

  @override
  _RuleSelectionModalState createState() => _RuleSelectionModalState();
}

class _RuleSelectionModalState extends State<RuleSelectionModal> {
  bool isUpdating = false;

  @override
  Widget build(BuildContext context) {
    RegulationSelection sel = RegulationsProvider.getUserSelection();
    Map<String, RegulationRuleset> availableRules = RegulationsProvider.getAvailableRules(sel.countryCode, sel.subregionCode);

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: Text('Purpose of use'.tr()),
        ),
        child: SafeArea(
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              controller: ModalScrollController.of(context),
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 32.0),
                    child: Text(
                      'Based on the purpose of use selection, all QR codes will be validated according to the current regulations.'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: GPColors.dark_grey,
                      ),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                  for (String r in availableRules.keys) ...[
                    ListElements.horizontalLine(height: 0),
                    _ruleElement(context: context, rule: r),
                  ],
                  Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ruleElement({required BuildContext context, required String rule}) {
    RegulationSelection sel = RegulationsProvider.getUserSelection();

    return Material(
      child: ListElements.listElement(
        mainText: RegulationsProvider.getRuleTranslation(rule, context.locale),
        trailing: sel.rule == rule ? Icon(
          MaterialIcons.check,
          color: Theme.of(context).primaryColor,
        ) : null,
        action: () async {
          await _saveSelection(context, rule);
        },
      ),
    );
  }

  Future<void> _saveSelection(BuildContext context, String rule) async {
    if (!isUpdating) {
      isUpdating = true;
      await RegulationsProvider.selectRule(rule);
      Navigator.of(context).pop();
    }
  }
}