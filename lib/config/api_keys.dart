class ApiKeys {
  ApiKeys._();

  // Override example:
  // --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
  static const String googleMaps = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyBF6oYuVqjQjJJvlg6p9vVnHohloBFuYMQ',
  );
}
