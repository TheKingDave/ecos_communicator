import 'dart:async';

import 'reply.dart';

class ResponseTransformer implements StreamTransformer<String, Reply> {
  StreamController _controller;
  StreamSubscription _subscription;
  bool cancelOnError;

  Stream<String> _stream;

  ResponseTransformer({bool sync = false, this.cancelOnError}) {
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

  ResponseTransformer.broadcast({bool sync = false, this.cancelOnError}) {
    _controller = StreamController.broadcast(
        onListen: _onListen, onCancel: _onCancel, sync: sync);
  }

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError,
        onDone: _controller.close,
        cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  String _rawResponse = '';

  void onData(String data) {
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
