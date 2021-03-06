import 'package:flutter/widgets.dart';
import 'package:flutter_command/flutter_command.dart';

class CommandBuilder<TParam, TResult> extends StatelessWidget {
  final Command<TParam, TResult> command;
  final Widget Function(BuildContext, TResult, TParam) onData;
  final Widget Function(BuildContext, TResult lastValue, TParam) whileExecuting;
  final Widget Function(BuildContext, Object, TResult lastValue, TParam)
      onError;

  const CommandBuilder({
    this.command,
    @required this.onData,
    this.whileExecuting,
    this.onError,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CommandResult<TParam, TResult>>(
        valueListenable: command.results,
        builder: (context, result, _) {
          return result.toWidget(
              onResult: (data, paramData) =>
                  onData?.call(context, data, paramData) ?? SizedBox(),
              whileExecuting: (lastData, paramData) =>
                  whileExecuting?.call(context, lastData, paramData) ??
                  SizedBox(),
              onError: (lastData, error, paramData) =>
                  onError?.call(context, lastData, error, paramData) ??
                  SizedBox());
        });
  }
}

extension ToWidgeCommandResult<TParam, TResult>
    on CommandResult<TParam, TResult> {
  Widget toWidget(
      {@required Widget Function(TResult lastResult, TParam param) onResult,
      Widget Function(TResult lastResult, TParam param) whileExecuting,
      Widget Function(Object error, TResult lastResult, TParam param)
          onError}) {
    if (error != null) {
      return onError?.call(error, data, paramData) ?? SizedBox();
    }
    if (isExecuting) {
      return whileExecuting?.call(data, paramData) ?? SizedBox();
    }
    return onResult(data, paramData);
  }
}
