import 'package:cloud_firestore/cloud_firestore.dart';

enum AgentStatus {
  vivo,
  morto,
  desaparecido;

  static AgentStatus fromString(String status) {
    return AgentStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AgentStatus.desaparecido,
    );
  }
}

class Character {
  final String id;
  final String codinome;
  final AgentStatus agentStatus;
  final int dangerLevel;
  final String? profilePhotoUrl;
  final String? campaignId;
  final DateTime? createdAt;
  final bool archived;
  final bool achievementsRevealed;
  final bool forceTerminalOpen;
  final bool forceMacOpen;
  final String? spotifyPlaylistUrl;
  final String? agentId;
  final List<String> unlockedCampaigns;

  Character({
    required this.id,
    required this.codinome,
    required this.agentStatus,
    required this.dangerLevel,
    this.profilePhotoUrl,
    this.campaignId,
    this.createdAt,
    this.archived = false,
    this.achievementsRevealed = false,
    this.forceTerminalOpen = false,
    this.forceMacOpen = false,
    this.spotifyPlaylistUrl,
    this.agentId,
    this.unlockedCampaigns = const [],
  });

  factory Character.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Character(
      id: doc.id,
      codinome: data['codinome'] ?? '',
      agentStatus: AgentStatus.fromString(data['agentStatus'] ?? 'desaparecido'),
      dangerLevel: data['dangerLevel'] ?? 1,
      profilePhotoUrl: data['profilePhotoUrl'],
      campaignId: data['campaignId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      archived: data['archived'] ?? false,
      achievementsRevealed: data['achievementsRevealed'] ?? false,
      forceTerminalOpen: data['forceTerminalOpen'] ?? false,
      forceMacOpen: data['forceMacOpen'] ?? false,
      spotifyPlaylistUrl: data['spotifyPlaylistUrl'],
      agentId: data['agentId'],
      unlockedCampaigns: List<String>.from(data['unlockedCampaigns'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'codinome': codinome,
      'agentStatus': agentStatus.name,
      'dangerLevel': dangerLevel,
      'profilePhotoUrl': profilePhotoUrl,
      'campaignId': campaignId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'archived': archived,
      'achievementsRevealed': achievementsRevealed,
      'forceTerminalOpen': forceTerminalOpen,
      'forceMacOpen': forceMacOpen,
      'spotifyPlaylistUrl': spotifyPlaylistUrl,
      'agentId': agentId,
      'unlockedCampaigns': unlockedCampaigns,
    };
  }

  Character copyWith({
    String? id,
    String? codinome,
    AgentStatus? agentStatus,
    int? dangerLevel,
    String? profilePhotoUrl,
    Object? campaignId = const Object(),
    DateTime? createdAt,
    bool? archived,
    bool? achievementsRevealed,
    bool? forceTerminalOpen,
    bool? forceMacOpen,
    String? spotifyPlaylistUrl,
    String? agentId,
    List<String>? unlockedCampaigns,
  }) {
    return Character(
      id: id ?? this.id,
      codinome: codinome ?? this.codinome,
      agentStatus: agentStatus ?? this.agentStatus,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      campaignId: campaignId == const Object() ? this.campaignId : (campaignId as String?),
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
      achievementsRevealed: achievementsRevealed ?? this.achievementsRevealed,
      forceTerminalOpen: forceTerminalOpen ?? this.forceTerminalOpen,
      forceMacOpen: forceMacOpen ?? this.forceMacOpen,
      spotifyPlaylistUrl: spotifyPlaylistUrl ?? this.spotifyPlaylistUrl,
      agentId: agentId ?? this.agentId,
      unlockedCampaigns: unlockedCampaigns ?? this.unlockedCampaigns,
    );
  }
}
