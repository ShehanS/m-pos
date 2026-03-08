import 'dart:convert';

class FormFieldEntity {
  final String? id;
  final Map<String, String>? displayName;
  final String? name;
  final String? defaultValue;
  final List<Map<String, dynamic>>? optionValue;
  final String? type;
  final bool? validate;
  final bool? required;
  final String? dependOn;
  final String? condition;

  const FormFieldEntity({
    this.id,
    this.displayName,
    this.name,
    this.defaultValue,
    this.optionValue,
    this.type,
    this.validate,
    this.required,
    this.dependOn,
    this.condition,
  });

  factory FormFieldEntity.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>>? parsedOptions;

    if (map['optionValue'] != null) {
      var rawOptions = map['optionValue'];

      while (rawOptions is List && rawOptions.isNotEmpty && rawOptions.first is List) {
        rawOptions = rawOptions.first;
      }

      if (rawOptions is List) {
        parsedOptions = rawOptions.map((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
      }
    }

    return FormFieldEntity(
      id: map['id'] as String?,
      displayName: map['displayName'] != null
          ? Map<String, String>.from(map['displayName'])
          : null,
      name: map['name'] as String?,
      defaultValue: map['defaultValue']?.toString(),
      optionValue: parsedOptions,
      type: map['type'] as String?,
      validate: map['validate'] as bool?,
      required: map['required'] as bool?,
      dependOn: map['dependOn'] as String?,
      condition: map['condition'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'name': name,
      'defaultValue': defaultValue,
      'optionValue': optionValue,
      'type': type,
      'validate': validate,
      'required': required,
      'dependOn': dependOn,
      'condition': condition,
    };
  }

  factory FormFieldEntity.fromJson(String source) =>
      FormFieldEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  FormFieldEntity copyWith({
    String? id,
    Map<String, String>? displayName,
    String? name,
    String? defaultValue,
    List<Map<String, dynamic>>? optionValue,
    String? type,
    bool? validate,
    bool? required,
    String? dependOn,
    String? condition,
  }) {
    return FormFieldEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      defaultValue: defaultValue ?? this.defaultValue,
      optionValue: optionValue ?? this.optionValue,
      type: type ?? this.type,
      validate: validate ?? this.validate,
      required: required ?? this.required,
      dependOn: dependOn ?? this.dependOn,
      condition: condition ?? this.condition,
    );
  }

  @override
  String toString() {
    return 'FormFieldEntity(id: $id, displayName: $displayName, name: $name, defaultValue: $defaultValue, optionValue: $optionValue, type: $type, validate: $validate, required: $required, dependOn: $dependOn, condition: $condition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormFieldEntity &&
        other.id == id &&
        _mapEquals(other.displayName, displayName) &&
        other.name == name &&
        other.defaultValue == defaultValue &&
        _listEquals(other.optionValue, optionValue) &&
        other.type == type &&
        other.validate == validate &&
        other.required == required &&
        other.dependOn == dependOn &&
        other.condition == condition;
  }

  @override
  int get hashCode {
    return Object.hash(id, displayName, name, defaultValue, optionValue, type, validate, required, dependOn, condition);
  }
}

bool _mapEquals(Map? a, Map? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    final valueA = a[key];
    final valueB = b[key];
    if (valueA is Map && valueB is Map) {
      if (!_mapEquals(valueA, valueB)) return false;
    } else if (valueA is List && valueB is List) {
      if (!_listEquals(valueA, valueB)) return false;
    } else if (valueA != valueB) {
      return false;
    }
  }
  return true;
}

bool _listEquals(List? a, List? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    final elementA = a[i];
    final elementB = b[i];
    if (elementA is Map && elementB is Map) {
      if (!_mapEquals(elementA, elementB)) return false;
    } else if (elementA is List && elementB is List) {
      if (!_listEquals(elementA, elementB)) return false;
    } else if (elementA != elementB) {
      return false;
    }
  }
  return true;
}