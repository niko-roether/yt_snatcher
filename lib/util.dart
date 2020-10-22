Stream<T> futureIntoStream<T>(Future<Stream<T>> streamFuture) {
  return Stream.fromFuture(streamFuture).asyncExpand((event) => event);
}
