import 'dart:async';

import 'reply.dart';

/// Stream transformer to create reply's from Strings
class ReplyTransformer implements StreamTransformer<String, Reply> {
  StreamController _controller;
  StreamSubscription _subscription;
  /// If the stream should be closed when an error occurred
  final bool cancelOnError;

  Stream<String> _stream;

  /// Creates a ReplyTransformer
  ///
  /// It congregate the lines until an `<END` is received and then parses it
  /// into a [Reply]
  ReplyTransformer({bool sync = false, this.cancelOnError}) {
    _controller = StreamController<Reply>(
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
    _appendData(data);
    if (data.startsWith('<END')) {
      _controller.add(Reply.fromString(_rawResponse));
      _rawResponse = '';
    }
  }

  void _appendData(String data) {
    _rawResponse += '\n$data';
  }

  @override
  Stream<Reply> bind(Stream<String> stream) {
    _stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
