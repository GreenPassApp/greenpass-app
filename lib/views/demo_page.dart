import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {

  final _certTextController = TextEditingController(
    text: 'HC1:NCFTW2H:7*I06R3W/J:O6:P4QB3+7RKFVJWV66UBCE//UXDT:*ML-4D.NBXR+SRHMNIY6EB8I595+6UY9-+0DPIO6C5%0SBHN-OWKCJ6BLC2M.M/NPKZ4F3WNHEIE6IO26LB8:F4:JVUGVY8*EKCLQ..QCSTS+F\$:0PON:.MND4Z0I9:GU.LBJQ7/2IJPR:PAJFO80NN0TRO1IB:44:N2336-:KC6M*2N*41C42CA5KCD555O/A46F6ST1JJ9D0:.MMLH2/G9A7ZX4DCL*010LGDFI\$MUD82QXSVH6R.CLIL:T4Q3129HXB8WZI8RASDE1LL9:9NQDC/O3X3G+A:2U5VP:IE+EMG40R53CG9J3JE1KB KJA5*\$4GW54%LJBIWKE*HBX+4MNEIAD\$3NR E228Z9SS4E R3HUMH3J%-B6DRO3T7GJBU6O URY858P0TR8MDJ\$6VL8+7B5\$G CIKIPS2CPVDK%K6+N0GUG+TG+RB5JGOU55HXDR.TL-N75Y0NHQTZ3XNQMTF/ZHYBQ\$8IR9MIQHOSV%9K5-7%ZQ/.15I0*-J8AVD0N0/0USH.3',
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('This is just a demo for verifying the EU green certificate.'),
              Padding(padding: const EdgeInsets.only(top: 16.0)),
              TextField(
                controller: _certTextController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Raw certificate',
                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 16.0)),
              ElevatedButton(
                onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (context) {
                      // TODO scan a qr code
                      String qr = _certTextController.text;

                      ValidationResult res = GreenValidator.validate(qr);

                      if (!res.success)
                        throw ('Could not validate: ' + res.errorCode.toString());

                      GreenCertificate cert = res.certificate!;

                      print(cert);
                      print(cert.personInfo.firstName);

                      return AlertDialog(
                        content: Text(
                            'Type: ' + cert.certificateType.toString() + '\n' +
                                'For: ' + cert.personInfo.firstName + ' ' + cert.personInfo.lastName + '\n' +
                                'Error: ' + res.errorCode.toString()
                        ),
                      );
                    },
                  )
                },
                child: Text('Validate'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
