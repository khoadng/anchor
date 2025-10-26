import 'package:flutter/foundation.dart';

final isDesktop = switch (defaultTargetPlatform) {
  TargetPlatform.macOS => true,
  TargetPlatform.linux => true,
  TargetPlatform.windows => true,
  _ => false,
};
