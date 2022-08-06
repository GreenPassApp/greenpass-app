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
    if (medicalProductCode == 'EU/1/20/1507') return 'Spikevax';
    if (medicalProductCode == 'EU/1/21/1529') return 'Vaxzevria';
    if (medicalProductCode == 'EU/1/20/1525') return 'Jcovden';
    if (medicalProductCode == 'CVnCoV') return 'CVnCoV';
    if (medicalProductCode == 'NVX-CoV2373') return 'NVX-CoV2373';
    if (medicalProductCode == 'Sputnik-V') return 'Sputnik V';
    if (medicalProductCode == 'Convidecia') return 'Convidecia';
    if (medicalProductCode == 'EpiVacCorona') return 'EpiVacCorona';
    if (medicalProductCode == 'BBIBP-CorV') return 'BBIBP-CorV';
    if (medicalProductCode == 'Inactivated-SARS-CoV-2-Vero-Cell') return 'Inactivated SARS-CoV-2 (Vero Cell)';
    if (medicalProductCode == 'CoronaVac') return 'CoronaVac';
    if (medicalProductCode == 'Covaxin') return 'Covaxin';
    if (medicalProductCode == 'Covishield') return 'Covishield';
    if (medicalProductCode == 'Covid-19-recombinant') return 'Covid-19 (recombinant)';
    if (medicalProductCode == 'R-COVI') return 'R-COVI';
    if (medicalProductCode == 'CoviVac') return 'CoviVac';
    if (medicalProductCode == 'Sputnik-Light') return 'Sputnik Light';
    if (medicalProductCode == 'Hayat-Vax') return 'Hayat-Vax';
    if (medicalProductCode == 'Abdala') return 'Abdala';
    if (medicalProductCode == 'WIBP-CorV') return 'WIBP-CorV';
    if (medicalProductCode == 'MVC-COV1901') return 'MVC COVID-19 Vaccine';
    if (medicalProductCode == 'EU/1/21/1618') return 'Nuvaxovid';
    if (medicalProductCode == 'Covovax') return 'Covovax';
    if (medicalProductCode == 'Vidprevtyn') return 'Vidprevtyn';
    if (medicalProductCode == 'VLA2001') return 'VLA2001';
    if (medicalProductCode == 'EpiVacCorona-N') return 'EpiVacCorona-N';
    if (medicalProductCode == 'Sputnik-M') return 'Sputnik M';
    if (medicalProductCode == 'Covid-19-adsorvida-inativada') return 'Vacina adsorvida covid-19 (inativada)';
    if (medicalProductCode == 'NVSI-06-08') return 'NVSI-06-08';
    if (medicalProductCode == 'YS-SC2-010') return 'YS-SC2-010';
    if (medicalProductCode == 'SCTV01C') return 'SCTV01C';
    if (medicalProductCode == 'Covifenz') return 'Covifenz';
    if (medicalProductCode == 'AZD2816') return 'AZD2816';
    if (medicalProductCode == 'Soberana-02') return 'Soberana 02';
    if (medicalProductCode == 'Soberana-Plus') return 'Soberana Plus';

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
    if (manufacturerCode == 'ORG-100001981') return 'Serum Institute Of India Private Limited';
    if (manufacturerCode == 'Fiocruz') return 'Fiocruz';
    if (manufacturerCode == 'ORG-100007893') return 'R-Pharm CJSC';
    if (manufacturerCode == 'Chumakov-Federal-Scientific-Center') return 'Chumakov Federal Scientific Center for Research and Development of Immune-and-Biological Products';
    if (manufacturerCode == 'ORG-100023050') return 'Gulf Pharmaceutical Industries';
    if (manufacturerCode == 'CIGB') return 'Center for Genetic Engineering and Biotechnology';
    if (manufacturerCode == 'Sinopharm-WIBP') return 'Sinopharm - Wuhan Institute of Biological Products';
    if (manufacturerCode == 'ORG-100033914') return 'Medigen Vaccine Biologics Corporation';
    if (manufacturerCode == 'ORG-100000788') return 'Sanofi Pasteur';
    if (manufacturerCode == 'ORG-100036422') return 'Valneva France';
    if (manufacturerCode == 'Instituto-Butantan') return 'Instituto Butantan';
    if (manufacturerCode == 'NVSI') return 'National Vaccine and Serum Institute, China';
    if (manufacturerCode == 'Yisheng-Biopharma') return 'Yisheng Biopharma';
    if (manufacturerCode == 'ORG-100026614') return 'Sinocelltech Ltd.';
    if (manufacturerCode == 'ORG-100008549') return 'Medicago Inc.';
    if (manufacturerCode == 'Finlay-Institute') return 'Finlay Institute of Vaccines';

    return 'Unknown';
  }
}