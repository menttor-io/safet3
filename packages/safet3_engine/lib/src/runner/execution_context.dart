/// Holds the runtime state of a mission (variables, logs).
class ExecutionContext {
  final Map<String, dynamic> _store = {};
  final StringBuffer _logs = StringBuffer();

  ExecutionContext([Map<String, String>? initialVariables]) {
    if (initialVariables != null) {
      _store.addAll(initialVariables);
    }
  }

  /// Sets a variable value (e.g., extracted token).
  void set(String key, dynamic value) {
    _store[key] = value;
  }

  /// Gets a variable value.
  dynamic get(String key) => _store[key];

  /// Replaces {{key}} placeholders in a string with actual values.
  /// Example: "Bearer {{token}}" -> "Bearer abc123xyz"
  String interpolate(String input) {
    if (!input.contains('{{')) return input;

    return input.replaceAllMapped(RegExp(r'\{\{(.*?)\}\}'), (match) {
      final key = match.group(1)?.trim();
      if (key == null) return match.group(0)!;

      final value = _store[key];
      // Si la variable n'existe pas, on laisse tel quel pour debug
      return value?.toString() ?? match.group(0)!;
    });
  }

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _logs.writeln('[$timestamp] $message');
    // En mode CLI, on pourrait aussi print directement
    print('[$timestamp] $message'); 
  }
}