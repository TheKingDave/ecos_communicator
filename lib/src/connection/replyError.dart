import '../objects/reply.dart';

/// Error thrown when the status of a reply is not 0
class ReplyError implements Exception {
  /// The status code
  final int status;

  /// The status message
  final String statusMsg;

  /// The reply that that is the source of this Error
  final Reply reply;

  /// Creates [ReplyError] with the specified values
  ReplyError({this.status, this.statusMsg, this.reply});

  /// Creates a [ReplyError] from an [Reply]
  factory ReplyError.fromReply(Reply reply) {
    return ReplyError(
      status: reply.status,
      statusMsg: reply.statusMsg,
      reply: reply,
    );
  }

  @override
  String toString() {
    return 'ReplyError{status: $status, statusMsg: $statusMsg, reply: $reply}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplyError &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          statusMsg == other.statusMsg &&
          reply == other.reply;

  @override
  int get hashCode => status.hashCode ^ statusMsg.hashCode ^ reply.hashCode;
}
