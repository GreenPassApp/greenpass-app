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
}