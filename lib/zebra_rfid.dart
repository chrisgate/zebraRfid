import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zebra_rfid/base.dart';

class ZebraRfid {
  static const MethodChannel _channel =
      const MethodChannel('com.hone.zebraRfid/plugin');
  static const EventChannel _eventChannel =
      const EventChannel('com.hone.zebraRfid/event_channel');
  static ZebraEngineEventHandler _handler;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> toast(String text) async {
    return _channel.invokeMethod('toast', {"text": text});
  }

  ///
  static Future<String> onRead() async {
    return _channel.invokeMethod('startRead');
  }

  ///写
  static Future<String> write() async {
    return _channel.invokeMethod('write');
  }

  ///连接设备
  static Future<dynamic> connect() async {
    try {
      await _addEventChannelHandler();
      var result = await _channel.invokeMethod('connect');
      return result;
    } catch (e) {
      var a = e;
    }
  }

  ///断开设备
  static Future<String> disconnect() async {
    return _channel.invokeMethod('disconnect');
  }

  /// Sets the engine event handler.
  ///
  /// After setting the engine event handler, you can listen for engine events and receive the statistics of the corresponding [RtcEngine] instance.
  ///
  /// **Parameter** [handler] The event handler.
  static void setEventHandler(ZebraEngineEventHandler handler) {
    _handler = handler;
  }

  static StreamSubscription<dynamic> _sink;
  static Future<void> _addEventChannelHandler() async {
    if (_sink == null) {
      _sink = _eventChannel.receiveBroadcastStream().listen((event) {
        final eventMap = Map<String, dynamic>.from(event);
        final eventName = eventMap['eventName'] as String;
        // final data = List<dynamic>.from(eventMap['data']);
        _handler?.process(eventName, eventMap);
      });
    }
  }

  ///连接设备
  static Future<String> dispose() async {
    _sink = null;
    return _channel.invokeMethod('dispose');
  }
}
