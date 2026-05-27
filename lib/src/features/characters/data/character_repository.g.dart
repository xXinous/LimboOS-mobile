// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$characterRepositoryHash() =>
    r'7afd7b3f5ff09aa839a41350f92d59cbb7b2d1e5';

/// See also [characterRepository].
@ProviderFor(characterRepository)
final characterRepositoryProvider =
    AutoDisposeProvider<CharacterRepository>.internal(
      characterRepository,
      name: r'characterRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$characterRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CharacterRepositoryRef = AutoDisposeProviderRef<CharacterRepository>;
String _$userCharactersHash() => r'badd191ae42fd26a4d4f9428a96baec4cedd510e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userCharacters].
@ProviderFor(userCharacters)
const userCharactersProvider = UserCharactersFamily();

/// See also [userCharacters].
class UserCharactersFamily extends Family<AsyncValue<List<Character>>> {
  /// See also [userCharacters].
  const UserCharactersFamily();

  /// See also [userCharacters].
  UserCharactersProvider call(String uid) {
    return UserCharactersProvider(uid);
  }

  @override
  UserCharactersProvider getProviderOverride(
    covariant UserCharactersProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userCharactersProvider';
}

/// See also [userCharacters].
class UserCharactersProvider
    extends AutoDisposeStreamProvider<List<Character>> {
  /// See also [userCharacters].
  UserCharactersProvider(String uid)
    : this._internal(
        (ref) => userCharacters(ref as UserCharactersRef, uid),
        from: userCharactersProvider,
        name: r'userCharactersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userCharactersHash,
        dependencies: UserCharactersFamily._dependencies,
        allTransitiveDependencies:
            UserCharactersFamily._allTransitiveDependencies,
        uid: uid,
      );

  UserCharactersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    Stream<List<Character>> Function(UserCharactersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserCharactersProvider._internal(
        (ref) => create(ref as UserCharactersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Character>> createElement() {
    return _UserCharactersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserCharactersProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserCharactersRef on AutoDisposeStreamProviderRef<List<Character>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _UserCharactersProviderElement
    extends AutoDisposeStreamProviderElement<List<Character>>
    with UserCharactersRef {
  _UserCharactersProviderElement(super.provider);

  @override
  String get uid => (origin as UserCharactersProvider).uid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
