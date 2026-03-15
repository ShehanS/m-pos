// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_data_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MasterDataEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadMasterData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadMasterData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadMasterData,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMasterData value) loadMasterData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMasterData value)? loadMasterData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMasterData value)? loadMasterData,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MasterDataEventCopyWith<$Res> {
  factory $MasterDataEventCopyWith(
          MasterDataEvent value, $Res Function(MasterDataEvent) then) =
      _$MasterDataEventCopyWithImpl<$Res, MasterDataEvent>;
}

/// @nodoc
class _$MasterDataEventCopyWithImpl<$Res, $Val extends MasterDataEvent>
    implements $MasterDataEventCopyWith<$Res> {
  _$MasterDataEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MasterDataEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadMasterDataImplCopyWith<$Res> {
  factory _$$LoadMasterDataImplCopyWith(_$LoadMasterDataImpl value,
          $Res Function(_$LoadMasterDataImpl) then) =
      __$$LoadMasterDataImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadMasterDataImplCopyWithImpl<$Res>
    extends _$MasterDataEventCopyWithImpl<$Res, _$LoadMasterDataImpl>
    implements _$$LoadMasterDataImplCopyWith<$Res> {
  __$$LoadMasterDataImplCopyWithImpl(
      _$LoadMasterDataImpl _value, $Res Function(_$LoadMasterDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MasterDataEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadMasterDataImpl implements LoadMasterData {
  const _$LoadMasterDataImpl();

  @override
  String toString() {
    return 'MasterDataEvent.loadMasterData()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadMasterDataImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadMasterData,
  }) {
    return loadMasterData();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadMasterData,
  }) {
    return loadMasterData?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadMasterData,
    required TResult orElse(),
  }) {
    if (loadMasterData != null) {
      return loadMasterData();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMasterData value) loadMasterData,
  }) {
    return loadMasterData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMasterData value)? loadMasterData,
  }) {
    return loadMasterData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMasterData value)? loadMasterData,
    required TResult orElse(),
  }) {
    if (loadMasterData != null) {
      return loadMasterData(this);
    }
    return orElse();
  }
}

abstract class LoadMasterData implements MasterDataEvent {
  const factory LoadMasterData() = _$LoadMasterDataImpl;
}
