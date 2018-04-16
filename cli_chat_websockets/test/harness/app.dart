import 'package:chat/chat.dart';
import 'package:aqueduct/test.dart';

export 'package:chat/chat.dart';
export 'package:aqueduct/test.dart';
export 'package:test/test.dart';
export 'package:aqueduct/aqueduct.dart';

/// A testing harness for chat.
///
/// Use instances of this class to start/stop the test chat server. Use [client] to execute
/// requests against the test server.  This instance will use configuration values
/// from config.src.yaml.
class TestApplication {
  Application<Chat> application;
  Chat get channel => application.channel;
  TestClient client;

  /// Starts running this test harness.
  ///
  /// This method will start an [Application] with [Chat].
  ///
  /// You must call [stop] on this instance when tearing down your tests.
  Future start() async {
    Controller.letUncaughtExceptionsEscape = true;
    application = new Application<Chat>();
    application.options.port = 0;
    application.options.configurationFilePath = "config.src.yaml";

    await application.test();

    client = new TestClient(application);
  }

  /// Stops running this application harness.
  ///
  /// This method must be called during test tearDown.
  Future stop() async {
    await application?.stop();
  }
}
