import 'package:path/path.dart' as p;

/// Returns whether [path] satisfies [pattern].
///
/// This helper is used by path-based predicates and conditions. It supports
/// these simple pattern forms:
///
/// - path segment, such as `data`;
/// - exact path, such as `lib/src/data`, when the pattern starts at the same
///   segment as the checked path;
/// - segment sequence, such as `data/repository`;
/// - `..` pattern, such as `..service..` or `..data/service..`;
/// - basic glob pattern with `*` and `**`.
///
/// Example:
/// ```dart
/// pathMatches('lib/src/user/data/repository.dart', 'data'); // true
/// pathMatches('lib/src/user/data/repository.dart', 'lib/src/user/data'); // false
/// pathMatches('lib/src/user/data/repository/foo.dart', 'data/repository'); // true
/// pathMatches('lib/src/user/data/repository.dart', 'lib/src/user/data/**'); // true
/// pathMatches('lib/src/user/service/foo.dart', '..service..'); // true
/// pathMatches('lib/src/user/data/service/foo.dart', '..data/service..'); // true
/// pathMatches('lib/src/user/data/foo_impl.dart', '/data/**/*impl.dart'); // true
/// ```
bool pathMatches(String path, String pattern) {
  final normalizedPath = normalizePath(path);
  final normalizedPattern = normalizePath(pattern);

  if (_isSegmentWildcardPattern(normalizedPattern)) {
    final token = normalizedPattern.replaceAll('..', '').replaceAll('/', '');
    return normalizedPath.split('/').contains(token);
  }

  if (normalizedPattern.contains('..')) {
    return _patternRegex(normalizedPattern).hasMatch(normalizedPath);
  }
  if (normalizedPattern.contains('*') || normalizedPattern.contains('(*)') || normalizedPattern.contains('(**)')) {
    return _patternRegex(normalizedPattern).hasMatch(normalizedPath);
  }
  if (normalizedPattern.contains('/')) {
    if (_looksLikeCompletePath(normalizedPath, normalizedPattern)) {
      return normalizedPath == normalizedPattern;
    }
    return normalizedPath == normalizedPattern ||
        normalizedPath.startsWith('$normalizedPattern/') ||
        normalizedPath.endsWith('/$normalizedPattern') ||
        normalizedPath.contains('/$normalizedPattern/');
  }
  return normalizedPath.split('/').contains(normalizedPattern);
}

/// Captures the slice segment matched by the first `(*)` in [pattern].
///
/// The full [pattern] must match [path]. When [pattern] ends with `(*)`, it is
/// treated as a slice root and also matches descendants of the captured segment.
/// The pattern supports the same wildcard syntax as [pathMatches].
String? captureSlicePathSegment(String path, String pattern) {
  final normalizedPath = normalizePath(path);
  final normalizedPattern = normalizePath(pattern);
  if (!normalizedPattern.contains('(*)')) return null;
  return _sliceCaptureRegex(normalizedPattern).firstMatch(normalizedPath)?.group(1);
}

/// Normalizes path separators to `/`.
String normalizePath(String path) => p.normalize(path).replaceAll(r'\', '/');

bool _isSegmentWildcardPattern(String pattern) {
  if (!pattern.startsWith('..') || !pattern.endsWith('..')) return false;
  final token = pattern.replaceAll('..', '').replaceAll('/', '');
  return token.isNotEmpty && !pattern.contains('/') && !token.contains('*') && !token.contains('(');
}

bool _looksLikeCompletePath(String path, String pattern) {
  return path.split('/').first == pattern.split('/').first;
}

RegExp _patternRegex(String pattern) {
  final matchFromAnySegment = pattern.startsWith('/');
  final effectivePattern = matchFromAnySegment ? pattern.substring(1) : pattern;
  final buffer = StringBuffer('^');
  if (matchFromAnySegment) {
    buffer.write('(?:.*/)?');
  }
  var index = 0;
  while (index < effectivePattern.length) {
    if (effectivePattern.startsWith('(**)', index)) {
      buffer.write('(.+)');
      index += 4;
    } else if (effectivePattern.startsWith('(*)', index)) {
      buffer.write('([^/]+)');
      index += 3;
    } else if (effectivePattern.startsWith('..', index)) {
      buffer.write('.*');
      index += 2;
    } else if (effectivePattern.startsWith('**/', index)) {
      buffer.write('(?:.*/)?');
      index += 3;
    } else if (effectivePattern.startsWith('**', index)) {
      buffer.write('.*');
      index += 2;
    } else if (effectivePattern[index] == '*') {
      buffer.write('[^/]*');
      index += 1;
    } else {
      buffer.write(RegExp.escape(effectivePattern[index]));
      index += 1;
    }
  }
  buffer.write(r'$');
  return RegExp(buffer.toString());
}

RegExp _sliceCaptureRegex(String pattern) {
  final matchFromAnySegment = pattern.startsWith('/');
  final effectivePattern = matchFromAnySegment ? pattern.substring(1) : pattern;
  final buffer = StringBuffer('^');
  if (matchFromAnySegment) {
    buffer.write('(?:.*/)?');
  }

  var captured = false;
  var index = 0;
  while (index < effectivePattern.length) {
    if (effectivePattern.startsWith('(**)', index)) {
      buffer.write('(?:.+)');
      index += 4;
    } else if (effectivePattern.startsWith('(*)', index)) {
      buffer.write(captured ? '(?:[^/]+)' : '([^/]+)');
      captured = true;
      index += 3;
    } else if (effectivePattern.startsWith('..', index)) {
      buffer.write('.*');
      index += 2;
    } else if (effectivePattern.startsWith('**/', index)) {
      buffer.write('(?:.*/)?');
      index += 3;
    } else if (effectivePattern.startsWith('**', index)) {
      buffer.write('.*');
      index += 2;
    } else if (effectivePattern[index] == '*') {
      buffer.write('[^/]*');
      index += 1;
    } else {
      buffer.write(RegExp.escape(effectivePattern[index]));
      index += 1;
    }
  }
  if (effectivePattern.endsWith('(*)')) {
    buffer.write('(?:/.*)?');
  }
  buffer.write(r'$');
  return RegExp(buffer.toString());
}
