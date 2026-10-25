/// Runs independent startup work only after the first frame is visible.
Future<void> runDeferredStartup({
  required Future<void> firstFrame,
  required Iterable<Future<void> Function()> tasks,
  required void Function(Object error, StackTrace stackTrace) onError,
}) async {
  try {
    await firstFrame;
  } catch (error, stackTrace) {
    onError(error, stackTrace);
    return;
  }

  await Future.wait(
    tasks.map((initialize) async {
      try {
        await initialize();
      } catch (error, stackTrace) {
        onError(error, stackTrace);
      }
    }),
  );
}
