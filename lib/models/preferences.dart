import 'helper.dart';
import 'organization.dart';

class AuctionPreferences {
  AuctionPreferences({
    this.organization,
    this.regions,
    this.lines,
  });

  final Organization organization;
  final Region regions;
  final BusinessLine lines;
}

class TenderPreferences {
  TenderPreferences({
    this.organization,
    this.lines,
  });

  final Organization organization;
  final BusinessLine lines;
}
