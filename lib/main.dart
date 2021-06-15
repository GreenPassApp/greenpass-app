import 'package:country_codes/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/views/demo_page.dart';
import 'package:greenpass_app/views/qr_code_scanner.dart';
import 'package:pass_flutter/pass_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CountryCodes.init();
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
      ),
      home: MyHomePage(title: 'EU green certificate Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  List<Widget> _tabPages = [
    DemoPage(),
    QRCodeScanner(),
  ];
  int _currentPageIdx = 0;

  late TabController _tabController;
  static const platform = const MethodChannel('eu.greenpassapp.wallet');

  Future<void> _addPassIntoWallet() async {
    String batteryLevel;
    try {
      var result = await platform.invokeMethod('addPassIntoWallet', {"uri": "https://jakobstadlhuber.com/test2.pkpass"});
      batteryLevel = 'Success $result % .';
      print(batteryLevel);
    } on PlatformException catch (e) {
      batteryLevel = "Failed to add pass: '${e.message}'.";
    }

  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabPages.length, vsync: this);
    _tabController.addListener(() {
      setState(() { _currentPageIdx = _tabController.index; });
    });

    _tabController.animation!.addListener(() {
      int roundedIdx = _tabController.animation!.value.round();
      if (_currentPageIdx != roundedIdx)
        setState(() { _currentPageIdx = roundedIdx; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GreenPass',
          style: TextStyle(
            color: _currentPageIdx == 0 ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Information',
            color: _currentPageIdx == 0 ? Colors.black : Colors.white,
            onPressed: () async {
              _addPassIntoWallet();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hello there!')));
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: TabBarView(
        controller: _tabController,
        children: _tabPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIdx,
        onTap: (newIdx) {
          _tabController.animateTo(newIdx);
        },
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'My Pass',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan Pass',
          ),
        ],
      ),
    );
  }
}
