import 'dart:io';

import 'package:country_codes/country_codes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/configuration.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/services/detect_country.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/add_qr_code.dart';
import 'package:greenpass_app/elements/first_app_launch.dart';
import 'package:greenpass_app/elements/flag_element.dart';
import 'package:greenpass_app/services/country_regulations/regulations_provider.dart';
import 'package:greenpass_app/services/my_certs/my_certs.dart';
import 'package:greenpass_app/services/outdated_check.dart';
import 'package:greenpass_app/services/pub_certs/pub_certs.dart';
import 'package:greenpass_app/services/settings.dart';
import 'package:greenpass_app/services/update_check/update_check.dart';
import 'package:greenpass_app/views/country_selection_page.dart';
import 'package:greenpass_app/views/settings_page.dart';
import 'package:greenpass_app/views/my_passes_page.dart';
import 'package:greenpass_app/views/scan_others_pass.dart';
import 'package:greenpass_app/views/update_notification.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Hive.initFlutter(),
    OutdatedCheck.initAppStart(),
    CountryCodes.init(),
    PubCerts.initAppStart(),
    RegulationsProvider.initAppStart(),
    MyCerts.initAppStart(),
    Settings.initAppStart(),
    EasyLocalization.ensureInitialized(),
  ]);
  if (Platform.isAndroid && kReleaseMode && Configuration.enable_android_updater) UpdateCheck.initAppStart();
  DetectCountry.getCountryCode();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('de')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: App(await FirstAppLaunch.isFirstLaunch())
    )
  );
}

class App extends StatelessWidget {
  final bool firstAppLaunch;

  App(this.firstAppLaunch);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: MaterialApp(
        title: 'GreenPass',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: GPColors.dark_statusbar_style,
          ),
          primarySwatch: GPColors.createMaterialColor(GPColors.green),
          fontFamily: 'Inter',
        ),
        home: firstAppLaunch ? FirstAppLaunch.getFirstLaunchScreen(true) : MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  int _currentPageIdx = 0;
  static const int _pageCount = 2;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pageCount, vsync: this);
    _tabController.addListener(() {
      setState(() { _currentPageIdx = _tabController.index; });
    });

    _tabController.animation!.addListener(() {
      int roundedIdx = _tabController.animation!.value.round();
      if (_currentPageIdx != roundedIdx) {
        setState(() { _currentPageIdx = roundedIdx; });
      }
    });

    if (OutdatedCheck.isOutdated) {
      Future.delayed(Duration.zero, () =>
          PlatformAlertDialog.showAlertDialog(
            context: context,
            title: 'Outdated app version'.tr(),
            text: "Your app version is outdated, so certificate checking and color validation have been disabled. To re-enable these features, you need to update the app.".tr(),
            dismissButtonText: 'Ok'.tr()
          )
      );
    }

    if (UpdateCheck.updateCheck != null) {
      UpdateCheck.updateCheck!.then((res) {
        if (res != null && res.updateAvailable) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => UpdateNotification(androidUpdateCheckResult: res)
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _tabPages = [
      MyPassesPage(),
      ScanOthersPassView(context: context),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'GreenPass',
          style: TextStyle(
            color: _currentPageIdx == 0 ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: _getCountryButton(),
        systemOverlayStyle: _currentPageIdx == 0 ? GPColors.dark_statusbar_style : GPColors.light_statusbar_style,
        actions: [
          /*IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Information',
            color: _currentPageIdx == 0 ? Colors.black : Colors.white,
            onPressed: () async {
              //var encodedCert = Uri.encodeFull("NCFTW2H:7*I06R3W/J:O6:P4QB3+7RKFVJWV66UBCE//UXDT:*ML-4D.NBXR+SRHMNIY6EB8I595+6UY9-+0DPIO6C5%0SBHN-OWKCJ6BLC2M.M/NPKZ4F3WNHEIE6IO26LB8:F4:JVUGVY8*EKCLQ..QCSTS+F\$:0PON:.MND4Z0I9:GU.LBJQ7/2IJPR:PAJFO80NN0TRO1IB:44:N2336-:KC6M*2N*41C42CA5KCD555O/A46F6ST1JJ9D0:.MMLH2/G9A7ZX4DCL*010LGDFI\$MUD82QXSVH6R.CLIL:T4Q3129HXB8WZI8RASDE1LL9:9NQDC/O3X3G+A:2U5VP:IE+EMG40R53CG9J3JE1KB KJA5*\$4GW54%LJBIWKE*HBX+4MNEIAD\$3NR E228Z9SS4E R3HUMH3J%-B6DRO3T7GJBU6O URY858P0TR8MDJ\$6VL8+7B5\$G CIKIPS2CPVDK%K6+N0GUG+TG+RB5JGOU55HXDR.TL-N75Y0NHQTZ3XNQMTF/ZHYBQ\$8IR9MIQHOSV%9K5-7%ZQ/.15I0*-J8AVD0N0/0USH.3");
              var cert = "NCFTW2H%3A7*I06R3W%2FJ%3AO6%3AP4QB3%2B7RKFVJWV66UBCE%2F%2FUXDT%3A*ML-4D.NBXR%2BSRHMNIY6EB8I595%2B6UY9-%2B0DPIO6C5%250SBHN-OWKCJ6BLC2M.M%2FNPKZ4F3WNHEIE6IO26LB8%3AF4%3AJVUGVY8*EKCLQ..QCSTS%2BF%24%3A0PON%3A.MND4Z0I9%3AGU.LBJQ7%2F2IJPR%3APAJFO80NN0TRO1IB%3A44%3AN2336-%3AKC6M*2N*41C42CA5KCD555O%2FA46F6ST1JJ9D0%3A.MMLH2%2FG9A7ZX4DCL*010LGDFI%24MUD82QXSVH6R.CLIL%3AT4Q3129HXB8WZI8RASDE1LL9%3A9NQDC%2FO3X3G%2BA%3A2U5VP%3AIE%2BEMG40R53CG9J3JE1KB%20KJA5*%244GW54%25LJBIWKE*HBX%2B4MNEIAD%243NR%20E228Z9SS4E%20R3HUMH3J%25-B6DRO3T7GJBU6O%20URY858P0TR8MDJ%246VL8%2B7B5%24G%20CIKIPS2CPVDK%25K6%2BN0GUG%2BTG%2BRB5JGOU55HXDR.TL-N75Y0NHQTZ3XNQMTF%2FZHYBQ%248IR9MIQHOSV%259K5-7%25ZQ%2F.15I0*-J8AVD0N0%2F0USH.3";
              await _pkPassDownload(url:"http://localhost:8081/api/user/pass?cert=$cert");
              //_addPassIntoWallet();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hello there!')));
            },
          ),*/

          if (_currentPageIdx == 0) ...[
            IconButton(
              icon: const Icon(FontAwesome5Solid.plus),
              color: Colors.black,
              onPressed: () => AddQrCode.openDialog(context).then((_) => setState(() {})),
            ),
          ],
          IconButton(
            icon: Icon(
              FontAwesome5Solid.ellipsis_v,
              color: _currentPageIdx == 0 ? Colors.black : Colors.white,
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => SettingsPage()
            )),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _tabPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIdx,
        onTap: (newIdx) {
          _tabController.animateTo(newIdx);
        },
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(FontAwesome5Solid.file_alt),
            ),
            label: 'Show Pass'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(FontAwesome5Solid.qrcode),
            ),
            label: 'Check Pass'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _getCountryButton() {

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: FlagElement.buildFlag(flag: RegulationsProvider.getUserSetting()),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CountrySelectionPage()
          )),
        ),
        if (OutdatedCheck.isOutdated) ...[
          Positioned(
            bottom: 10.0,
            right: 4.0,
            child: IgnorePointer(
              child: Icon(
                FontAwesome5Solid.exclamation_triangle,
                color: GPColors.yellow,
                size: 20.0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
