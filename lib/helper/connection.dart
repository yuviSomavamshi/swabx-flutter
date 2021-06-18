import 'dart:convert';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import '../constants.dart';
import 'SharedPreferencesHelper.dart';

class Connection {
  SocketIO _socket;

  Connection() {
    if (_socket == null) {
      _socketStatus(dynamic data) {
        print("Socket status: " + data);
      }

      //update the domain before using
      _socket = SocketIOManager()
          .createSocketIO(kWebsite, "/", socketStatusCallback: _socketStatus);
      //call init socket before doing anything
      _socket.init();

      //connect socket
      _socket.connect();
      _socket.subscribe("DEVICE_DISCONNECTED", _getMessage);
    }
  }

  sendMessage(String event, String message) {
    if (_socket != null) {
      _socket.sendMessage(event, message);
    }
  }

  destroy() {
    SocketIOManager().destroyAllSocket();
    _socket = null;
  }

  void subscribe(String event, Function callback) {
    if (_socket != null) {
      _socket.subscribe(event, callback);
    }
  }
}

void _getMessage(dynamic data) async {
  Map<String, dynamic> map = new Map<String, dynamic>();
  map = json.decode(data);
  if (map['senderName'] != null) {
    String name = await SharedPreferencesHelper.getString("RECEIVER");
    if (map['senderName'] == name) {
      await SharedPreferencesHelper.removeString("RECEIVER");
    }
  }
}

Connection con = Connection();
