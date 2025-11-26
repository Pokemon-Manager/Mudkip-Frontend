import 'dart:async';
import 'dart:convert';

import 'package:mudkip_frontend/mudkipc.dart';
import 'package:talker/talker.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:ulid/ulid.dart';

enum ReyveldConnectionState {
  disconnected,
  connectedUnsecured,
  connectedSecured
}

class Reyveld {
  static WebSocket? _socket;

  static final StreamController<ReyveldConnectionState> _statusController =
      StreamController<ReyveldConnectionState>.broadcast();
  static Stream<ReyveldConnectionState> get statusChange =>
      _statusController.stream;

  static ReyveldConnectionState _state = ReyveldConnectionState.disconnected;

  static ReyveldConnectionState get state => _state;

  static final Map<String, ReyveldTask> _tasks = {};

  static void start() {
    final backoff = LinearBackoff(
      initial: const Duration(seconds: 0),
      increment: const Duration(seconds: 1),
      maximum: const Duration(seconds: 5),
    );
    _socket = WebSocket(Uri.parse('ws://127.0.0.1:7274/lua'), backoff: backoff);
    _socket!.connection.listen((data) {
      if (data is Connected) {
        _statusController.add(ReyveldConnectionState.connectedUnsecured);
      } else if (data is Disconnected) {
        _statusController.add(ReyveldConnectionState.disconnected);
      } else if (data is Reconnected) {
        _statusController.add(ReyveldConnectionState.connectedUnsecured);
      } else if (data is Reconnecting) {
        _statusController.add(ReyveldConnectionState.disconnected);
      } else if (data is Disconnecting) {
        _statusController.add(ReyveldConnectionState.disconnected);
      } else if (data is Connecting) {
        _statusController.add(ReyveldConnectionState.disconnected);
      }
    });

    statusChange.listen((event) async {
      MudkiPC.talker.info("Reyveld event: $event");
      _state = event;
      if (event == ReyveldConnectionState.connectedUnsecured) {
        final currentToken = await MudkiPC.getReyveldToken();
        final token = await Reyveld.run("""
local appname = "MudkiPC"
local tk = ${currentToken != null ? '"$currentToken"' : 'nil'} 
local pols = { SPolicy.files({
            reasoning = "To read and write to PK files for Pokémon games.",
            rexter = true,
            wexter = true,
            rinter = true,
            winter = true,
            whitelist = Globs.whitelist().addAll({ "*.pk9", "*.pk8",
                "*.pk7", "*.pk6", "*.pk5", "*.pk4", "*.pk3", "*.pk2", "*.pk1" })
        }) }

function Contract(name, token, policies)
    if token == nil then
        token = AuthVeld.newContract(name, policies)
    elseif not AuthVeld.hasContract(token) then
        token = AuthVeld.newContract(name, policies)
    elseif AuthVeld.requiresUpdate(token, policies) then
        AuthVeld.deleteContract(token)
        token = AuthVeld.newContract(name, policies)
    end
    if token ~= nil then
        AuthVeld.loadContract(token)
    end
    return token
end

return Contract(appname, tk, pols)
""").then((e) async => await e.future);
        if (token != null && await MudkiPC.getReyveldToken() != token) {
          await MudkiPC.setReyveldToken(token);
        }
        MudkiPC.talker.info("Reyveld connection secured.");
        _statusController.sink.add(ReyveldConnectionState.connectedSecured);
      }
    });
  }

  static Future<ReyveldTask> run(String code) async {
    final pid = Ulid().toUuid();
    final task = ReyveldTask(pid);
    _socket!.send("""
Session.pid("$pid")

$code
""");
    MudkiPC.talker.info("Started new Reyveld task, PID: $pid");
    _tasks[pid] = task;
    _socket!.messages.listen((data) {
      MudkiPC.talker.info("Reyveld message: $data");
      final message = jsonDecode(data);
      final pid = message['pid'];
      if (_tasks.containsKey(pid)) {
        switch (message['type']) {
          case 'completed':
            _tasks[pid]!.complete(message['data']);
            _tasks.remove(pid);
          case 'data':
            _tasks[pid]!.send(message['data']);
          case 'error':
            throw ReyveldException(pid, message['data']);
        }
      }
    });
    return task;
  }
}

class ReyveldTask {
  final String pid;
  final Completer<dynamic> _completer = Completer<dynamic>();
  final StreamController<dynamic> _controller =
      StreamController<dynamic>.broadcast();
  Stream<dynamic> get stream => _controller.stream;

  ReyveldTask(this.pid);

  Future<dynamic> get future => _completer.future;

  void send(dynamic data) {
    _controller.sink.add(data);
  }

  void complete(dynamic data) {
    _completer.complete(data);
    MudkiPC.talker.logCustom(SuccessfulTask(this));
  }
}

class SuccessfulTask extends TalkerLog {
  SuccessfulTask(ReyveldTask task)
      : super("Reyveld task successful (PID: ${task.pid})");

  /// Log title
  static get getTitle => 'Successful Task';

  /// Log key
  static get getKey => 'success_task';

  /// Log color
  static get getPen => AnsiPen()..green();

  /// The following overrides are required because the base class expects instance getters,
  /// but we use static getters to allow for easy customization and reuse of colors, titles, and keys.
  /// This approach works around limitations in the base class API, which does not support passing custom values
  /// directly to the constructor or as parameters, so we override the instance getters to return the static values.
  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

class ReyveldException implements Exception {
  final String pid;
  final dynamic data;
  const ReyveldException(this.pid, this.data);

  @override
  String toString() => "Task failed (PID: $pid) ${data.toString()}";
}
