// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$campaignRepositoryHash() =>
    r'd90f4bfc95684421292c527b320a1aa5543c29ab';

/// See also [campaignRepository].
@ProviderFor(campaignRepository)
final campaignRepositoryProvider =
    AutoDisposeProvider<CampaignRepository>.internal(
      campaignRepository,
      name: r'campaignRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$campaignRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CampaignRepositoryRef = AutoDisposeProviderRef<CampaignRepository>;
String _$activeCampaignsHash() => r'5a2725d8aa164379fd35e2815930a5bfa82a6a3f';

/// See also [activeCampaigns].
@ProviderFor(activeCampaigns)
final activeCampaignsProvider =
    AutoDisposeStreamProvider<List<Campaign>>.internal(
      activeCampaigns,
      name: r'activeCampaignsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeCampaignsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCampaignsRef = AutoDisposeStreamProviderRef<List<Campaign>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
