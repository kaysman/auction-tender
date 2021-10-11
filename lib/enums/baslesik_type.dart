enum BaslesikType { TENDOR, AUCTION }

extension Property on BaslesikType {
  String get title {
    switch (this) {
      case BaslesikType.TENDOR:
        return "Bäsleşik";
      case BaslesikType.AUCTION:
        return "Bäsleşikli söwda";
      default:
        throw Exception();
    }
  }

  String get satyjy {
    switch (this) {
      case BaslesikType.TENDOR:
        return "Satyn alyjy: ";
      case BaslesikType.AUCTION:
        return "Satyjy: ";
      default:
        throw Exception();
    }
  }

  String get date {
    switch (this) {
      case BaslesikType.TENDOR:
        return "Geçirilýän senesi: ";
      case BaslesikType.AUCTION:
        return "Geçirilýän senesi: ";
      default:
        throw Exception();
    }
  }
}
