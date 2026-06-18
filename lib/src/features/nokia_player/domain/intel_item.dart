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

final List<IntelItem> localIntelItems = [
  IntelItem(
    id: 'evidence-disk-01-corrupted',
    type: IntelType.text,
    level: 3,
    title: 'ARQUIVO_CORROMPIDO',
    description: 'Um disquete ilegível. As trilhas magnéticas estão destruídas.',
    textContent: '''S̸e̵ ̸o̸n̵d̴a̷ ̶s̵o̵n̶o̶r̶a̷ ̷a̶t̶i̵n̷g̷e̸ ̴∇̸ ̴∞̵ ̵n̷o̵ ̵m̶i̶l̶i̴s̸s̶e̵g̷u̴n̸d̸o̵ ̴d̵o̵ ̷e̶r̵r̵o̸ ̶t̴e̵m̴p̶o̶r̵a̵l̴.̶.̶.̷
O̵ ̵█̶█̶█̶█̶█̶█̶█̶█̶█̶█̶ ̷n̵ã̷o̵ ̷é̴ ̵l̵i̵n̴h̷a̴.̵ ̶É̸ ̴u̶m̸ ̷l̶o̵o̵p̸ ̷d̵e̴ ̶c̵ó̸d̵i̴g̵o̵.̶
1̷9̶0̶0̶ ̶▒̶░̶▓̶ ̶E̷R̷R̴O̷ ̸S̷I̸N̸T̸A̶X̵E̴ ̴▓̸░̸▒̸ ̶2̶0̶0̶0̵
A̶c̶h̷a̸m̴ ̴q̴u̷e̷ ̵é̶ ̵b̴u̷g̷ ̸c̷a̵l̶e̷n̸d̸á̷r̸i̴o̷.̸ ̵I̵d̴i̷o̷t̶a̵s̸.̵
L̸I̶M̵B̶O̷_̴0̶1̵ ̶é̶ ̶f̵e̵n̶d̴a̷.̸ ̶█̶█̶█̶█̶█̶█̶█̶ ̸v̵i̵v̶e̵ ̵n̷o̴ ̶e̵s̶p̵a̶ç̶o̵ ̷e̷n̷t̸r̵e̷ ̷z̶e̶r̶o̴s̸.̵
S̵e̴ ̶a̶l̴i̵m̵e̵n̴t̶a̸ ̸d̷e̴ ̴s̶i̵n̵a̵l̵.̶ ̶O̴d̴e̷i̴a̸ ̶a̷n̷a̷l̸ó̵g̵i̶c̸o̸.̸ ̷F̸i̵t̸a̸ ̸é̶ ̸â̷n̶c̶o̸r̶a̶.̶
C̷á̴l̶c̶u̵l̸o̸ ̴t̵r̶a̷n̶s̴i̷ç̸ã̶o̴:̷
(̵E̶ ̸≠ ̷h̷*̸f̴)̷ ̶/̵ █̶▓̶▒̶░̵▄̵▀̶▒̵▓̶█̶ ̵∇̵∞̶ ̵∂̷Ω̶∑̸ ̶¥̸§̷ÿ̷¢̶¿̶ ̶█̶▀̶▄̷█̴▓̷▒̷ ̸R̸E̵A̷L̷I̴D̴A̶D̵E̴ ̸O̴U̵T̴R̶A̷ ̵▒̵▓̴█̸▄̵▀̴ ̷█̴▓̷▒̷ ̵S̵Ω̸Λ̷M̷∂̴ ̸█̶█̶█̶█̶█̶█̶█̶█̶ ̶▓̴▒̸░̷ ̶A̸ ̵C̸ ̸E̷ ̸S̴ ̵S̵ ̵O̵ ̶▓̴▒̷█̴▀̸▄̵ ̵█̶▓̶▒̸ ̴S̵Ω̷Λ̸M̸∂̶ ̸░̷▄̶▀̷▒̷▓̵█̸ ̴∇̷∞̴ ̵∂̸Ω̶∑̴ ̸¥̵§̸ÿ̸¢̸¿̵ ̴█̴▀̵▄̵█̴▓̶▒̶ ̷R̷E̸A̷L̵I̴D̴A̴D̵E̴ ̵O̵U̸T̵R̶A̶ ̸▒̸▓̸█̴▄̵▀̴ ̵
S̵e̷ ̴e̷u̷ ̶s̸u̷m̷i̶r̶,̴ ̶f̴r̶e̵q̵u̶ê̵n̵c̵i̶a̶ ̵f̶u̶n̶c̸i̶o̸n̶o̷u̷.̶
M̶e̷ ̷a̵c̵h̴e̶m̷ ̴n̶o̵ ̵z̴e̴r̶o̵.''',
    metadata: IntelMetadata(
      npc: 'Desconhecido',
      artist: 'Desconhecido',
      chapter: 'Ameaças',
    ),
  ),
  IntelItem(
    id: 'evidence-disk-01',
    type: IntelType.text,
    level: 2,
    title: 'DISK_REPAIRED_01',
    description: 'Um disquete magnético recuperado e desmagnetizado.',
    textContent: '''A Teoria das Cordas diz que existem 11 dimensões, mas todo mundo está ignorando o óbvio: o zero é a ponte.
Eu percebi que o que está acontecendo agora é uma colisão. É a minha frequência analógica (do walkman mesmo) batendo de frente com esse "reset" digital do Bug do Milênio. Se a onda sonora atingir o infinito no exato milisegundo em que o erro temporal acontecer... a gente vai ver a verdade.
O Multiverso não é uma linha reta, como ensinam na escola. É um loop de código. 1900 foi um erro de sintaxe. 2000 é o próximo.
O LIMBO_01 é a fenda que abriu. E o Malware... ele não é um vírus comum. Ele é algo que vive no espaço "entre" os zeros. Ele se alimenta de sinal, por isso ele odeia tudo o que é analógico. A fita cassete é a minha única âncora aqui.
Cálculo de transição: (E=h⋅f)/Y2K_Bug=ACESSO
Se eu sumir hoje, significa que a frequência funcionou. Não me procurem no futuro. Me achem no zero.''',
    metadata: IntelMetadata(
      npc: 'Desconhecido',
      artist: 'Analog_Traveler',
      chapter: 'Evidências',
    ),
  ),
];
