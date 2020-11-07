Stream<T> futureIntoStream<T>(Future<Stream<T>> streamFuture) {
  assert(streamFuture != null);
  return Stream.fromFuture(streamFuture).asyncExpand((event) => event);
}

class Dimension extends Comparable<Dimension> {
  int width;
  int height;

  Dimension(this.width, this.height)
      : assert(width != null),
        assert(height != null);

  int size() => width * height;

  @override
  String toString() {
    return "$width x $height";
  }

  @override
  int compareTo(Dimension other) {
    assert(other != null);
    return size() - other.size();
  }
}

// Returns a sorted copy of a list instead of sorting the list itself
List<T> listSort<T>(List<T> list, int Function(T, T) compare) {
  assert(list != null);
  assert(compare != null);
  list.sort(compare);
  return list;
}

Future<T> retry<T>(Future<T> Function() futureBuilder, int times) async {
  assert(futureBuilder != null);
  assert(times != null);
  var error;
  for (; times > 0; times--) {
    try {
      return await futureBuilder();
    } catch (e) {
      error = e;
    }
  }
  throw error;
}

final _durationRegex = RegExp(
    "^([0-9]{1,2}):([0-9]{2}):([0-9]{2})\\.([0-9]{2})([0-9]{2})([0-9]{2})\$");

Duration parseDuration(String durationString) {
  assert(durationString != null);
  var match = _durationRegex.firstMatch(durationString);
  if (match == null) {
    throw FormatException(
      "The date string was of invalid format",
      durationString,
    );
  }
  return Duration(
    days: int.parse(match.group(1)),
    hours: int.parse(match.group(2)),
    minutes: int.parse(match.group(3)),
    seconds: int.parse(match.group(4)),
    milliseconds: int.parse(match.group(5)),
    microseconds: int.parse(match.group(6)),
  );
}

String capitalize(String str) {
  assert(str != null);
  return str.substring(0, 1).toUpperCase() + str.substring(1);
}

// The eleven character ID length might need to be adjusted in the future
// Matches youtube urls and ids of various formats
final _ytIdOrUrlRegex = RegExp(
    "^(?:(?:https?:\\/\\/)?(?:youtu\\.be\\/|(?:(?:www|m)\\.)?youtube\\.com\\/watch\\?v=))?([A-Za-z0-9_-]{11})(?:(?:\\?|&)[A-Za-z][A-Za-z0-9_-]*=[^?&/=\\s]+)*\$");

bool validateYoutubeUrlOrId(String urlOrId) {
  assert(urlOrId != null);
  return _ytIdOrUrlRegex.hasMatch(urlOrId);
}

String extractYoutubeId(String urlOrId) {
  assert(urlOrId != null);
  return _ytIdOrUrlRegex.firstMatch(urlOrId).group(1);
}

N numInRange<N extends num>(N number, N min, N max) {
  if (number < min) return min;
  if (number > max) return max;
  return number;
}

String stringifyDuration(Duration duration) {
  if (duration == null) return "0:00";
  int hours = duration.inHours.floor();
  int minutes = duration.inMinutes.floor() % 60;
  int seconds = duration.inSeconds.floor() % 60;
  // just trust me on this one
  // uses one of the following formats as they fit:
  // hh:mm:ss
  // mm:ss
  // m:ss
  return "${hours > 0 ? "$hours${minutes < 10 ? "0" : ""}:" : ""}$minutes:${seconds < 10 ? "0" : ""}$seconds";
}
