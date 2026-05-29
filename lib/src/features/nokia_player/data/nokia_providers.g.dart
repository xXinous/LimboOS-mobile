// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nokia_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$campaignIntelListHash() => r'967ef294fd4ae9eee6a5082d654580be6c2bda9e';

/// See also [campaignIntelList].
@ProviderFor(campaignIntelList)
final campaignIntelListProvider =
    StreamProvider<List<IntelItem>>.internal(
      campaignIntelList,
      name: r'campaignIntelListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$campaignIntelListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CampaignIntelListRef = StreamProviderRef<List<IntelItem>>;
String _$unlockedIntelIdsHash() => r'unlockedIntelIdsHash';

/// See also [unlockedIntelIds].
@ProviderFor(unlockedIntelIds)
final unlockedIntelIdsProvider =
    StreamProvider<List<String>>.internal(
      unlockedIntelIds,
      name: r'unlockedIntelIdsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unlockedIntelIdsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnlockedIntelIdsRef = StreamProviderRef<List<String>>;
String _$nokiaScreenStateHash() => r'db93b2c4e9d028d839b6e14cdf1ffc67800c7629';

/// See also [NokiaScreenState].
@ProviderFor(NokiaScreenState)
final nokiaScreenStateProvider =
    NotifierProvider<NokiaScreenState, NokiaScreen>.internal(
      NokiaScreenState.new,
      name: r'nokiaScreenStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nokiaScreenStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NokiaScreenState = Notifier<NokiaScreen>;
String _$nokiaVolumeHash() => r'bc3d022e9f7c8b4e6e072b8924f658fb9db21ee4';

/// See also [NokiaVolume].
@ProviderFor(NokiaVolume)
final nokiaVolumeProvider =
    NotifierProvider<NokiaVolume, int>.internal(
      NokiaVolume.new,
      name: r'nokiaVolumeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nokiaVolumeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NokiaVolume = Notifier<int>;
String _$nokiaMuteHash() => r'a3af96bc4b697ef9980841765e9fe5218571411e';

/// See also [NokiaMute].
@ProviderFor(NokiaMute)
final nokiaMuteProvider = NotifierProvider<NokiaMute, bool>.internal(
  NokiaMute.new,
  name: r'nokiaMuteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nokiaMuteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NokiaMute = Notifier<bool>;
String _$activeAudioIntelHash() => r'66c2c6048a70f67603414cc6a673ebacd32e7ee1';

/// See also [ActiveAudioIntel].
@ProviderFor(ActiveAudioIntel)
final activeAudioIntelProvider =
    NotifierProvider<ActiveAudioIntel, IntelItem?>.internal(
      ActiveAudioIntel.new,
      name: r'activeAudioIntelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeAudioIntelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveAudioIntel = Notifier<IntelItem?>;
String _$nokiaAudioPlaybackStatusHash() =>
    r'3fc56af144b6d088c09d56227a9ab2a7a6da8734';

/// See also [NokiaAudioPlaybackStatus].
@ProviderFor(NokiaAudioPlaybackStatus)
final nokiaAudioPlaybackStatusProvider =
    NotifierProvider<
      NokiaAudioPlaybackStatus,
      NokiaAudioStatus
    >.internal(
      NokiaAudioPlaybackStatus.new,
      name: r'nokiaAudioPlaybackStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nokiaAudioPlaybackStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NokiaAudioPlaybackStatus = Notifier<NokiaAudioStatus>;
String _$nokiaActiveSmsHash() => r'b2ed3f569648a73a0133ed1da6809ec483a12dff';

/// See also [NokiaActiveSms].
@ProviderFor(NokiaActiveSms)
final nokiaActiveSmsProvider =
    NotifierProvider<NokiaActiveSms, NokiaSms?>.internal(
      NokiaActiveSms.new,
      name: r'nokiaActiveSmsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nokiaActiveSmsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NokiaActiveSms = Notifier<NokiaSms?>;
String _$nokiaSmsListHash() => r'10865d48785e3923a8ca0efcc02d720d574028b3';

/// See also [NokiaSmsList].
@ProviderFor(NokiaSmsList)
final nokiaSmsListProvider =
    NotifierProvider<NokiaSmsList, List<NokiaSms>>.internal(
      NokiaSmsList.new,
      name: r'nokiaSmsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nokiaSmsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NokiaSmsList = Notifier<List<NokiaSms>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
