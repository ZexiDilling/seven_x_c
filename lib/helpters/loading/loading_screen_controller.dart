import 'package:flutter/foundation.dart' show immutable;

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingSCreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingSCreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
