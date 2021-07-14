import 'package:country_codes/country_codes.dart';
import 'package:greenpass_app/green_validator/payload/vaccine_type.dart';

import 'cert_entry.dart';

class CertEntryVaccination extends CertEntry {
  final String vaccineCode; // type, not the concrete product
  final String medicalProductCode;
  final String manufacturerCode;
  final int doseNumber;
  final int dosesNeeded;
  final DateTime dateOfVaccination;

  CertEntryVaccination({
    required String certificateIdentifier,
    required String certificateIssuer,
    required CountryDetails? country,
    required String targetedDiseaseCode,

    required this.vaccineCode,
    required this.medicalProductCode,
    required this.manufacturerCode,
    required this.doseNumber,
    required this.dosesNeeded,
    required this.dateOfVaccination,
  }) : super(
    certificateIdentifier: certificateIdentifier,
    certificateIssuer: certificateIssuer,
    country: country,
    targetedDiseaseCode: targetedDiseaseCode,
  );

  VaccineType get vaccine {
    if (vaccineCode == '1119305005') return VaccineType.antigen;
    if (vaccineCode == '1119349007') return VaccineType.mRna;
    if (vaccineCode == 'J07BX03') return VaccineType.other;
    return VaccineType.unknown;
  }

  String get medicalProduct {
    if (medicalProductCode == 'EU/1/20/1528') return 'Comirnaty';
    if (medicalProductCode == 'EU/1/20/1507') return 'COVID-19 Vaccine Moderna';
    if (medicalProductCode == 'EU/1/21/1529') return 'Vaxzevria';
    if (medicalProductCode == 'EU/1/20/1525') return 'COVID-19 Vaccine Janssen';
    if (medicalProductCode == 'CVnCoV') return 'CVnCoV';
    if (medicalProductCode == 'NVX-CoV2373') return 'NVX-CoV2373';
    if (medicalProductCode == 'Sputnik-V') return 'Sputnik V';
    if (medicalProductCode == 'Convidecia') return 'Convidecia';
    if (medicalProductCode == 'EpiVacCorona') return 'EpiVacCorona';
    if (medicalProductCode == 'BBIBP-CorV') return 'BBIBP-CorV';
    if (medicalProductCode == 'Inactivated-SARS-CoV-2-Vero-Cell') return 'Inactivated SARS-CoV-2 (Vero Cell)';
    if (medicalProductCode == 'CoronaVac') return 'CoronaVac';
    if (medicalProductCode == 'Covaxin') return 'Covaxin (also known as BBV152 A, B, C)';

    return 'Unknown';
  }

  String get manufacturer {
    if (manufacturerCode == 'ORG-100001699') return 'AstraZeneca AB';
    if (manufacturerCode == 'ORG-100030215') return 'Biontech Manufacturing GmbH';
    if (manufacturerCode == 'ORG-100001417') return 'Janssen-Cilag International';
    if (manufacturerCode == 'ORG-100031184') return 'Moderna Biotech Spain S.L.';
    if (manufacturerCode == 'ORG-100006270') return 'Curevac AG';
    if (manufacturerCode == 'ORG-100013793') return 'CanSino Biologics';
    if (manufacturerCode == 'ORG-100020693') return 'China Sinopharm International Corp. - Beijing location';
    if (manufacturerCode == 'ORG-100010771') return 'Sinopharm Weiqida Europe Pharmaceutical s.r.o. - Prague location';
    if (manufacturerCode == 'ORG-100024420') return 'Sinopharm Zhijun (Shenzhen) Pharmaceutical Co. Ltd. - Shenzhen location';
    if (manufacturerCode == 'ORG-100032020') return 'Novavax CZ AS';
    if (manufacturerCode == 'Gamaleya-Research-Institute') return 'Gamaleya Research Institute';
    if (manufacturerCode == 'Vector-Institute') return 'Vector Institute';
    if (manufacturerCode == 'Sinovac-Biotech') return 'Sinovac Biotech';
    if (manufacturerCode == 'Bharat-Biotech') return 'Bharat Biotech';

    return 'Unknown';
  }
}