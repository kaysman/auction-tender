const words = [
  [
    '',
    'bir',
    'iki',
    'üç',
    'dört',
    'bäş',
    'alty',
    'ýedi',
    'sekiz',
    'dokuz',
  ],
  [
    '',
    'on',
    'ýigrimi',
    'otuz',
    'kyrk',
    'elli',
    'altmyş',
    'ýetmiş',
    'segsen',
    'dogsan'
  ],
  [
    '',
    'bir ýüz',
    'iki ýüz',
    'üç ýüz',
    'dört ýüz',
    'bäş ýüz',
    'alty ýüz',
    'ýedi ýüz',
    'sekiz ýüz',
    'dokuz ýüz'
  ]
];

// toFloat function
double toFloat(String number) => double.tryParse(number) ?? 0;

// toInt function
int toInt(String number) => int.tryParse(number) ?? 0;

// parseNumber function
String parseNumber(String number, int count) {
  String first;
  String second;
  String numeral = '';

  if (number.length == 3) {
    first = number.substring(0, 1);
    number = number.substring(1, 3);
    numeral = '' + words[2][toInt(first)] + ' ';
  }

  if (toInt(number) < 10) {
    numeral = numeral + words[0][toInt(number)] + ' ';
  } else {
    first = number.substring(0, 1);
    second = number.substring(1, 2);
    numeral =
        numeral + words[1][toInt(first)] + ' ' + words[0][toInt(second)] + ' ';
  }

  if (count == 1) {
    if (numeral != ' ') {
      numeral = numeral + 'müň ';
    }
  } else if (count == 2) {
    if (numeral != ' ') {
      numeral = numeral + 'million ';
    }
  } else if (count == 3) {
    numeral = numeral + 'milliard ';
  } else if (count == 4) {
    numeral = numeral + 'trillion ';
  }

  return numeral;
}

// converter function
String converter(String number) {
  String numeral = '';
  String parts = '';
  int count = 0;
  String digit;

  for (int i = number.length - 1; i >= 0; i--) {
    digit = number.substring(i, i + 1);
    parts = digit + parts;

    if ((parts.length == 3 || i == 0) && double.tryParse(parts) != null) {
      numeral = parseNumber(parts, count) + numeral;
      parts = '';
      count++;
    }
  }

//  numeral = numeral.replace(/\s+/g, ' ');
  return numeral;
}

// esasy function
numberToTextConverter(String number) {
  if (number == null) {
    return null;
  }

  if (toFloat(number) <= 0) {
    return null;
  }

  List<String> splt;
  String decimals;
  number = toFloat(number).toStringAsFixed(2);

  if (number.indexOf('.') != -1) {
    splt = number.split('.');
    number = splt[0];
    decimals = splt[1];
  }

  String manat = converter(number);
  String tenne = '00 ';

  if (toFloat(decimals) != 0) {
    tenne = converter(decimals);
  }

  return manat.toString() + "manat " + tenne.toString() + "teňňe";
}
