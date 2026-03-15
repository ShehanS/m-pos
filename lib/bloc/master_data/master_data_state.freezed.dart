// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_data_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MasterDataState {
  MasterDataStatus get status => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  GlobalSettingEntity? get setting => throw _privateConstructorUsedError;

  /// Create a copy of MasterDataState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MasterDataStateCopyWith<MasterDataState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MasterDataStateCopyWith<$Res> {
  factory $MasterDataStateCopyWith(
          MasterDataState value, $Res Function(MasterDataState) then) =
      _$MasterDataStateCopyWithImpl<$Res, MasterDataState>;
  @useResult
  $Res call(
      {MasterDataStatus status,
      String errorMessage,
      GlobalSettingEntity? setting});

  $GlobalSettingEntityCopyWith<$Res>? get setting;
}

/// @nodoc
class _$MasterDataStateCopyWithImpl<$Res, $Val extends MasterDataState>
    implements $MasterDataStateCopyWith<$Res> {
  _$MasterDataStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MasterDataState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = null,
    Object? setting = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MasterDataStatus,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      setting: freezed == setting
          ? _value.setting
          : setting // ignore: cast_nullable_to_non_nullable
              as GlobalSettingEntity?,
    ) as $Val);
  }

  /// Create a copy of MasterDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GlobalSettingEntityCopyWith<$Res>? get setting {
    if (_value.setting == null) {
      return null;
    }

    return $GlobalSettingEntityCopyWith<$Res>(_value.setting!, (value) {
      return _then(_value.copyWith(setting: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MasterDataStateImplCopyWith<$Res>
    implements $MasterDataStateCopyWith<$Res> {
  factory _$$MasterDataStateImplCopyWith(_$MasterDataStateImpl value,
          $Res Function(_$MasterDataStateImpl) then) =
      __$$MasterDataStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MasterDataStatus status,
      String errorMessage,
      GlobalSettingEntity? setting});

  @override
  $GlobalSettingEntityCopyWith<$Res>? get setting;
}

/// @nodoc
class __$$MasterDataStateImplCopyWithImpl<$Res>
    extends _$MasterDataStateCopyWithImpl<$Res, _$MasterDataStateImpl>
    implements _$$MasterDataStateImplCopyWith<$Res> {
  __$$MasterDataStateImplCopyWithImpl(
      _$MasterDataStateImpl _value, $Res Function(_$MasterDataStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MasterDataState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = null,
    Object? setting = freezed,
  }) {
    return _then(_$MasterDataStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MasterDataStatus,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      setting: freezed == setting
          ? _value.setting
          : setting // ignore: cast_nullable_to_non_nullable
              as GlobalSettingEntity?,
    ));
  }
}

/// @nodoc

class _$MasterDataStateImpl implements _MasterDataState {
  const _$MasterDataStateImpl(
      {this.status = MasterDataStatus.initial,
      this.errorMessage = '',
      this.setting});

  @override
  @JsonKey()
  final MasterDataStatus status;
  @override
  @JsonKey()
  final String errorMessage;
  @override
  final GlobalSettingEntity? setting;

  @override
  String toString() {
    return 'MasterDataState(status: $status, errorMessage: $errorMessage, setting: $setting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MasterDataStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.setting, setting) || other.setting == setting));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, errorMessage, setting);

  /// Create a copy of MasterDataState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MasterDataStateImplCopyWith<_$MasterDataStateImpl> get copyWith =>
      __$$MasterDataStateImplCopyWithImpl<_$MasterDataStateImpl>(
          this, _$identity);
}

abstract class _MasterDataState implements MasterDataState {
  const factory _MasterDataState(
      {final MasterDataStatus status,
      final String errorMessage,
      final GlobalSettingEntity? setting}) = _$MasterDataStateImpl;

  @override
  MasterDataStatus get status;
  @override
  String get errorMessage;
  @override
  GlobalSettingEntity? get setting;

  /// Create a copy of MasterDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MasterDataStateImplCopyWith<_$MasterDataStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
