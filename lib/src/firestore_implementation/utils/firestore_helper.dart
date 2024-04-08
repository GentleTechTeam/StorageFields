import 'package:googleapis/firestore/v1.dart';
import 'package:recase/recase.dart';

const encodedNull = {'nullValue': 'NULL_VALUE'};

/// Encodes a raw map to firestore json, enclosed in a 'fields' object.
///
/// E.g. converts:
///   {'myFlag': true}
/// to:
///   {'fields': {'myFlag': {'booleanValue': true}}}
///
// ignore: prefer-match-file-name
extension ToFirestoreJson on Map<String, Object?> {
  Map<String, Map<String, dynamic>> toFirestoreJson() {
    return {
      'fields': <String, Object?>{
        for (final entry in entries)
          entry.key: entry.value?.toEncodedMap() ?? encodedNull,
      },
    };
  }
}

extension ToEncodedMap on Object {
  Map<String, dynamic> toEncodedMap() {
    if (this is bool) {
      return <String, Object>{'booleanValue': this};
    }

    if (this is int) {
      return <String, String>{'integerValue': toString()};
    }

    if (this is double) {
      return <String, Object?>{'doubleValue': this};
    }

    if (this is String) {
      return <String, Object?>{'stringValue': this};
    }

    if (this is DateTime) {
      return <String, String>{
        'timestampValue': (this as DateTime).toUtc().toIso8601String(),
      };
    }

    if (this is List) {
      return <String, Object?>{
        'arrayValue': {
          'values': [
            for (final Object? entry in this as List)
              entry?.toEncodedMap() ?? encodedNull,
          ],
        },
      };
    }

    if (this is Map) {
      return <String, Object?>{
        'mapValue': {
          'fields': {
            for (final entry in (this as Map<String, Object?>).entries)
              entry.key: entry.value?.toEncodedMap() ?? encodedNull,
          },
        },
      };
    }

    // We'll encode the string representation of unknown types.
    // Note that GeoPoint and Reference types are currently unhandled.
    print(
      // ignore: no_runtimetype_tostring
      'Unexpected type: $runtimeType - Calling toString() on object',
    );

    return <String, String>{'stringValue': toString()};
  }
}

/// Creates a firestore mask for a [Document.fields] Value map.
/// Typically used by an update function when merging data into an existing dataset.
///
/// The mask is a string array of field name paths in dot notation.
/// The mask will contain the paths of each field in a nested map, but not the map field itself.
///
/// E.g. A Value map of the form:
///
///   {
///     'a' {
///       'x': 1
///       'y': 2
///     }
///     'b': [1]
///   }
///
/// will produce a mask of:
///
///   ['a.x', 'a.y', 'b']
///
extension ToFirestoreMask on Map<String, Value> {
  List<String> toFirestoreMask() {
    final mask = <String>[];
    for (final entry in entries) {
      mask.addAll(
        entry.value.toFieldPath(entry: entry),
      );
    }

    return mask;
  }
}

extension _ToFieldPath on Value {
  List<String> toFieldPath({
    required MapEntry<String, Value> entry,
    String? parentKey,
  }) {
    final path = parentKey == null ? entry.key : '$parentKey.${entry.key}';

    if (mapValue != null) {
      final fields = mapValue?.fields;
      if (fields == null) {
        return [];
      }

      final mapMask = <String>[];
      for (final child in fields.entries) {
        mapMask.addAll(
          child.value.toFieldPath(
            entry: child,
            parentKey: path,
          ),
        );
      }

      return mapMask;
    }

    return [path];
  }

  /// TODO: Cover with tests
  // ignore: no-object-declaration
  Object? toDecodedJson() {
    if (booleanValue != null) {
      return booleanValue;
    }
    if (bytesValue != null) {
      return bytesValue;
    }
    if (doubleValue != null) {
      return doubleValue;
    }
    if (geoPointValue != null) {
      return geoPointValue.toString();
    }
    if (integerValue != null) {
      // ignore: avoid-non-null-assertion
      return int.parse(integerValue!);
    }
    if (nullValue != null) {
      return null;
    }
    if (stringValue != null) {
      return stringValue;
    }
    if (referenceValue != null) {
      return referenceValue;
    }
    if (timestampValue != null) {
      return timestampValue;
    }

    if (arrayValue != null) {
      return arrayValue?.values
              ?.map((value) => value.toDecodedJson())
              .toList() ??
          <Object?>[];
    }

    if (mapValue != null) {
      return mapValue?.fields
              ?.map((key, value) => MapEntry(key, value.toDecodedJson())) ??
          <Object?, Object?>{};
    }

    return null;
  }
}

extension DocumentExtension on Document {
  Map<String, Object?> toDecodedJson() {
    final fieldsData = Map<String, Value>.from(toJson()['fields'] as Map);

    return fieldsData.map(
      (key, value) => MapEntry(key, value.toDecodedJson()),
    );
  }
}

/// Converts keys to camelCase
extension ToCamelCaseKeys on Map<String, Object?> {
  Map<String, Object?> toCamelCaseKeys() {
    return {
      for (final entry in entries)
        ReCase(entry.key).camelCase: entry.value is Map
            ? (entry.value as Map<String, Object?>).toCamelCaseKeys()
            : entry.value,
    };
  }
}
