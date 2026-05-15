import 'package:cloud_firestore/cloud_firestore.dart';

class MasterAccount {
  final String uid;
  final String email;
  final String? masterName;
  final String? displayName;
  final String role;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool hasTerminalAccess;
  final bool hasMacAccess;
  final bool suspended;
  final String? notes;

  MasterAccount({
    required this.uid,
    required this.email,
    this.masterName,
    this.displayName,
    required this.role,
    this.createdAt,
    this.lastLogin,
    this.hasTerminalAccess = false,
    this.hasMacAccess = false,
    this.suspended = false,
    this.notes,
  });

  factory MasterAccount.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MasterAccount(
      uid: doc.id,
      email: data['email'] ?? '',
      masterName: data['masterName'],
      displayName: data['displayName'],
      role: data['role'] ?? 'player',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      hasTerminalAccess: data['hasTerminalAccess'] ?? false,
      hasMacAccess: data['hasMacAccess'] ?? false,
      suspended: data['suspended'] ?? false,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'masterName': masterName,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'hasTerminalAccess': hasTerminalAccess,
      'hasMacAccess': hasMacAccess,
      'suspended': suspended,
      'notes': notes,
    };
  }
}
