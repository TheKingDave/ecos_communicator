import 'event.dart';

abstract class EventHandler {
  void onEvent(Event event) {}
}