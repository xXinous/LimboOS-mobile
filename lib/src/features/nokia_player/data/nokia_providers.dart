import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/intel_item.dart';
import '../domain/nokia_sms.dart';
import 'intel_repository.dart';
import '../../campaigns/data/active_campaign_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../../characters/data/character_providers.dart';

part 'nokia_providers.g.dart';

enum NokiaScreen {
  player,
  profile,
  scanner,
  smsDetail,
}

@Riverpod(keepAlive: true)
class NokiaScreenState extends _$NokiaScreenState {
  @override
  NokiaScreen build() => NokiaScreen.player;

  void setScreen(NokiaScreen screen) {
    state = screen;
  }
}

@Riverpod(keepAlive: true)
class NokiaVolume extends _$NokiaVolume {
  @override
  int build() => 80;

  void setVolume(int value) {
    state = value.clamp(0, 100);
  }
}

@Riverpod(keepAlive: true)
class NokiaMute extends _$NokiaMute {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void setMute(bool value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
class ActiveAudioIntel extends _$ActiveAudioIntel {
  @override
  IntelItem? build() => null;

  void select(IntelItem item) {
    state = item;
  }

  void clear() {
    state = null;
  }
}

enum NokiaAudioStatus {
  idle,
  loading,
  loaded,
  playing,
  rewinding,
}

@Riverpod(keepAlive: true)
class NokiaAudioPlaybackStatus extends _$NokiaAudioPlaybackStatus {
  @override
  NokiaAudioStatus build() => NokiaAudioStatus.idle;

  void setStatus(NokiaAudioStatus status) {
    state = status;
  }
}

@Riverpod(keepAlive: true)
class NokiaActiveSms extends _$NokiaActiveSms {
  @override
  NokiaSms? build() => null;

  void select(NokiaSms sms) {
    state = sms;
  }

  void clear() {
    state = null;
  }
}

@Riverpod(keepAlive: true)
class NokiaSmsList extends _$NokiaSmsList {
  StreamSubscription? _groupsSub;
  final Map<String, StreamSubscription> _messageSubs = {};
  final Map<String, List<Map<String, dynamic>>> _messagesByGroup = {};

  @override
  List<NokiaSms> build() {
    _listenToGroups();
    ref.onDispose(() {
      _groupsSub?.cancel();
      for (var sub in _messageSubs.values) {
        sub.cancel();
      }
    });
    return [];
  }

  void _listenToGroups() {
    final auth = ref.watch(authStateChangesProvider).value;
    final character = ref.watch(activeCharacterProvider);
    if (auth == null || character == null) return;

    final db = FirebaseFirestore.instance;
    _groupsSub = db
        .collection('groups')
        .where('playerUids', arrayContains: auth.uid)
        .snapshots()
        .listen((groupSnap) {
      
      final currentGroupIds = groupSnap.docs.map((d) => d.id).toSet();
      
      final removed = _messageSubs.keys.where((id) => !currentGroupIds.contains(id)).toList();
      for (final id in removed) {
        _messageSubs[id]?.cancel();
        _messageSubs.remove(id);
        _messagesByGroup.remove(id);
      }

      for (final doc in groupSnap.docs) {
        if (!_messageSubs.containsKey(doc.id)) {
          _messageSubs[doc.id] = db
              .collection('groups')
              .doc(doc.id)
              .collection('messages')
              .snapshots()
              .listen((msgSnap) {
            _messagesByGroup[doc.id] = msgSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
            _rebuildState(character.id);
          });
        }
      }
      _rebuildState(character.id);
    });
  }

  void _rebuildState(String activeCharacterId) {
    final allMessages = _messagesByGroup.values.expand((x) => x).toList();
    
    final relevant = allMessages.where((msg) => 
       msg['recipientId'] == null || 
       msg['recipientId'] == activeCharacterId || 
       msg['senderId'] == activeCharacterId
    ).toList();

    relevant.sort((a, b) {
      final tsA = a['createdAt'] != null && a['createdAt'] is Timestamp ? a['createdAt'].millisecondsSinceEpoch : 0;
      final tsB = b['createdAt'] != null && b['createdAt'] is Timestamp ? b['createdAt'].millisecondsSinceEpoch : 0;
      return tsA.compareTo(tsB);
    });

    final Map<String, List<NokiaMessage>> messagesMap = {};

    for (final msg in relevant) {
      String contactId = '';

      if (msg['senderId'] == activeCharacterId) {
        if (msg['recipientId'] == null) continue;
        // As of the GroupService fix, player messages now have the NPC correctly set in recipientId
        contactId = msg['recipientId'];
      } else {
        contactId = msg['senderId'] ?? 'unknown';
      }

      final ts = msg['createdAt'];
      final millis = ts != null && ts is Timestamp ? ts.millisecondsSinceEpoch : 0;
      
      String dateStr = 'Agora';
      if (ts != null && ts is Timestamp) {
        final dt = ts.toDate();
        dateStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      
      final nokiaMsg = NokiaMessage(
        id: msg['id'],
        senderId: msg['senderId'] ?? 'unknown',
        senderName: msg['senderName'] ?? 'DESCONHECIDO',
        text: msg['text'] ?? '',
        time: dateStr,
        timestamp: millis,
        isMe: msg['senderId'] == activeCharacterId,
      );

      if (!messagesMap.containsKey(contactId)) {
        messagesMap[contactId] = [];
      }
      messagesMap[contactId]!.add(nokiaMsg);
    }

    final Map<String, NokiaSms> convMap = {};
    for (final entry in messagesMap.entries) {
      final contactId = entry.key;
      final msgs = entry.value;
      
      msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final latestMsg = msgs.last;
      
      String contactName = 'DESCONHECIDO';
      final receivedMsg = msgs.where((m) => !m.isMe).firstOrNull;
      if (receivedMsg != null) {
        contactName = receivedMsg.senderName;
      } else {
        final msgData = relevant.where((m) => m['recipientId'] == contactId).firstOrNull;
        if (msgData != null) {
          contactName = msgData['recipientName'] ?? 'DESCONHECIDO';
        }
      }

      final textPrefix = latestMsg.isMe ? 'VOCÊ: ' : '';

      final sms = NokiaSms(
        id: contactId,
        sender: contactName,
        text: textPrefix + latestMsg.text,
        time: latestMsg.time,
        read: false,
        messages: msgs,
      );
      
      convMap[contactId] = sms;
    }

    final sortedList = convMap.values.toList();
    sortedList.sort((a, b) => b.messages.last.timestamp.compareTo(a.messages.last.timestamp));
    
    // Preservar read state: O(1) por lookup via Map em vez de O(n) por item
    final readStateMap = <String, bool>{
      for (final sms in state) sms.id: sms.read,
    };
    state = sortedList.map((newSms) {
      final wasRead = readStateMap[newSms.id];
      return wasRead != null ? newSms.copyWith(read: wasRead) : newSms;
    }).toList();
  }

  void markAsRead(String id) {
    state = [
      for (final sms in state)
        if (sms.id == id) sms.copyWith(read: true) else sms,
    ];
  }
}

@Riverpod(keepAlive: true)
Stream<List<String>> unlockedIntelIds(UnlockedIntelIdsRef ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  final character = ref.watch(activeCharacterProvider);
  if (authState == null || character == null) {
    return Stream.value([]);
  }
  final intelRepo = ref.watch(intelRepositoryProvider);
  return intelRepo.watchUnlockedIntelIds(authState.uid, character.id);
}

@Riverpod(keepAlive: true)
Stream<List<IntelItem>> campaignIntelList(CampaignIntelListRef ref) {
  final intelRepo = ref.watch(intelRepositoryProvider);
  final activeCampaign = ref.watch(activeCampaignProvider).value;
  final unlockedIdsAsync = ref.watch(unlockedIntelIdsProvider);
  
  // Exposes a stream of all media assets from Firestore
  return intelRepo.watchAllMediaAssets().map((allMedia) {
    if (activeCampaign == null) return [];
    final unlockedIds = unlockedIdsAsync.value ?? [];
    
    // localIntelItems é constante: a concatenação é feita uma vez por snapshot Firestore,
    // mas a lista local nunca muda — considerável como custo fixo aceitável.
    final combinedMedia = [...allMedia, ...localIntelItems];
    
    // Filter to show only items matching active campaign AND are unlocked by this character
    return combinedMedia
        .where((item) =>
            (item.campaignId == null || item.campaignId == activeCampaign.id) &&
            unlockedIds.contains(item.id))
        .toList();
  });
}
