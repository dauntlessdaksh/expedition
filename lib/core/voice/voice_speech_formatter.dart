/// Converts workout metrics into natural spoken phrases for TTS.
abstract final class VoiceSpeechFormatter {
  static const _numberWords = {
    0: 'zero',
    1: 'one',
    2: 'two',
    3: 'three',
    4: 'four',
    5: 'five',
    6: 'six',
    7: 'seven',
    8: 'eight',
    9: 'nine',
    10: 'ten',
    11: 'eleven',
    12: 'twelve',
    13: 'thirteen',
    14: 'fourteen',
    15: 'fifteen',
    16: 'sixteen',
    17: 'seventeen',
    18: 'eighteen',
    19: 'nineteen',
    20: 'twenty',
    30: 'thirty',
    40: 'forty',
    50: 'fifty',
    60: 'sixty',
    70: 'seventy',
    80: 'eighty',
    90: 'ninety',
  };

  static String distanceMilestone({
    required int markerIndex,
    required int intervalMeters,
  }) {
    final distanceMeters = markerIndex * intervalMeters;

    if (intervalMeters == 1000) {
      if (markerIndex == 1) {
        return 'One kilometer completed.';
      }
      return 'Distance ${_numberWords[markerIndex] ?? markerIndex.toString()} kilometers.';
    }

    if (intervalMeters == 500 && distanceMeters == 500) {
      return 'Five hundred meters completed.';
    }

    if (distanceMeters % 1000 == 0) {
      final kilometers = distanceMeters ~/ 1000;
      if (kilometers == 1) {
        return 'One kilometer completed.';
      }
      return 'Distance ${_numberWords[kilometers] ?? kilometers.toString()} kilometers.';
    }

    if (distanceMeters >= 1000) {
      final km = distanceMeters / 1000;
      return 'Distance ${_decimal(km)} kilometers completed.';
    }

    return '${distanceMeters.round()} meters completed.';
  }

  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) {
      parts.add('${_word(hours)} ${hours == 1 ? 'hour' : 'hours'}');
    }
    if (minutes > 0) {
      parts.add('${_word(minutes)} ${minutes == 1 ? 'minute' : 'minutes'}');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('${_word(seconds)} ${seconds == 1 ? 'second' : 'seconds'}');
    }

    if (parts.length == 1) {
      return parts.first;
    }
    if (parts.length == 2) {
      return '${parts.first} ${parts.last}';
    }
    return '${parts[0]} ${parts[1]} ${parts[2]}';
  }

  static String distanceKm(double meters) {
    final km = meters / 1000;
    if (km < 0.1) {
      return '${meters.round()} meters';
    }
    return '${_decimal(km)} kilometers';
  }

  static String pacePerKm(double metersPerSecond) {
    if (metersPerSecond <= 0.3) {
      return 'pace unavailable';
    }

    final totalSeconds = (1000 / metersPerSecond).round();
    return '${duration(Duration(seconds: totalSeconds))} per kilometer';
  }

  static String speedKmh(double metersPerSecond) {
    if (metersPerSecond <= 0) {
      return 'zero kilometers per hour';
    }
    final kmh = metersPerSecond * 3.6;
    return '${_decimal(kmh)} kilometers per hour';
  }

  static String calories(int value) {
    return '${_word(value)} calories burned';
  }

  static String elevationGain(double meters) {
    if (meters <= 0) {
      return 'no elevation gain';
    }
    return 'elevation gain ${meters.round()} meters';
  }

  static String gpsStatus(double accuracyMeters) {
    if (accuracyMeters <= 0) {
      return 'GPS signal searching.';
    }
    if (accuracyMeters <= 12) {
      return 'GPS signal good.';
    }
    if (accuracyMeters <= 25) {
      return 'GPS signal fair.';
    }
    return 'GPS signal weak.';
  }

  static String timeCheckpoint(Duration elapsed) {
    return 'Time ${duration(elapsed)}.';
  }

  static String _word(int value) {
    if (_numberWords.containsKey(value)) {
      return _numberWords[value]!;
    }
    if (value < 100) {
      final tens = (value ~/ 10) * 10;
      final ones = value % 10;
      if (ones == 0) {
        return _numberWords[tens] ?? value.toString();
      }
      return '${_numberWords[tens] ?? '$tens'} ${_word(ones)}';
    }
    return value.toString();
  }

  static String _decimal(double value) {
    final rounded = (value * 10).round() / 10;
    final whole = rounded.floor();
    final fraction = ((rounded - whole) * 10).round();

    if (fraction == 0) {
      return _word(whole);
    }

    return '${_word(whole)} point ${_word(fraction)}';
  }
}
