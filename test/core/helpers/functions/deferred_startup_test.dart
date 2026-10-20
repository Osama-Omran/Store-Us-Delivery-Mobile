import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/functions/deferred_startup.dart';

void main() {
  group('runDeferredStartup', () {
    test('waits for the first frame before starting services', () async {
      final firstFrame = Completer<void>();
      var starts = 0;

      final startup = runDeferredStartup(
        firstFrame: firstFrame.future,
        tasks: [
          () async {
            starts++;
          },
        ],
        onError: (error, stackTrace) => fail('Unexpected error: $error'),
      );

      await Future<void>.value();
      expect(starts, 0);

      firstFrame.complete();
      await startup;
      expect(starts, 1);
    });

    test('a pending service does not block another service', () async {
      final pendingService = Completer<void>();
      final siblingStarted = Completer<void>();
      var startupCompleted = false;

      final startup = runDeferredStartup(
        firstFrame: Future<void>.value(),
        tasks: [
          () => pendingService.future,
          () async {
            siblingStarted.complete();
          },
        ],
        onError: (error, stackTrace) => fail('Unexpected error: $error'),
      ).then((_) => startupCompleted = true);

      await siblingStarted.future;
      expect(startupCompleted, isFalse);

      pendingService.complete();
      await startup;
      expect(startupCompleted, isTrue);
    });

    test(
      'service failures are reported without skipping other services',
      () async {
        final synchronousFailure = StateError('Synchronous service failure');
        final asynchronousFailure = StateError('Asynchronous service failure');
        final errors = <Object>[];
        final stackTraces = <StackTrace>[];
        var healthyServiceStarted = false;

        await runDeferredStartup(
          firstFrame: Future<void>.value(),
          tasks: [
            () => throw synchronousFailure,
            () async => throw asynchronousFailure,
            () async {
              healthyServiceStarted = true;
            },
          ],
          onError: (error, stackTrace) {
            errors.add(error);
            stackTraces.add(stackTrace);
          },
        );

        expect(healthyServiceStarted, isTrue);
        expect(
          errors,
          unorderedEquals([synchronousFailure, asynchronousFailure]),
        );
        expect(stackTraces, hasLength(2));
        expect(
          stackTraces.every((stackTrace) => stackTrace.toString().isNotEmpty),
          isTrue,
        );
      },
    );

    test(
      'a failed first frame is reported without starting services',
      () async {
        final firstFrame = Completer<void>();
        final frameFailure = StateError('First frame failed');
        final errors = <Object>[];
        var serviceStarted = false;

        final startup = runDeferredStartup(
          firstFrame: firstFrame.future,
          tasks: [
            () async {
              serviceStarted = true;
            },
          ],
          onError: (error, stackTrace) => errors.add(error),
        );

        firstFrame.completeError(frameFailure);
        await startup;

        expect(serviceStarted, isFalse);
        expect(errors, [frameFailure]);
      },
    );

    test('services run once as asynchronous work completes', () async {
      final firstFrame = Completer<void>();
      final pendingService = Completer<void>();
      final siblingStarted = Completer<void>();
      final starts = <String>[];

      final startup = runDeferredStartup(
        firstFrame: firstFrame.future,
        tasks: [
          () {
            starts.add('pending');
            return pendingService.future;
          },
          () async {
            starts.add('sibling');
            siblingStarted.complete();
          },
        ],
        onError: (error, stackTrace) => fail('Unexpected error: $error'),
      );

      firstFrame.complete();
      await siblingStarted.future;
      expect(starts, ['pending', 'sibling']);

      pendingService.complete();
      await startup;
      await Future<void>.value();
      expect(starts, ['pending', 'sibling']);
    });
  });
}
