import 'package:easy_localization/easy_localization.dart';

class PersonInfo {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;

  PersonInfo({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  });

  String get fullName {
    return firstName + ' ' + lastName;
  }

  String get pseudoIdentifier {
    return this.firstName + '_' + DateFormat('yyyy-MM-dd').format(this.dateOfBirth) + '_' + this.lastName;
  }
}