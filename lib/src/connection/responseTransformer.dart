import 'dart:async';

import '../objects/response.dart';

/// Transforms a [String] [Stream] into a [Reply] [Stream]
class ResponseTransformer implements StreamTransformer<String, Response> {
  StreamController _controller;
  StreamSubscription _subscription;

  /// If the stream should be closed when an error occurred
  final bool cancelOnError;

  Stream<String> _stream;

  /// Creates a ReplyTransformer
  ///
  /// It congregate the lines until an `<END` is received and then parses it
  /// into a [Reply]
  ResponseTransformer({bool sync = false, this.cancelOnError}) {
    _controller = StreamController<Response>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  void _onListen() {
    _subscription = _stream.listen(_onData,
        onError: _controller.addError,
        onDone: _controller.close,
        cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  String _rawResponse = '';

  void _onData(String data) {
    _rawResponse += '\n$data';
    if (data.startsWith('<END')) {
      _controller.add(Response.fromString(_rawResponse));
      _rawResponse = '';
    }
  }

  @override
  Stream<Response> bind(Stream<String> stream) {
    _stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
