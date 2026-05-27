import 'package:cloud_firestore/cloud_firestore.dart';

enum IntelType {
  audio,
  visual,
  text,
  meta;

  static IntelType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'AUDIO':
        return IntelType.audio;
      case 'VISUAL':
        return IntelType.visual;
      case 'TEXT':
        return IntelType.text;
      case 'META':
        return IntelType.meta;
      default:
        return IntelType.text;
    }
  }
}

class IntelMetadata {
  final String? npc;
  final String? artist;
  final String? chapter;
  final int? duration;
  final bool? isSecret;
  final String? visualCategory;
  final String? imageUrl;
  final String? icon;
  final String? hint;
  final String? unlockCondition;
  final String? achievementRuleId;

  IntelMetadata({
    this.npc,
    this.artist,
    this.chapter,
    this.duration,
    this.isSecret,
    this.visualCategory,
    this.imageUrl,
    this.icon,
    this.hint,
    this.unlockCondition,
    this.achievementRuleId,
  });

  factory IntelMetadata.fromMap(Map<String, dynamic> map) {
    return IntelMetadata(
      npc: map['npc'] as String?,
      artist: map['artist'] as String?,
      chapter: map['chapter'] as String?,
      duration: map['duration'] is int ? map['duration'] as int : (map['duration'] as num?)?.toInt(),
      isSecret: map['isSecret'] as bool?,
      visualCategory: map['visualCategory'] as String? ?? map['category'] as String?,
      imageUrl: map['imageUrl'] as String?,
      icon: map['icon'] as String?,
      hint: map['hint'] as String?,
      unlockCondition: map['unlockCondition'] as String?,
      achievementRuleId: map['achievementRuleId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (npc != null) 'npc': npc,
      if (artist != null) 'artist': artist,
      if (chapter != null) 'chapter': chapter,
      if (duration != null) 'duration': duration,
      if (isSecret != null) 'isSecret': isSecret,
      if (visualCategory != null) 'visualCategory': visualCategory,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (icon != null) 'icon': icon,
      if (hint != null) 'hint': hint,
      if (unlockCondition != null) 'unlockCondition': unlockCondition,
      if (achievementRuleId != null) 'achievementRuleId': achievementRuleId,
    };
  }
}

class IntelItem {
  final String id;
  final IntelType type;
  final int level;
  final String title;
  final String description;
  final String? campaignId;
  final String? mediaUrl;
  final String? textContent;
  final IntelMetadata? metadata;

  IntelItem({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.description,
    this.campaignId,
    this.mediaUrl,
    this.textContent,
    this.metadata,
  });

  factory IntelItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Map remote database type names ('audio', 'video', 'image', 'text', 'document', 'meta', 'achievement')
    final String rawType = data['type'] ?? 'text';
    IntelType resolvedType;
    if (rawType == 'audio') {
      resolvedType = IntelType.audio;
    } else if (rawType == 'video' || rawType == 'image') {
      resolvedType = IntelType.visual;
    } else if (rawType == 'text' || rawType == 'document') {
      resolvedType = IntelType.text;
    } else if (rawType == 'meta' || rawType == 'achievement') {
      resolvedType = IntelType.meta;
    } else {
      resolvedType = IntelType.fromString(rawType);
    }

    final metadataMap = data['metadata'] as Map<String, dynamic>?;

    return IntelItem(
      id: doc.id,
      type: resolvedType,
      level: data['level'] is int ? data['level'] as int : (metadataMap?['level'] as num?)?.toInt() ?? 1,
      title: data['title'] ?? metadataMap?['title'] ?? data['filename'] ?? '',
      description: data['description'] ?? metadataMap?['description'] ?? '',
      campaignId: data['campaignId'],
      mediaUrl: data['url'] ?? data['mediaUrl'],
      textContent: data['textContent'],
      metadata: metadataMap != null ? IntelMetadata.fromMap(metadataMap) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    String rawType = 'text';
    switch (type) {
      case IntelType.audio:
        rawType = 'audio';
        break;
      case IntelType.visual:
        rawType = 'image';
        break;
      case IntelType.text:
        rawType = 'text';
        break;
      case IntelType.meta:
        rawType = 'meta';
        break;
    }

    return {
      'type': rawType,
      'level': level,
      'title': title,
      'description': description,
      'campaignId': campaignId,
      'url': mediaUrl,
      'textContent': textContent,
      'metadata': metadata?.toMap(),
    };
  }
}

class PlayerIntelCollection {
  final List<IntelItem> items;
  final Map<IntelType, List<IntelItem>> byType;
  final Map<int, List<IntelItem>> byLevel;
  final List<String> unlockedIds;
  final int totalCount;
  final int audioCount;
  final int visualCount;
  final int textCount;
  final int metaCount;

  PlayerIntelCollection({
    required this.items,
    required this.byType,
    required this.byLevel,
    required this.unlockedIds,
    required this.totalCount,
    required this.audioCount,
    required this.visualCount,
    required this.textCount,
    required this.metaCount,
  });

  factory PlayerIntelCollection.empty() {
    return PlayerIntelCollection(
      items: [],
      byType: {IntelType.audio: [], IntelType.visual: [], IntelType.text: [], IntelType.meta: []},
      byLevel: {1: [], 2: [], 3: [], 4: []},
      unlockedIds: [],
      totalCount: 0,
      audioCount: 0,
      visualCount: 0,
      textCount: 0,
      metaCount: 0,
    );
  }
}
