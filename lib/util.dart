Stream<T> futureIntoStream<T>(Future<Stream<T>> streamFuture) {
  return Stream.fromFuture(streamFuture).asyncExpand((event) => event);
}

class Dimension extends Comparable<Dimension> {
  int width;
  int height;

  Dimension(this.width, this.height);

  int size() => width * height;

  @override
  String toString() {
    return "$width x $height";
  }

  @override
  int compareTo(Dimension other) {
    return size() - other.size();
  }
}

// Returns a sorted copy of a list instead of sorting the list itself
List<T> listSort<T>(List<T> list, int Function(T, T) compare) {
  list.sort(compare);
  return list;
}
