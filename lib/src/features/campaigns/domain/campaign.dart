import 'package:cloud_firestore/cloud_firestore.dart';

enum CampaignStatus {
  ativa,
  arquivada,
  bloqueada;

  static CampaignStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'ativa':
        return CampaignStatus.ativa;
      case 'arquivada':
        return CampaignStatus.arquivada;
      case 'bloqueada':
        return CampaignStatus.bloqueada;
      default:
        return CampaignStatus.bloqueada;
    }
  }

  String toDisplayString() {
    switch (this) {
      case CampaignStatus.ativa:
        return 'Ativa';
      case CampaignStatus.arquivada:
        return 'Arquivada';
      case CampaignStatus.bloqueada:
        return 'Bloqueada';
    }
  }
}

enum PlayerType {
  walkman,
  nokia;

  static PlayerType fromString(String? type) {
    if (type == 'nokia') return PlayerType.nokia;
    return PlayerType.walkman;
  }
}

class Campaign {
  final String id;
  final String name;
  final String description;
  final String location;
  final String year;
  final String rpgSystem;
  final CampaignStatus status;
  final String imageUrl;
  final PlayerType playerType;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.year,
    required this.rpgSystem,
    required this.status,
    required this.imageUrl,
    this.playerType = PlayerType.walkman,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      year: data['year'] ?? '',
      rpgSystem: data['rpgSystem'] ?? '',
      status: CampaignStatus.fromString(data['status'] ?? 'Bloqueada'),
      imageUrl: data['imageUrl'] ?? '',
      playerType: PlayerType.fromString(data['playerType']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'year': year,
      'rpgSystem': rpgSystem,
      'status': status.toDisplayString(),
      'imageUrl': imageUrl,
      'playerType': playerType.name,
    };
  }
}
