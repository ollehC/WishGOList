// Helper function for json_serializable generated code
T? $enumDecodeNullable<T>(Map<T, Object> enumValues, Object? source) {
  if (source == null) {
    return null;
  }
  return enumValues.entries
      .singleWhere(
        (e) => e.value == source,
        orElse: () => throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        ),
      )
      .key;
}