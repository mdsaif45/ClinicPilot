import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';


final referralContactsProvider = StreamProvider<List<ReferralContact>>((ref) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.referralContacts)
    ..where((t) => t.isDeleted.equals(false))
    ..orderBy([
      (t) => OrderingTerm.desc(t.referralCount),
      (t) => OrderingTerm.asc(t.name),
    ]);

  return query.watch();
});

class ReferralCrmStats {
  final int totalPartners;
  final int totalReferrals;
  final int totalVisits;
  final int activePartners;

  const ReferralCrmStats({
    required this.totalPartners,
    required this.totalReferrals,
    required this.totalVisits,
    required this.activePartners,
  });
}

final referralCrmStatsProvider = Provider<ReferralCrmStats>((ref) {
  final contacts = ref.watch(referralContactsProvider).value ?? [];

  int referrals = 0;
  int visits = 0;
  int active = 0;

  for (final c in contacts) {
    referrals += c.referralCount;
    visits += c.visitCount;
    if (c.referralCount > 0) active++;
  }

  return ReferralCrmStats(
    totalPartners: contacts.length,
    totalReferrals: referrals,
    totalVisits: visits,
    activePartners: active,
  );
});

class ReferralCrmNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ReferralCrmNotifier(this._db) : super(const AsyncData(null));

  Future<String> addContact({
    required String name,
    String? contactPerson,
    String category = 'Pharmacy',
    String? phone,
    String? address,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();

    final companion = ReferralContactsCompanion.insert(
      id: id,
      name: name.trim(),
      contactPerson: Value(contactPerson?.trim()),
      category: Value(category),
      phone: Value(phone?.trim()),
      address: Value(address?.trim()),
      notes: Value(notes?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.referralContacts).insert(companion);
    });

    return id;
  }

  Future<void> updateContact({
    required String id,
    required String name,
    String? contactPerson,
    String category = 'Pharmacy',
    String? phone,
    String? address,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.referralContacts)..where((t) => t.id.equals(id))).write(
        ReferralContactsCompanion(
          name: Value(name.trim()),
          contactPerson: Value(contactPerson?.trim()),
          category: Value(category),
          phone: Value(phone?.trim()),
          address: Value(address?.trim()),
          notes: Value(notes?.trim()),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> logOutreachVisit(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing = await (_db.select(_db.referralContacts)..where((t) => t.id.equals(id))).getSingle();
      await (_db.update(_db.referralContacts)..where((t) => t.id.equals(id))).write(
        ReferralContactsCompanion(
          visitCount: Value(existing.visitCount + 1),
          lastVisitedDate: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> incrementReferralCount(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing = await (_db.select(_db.referralContacts)..where((t) => t.id.equals(id))).getSingle();
      await (_db.update(_db.referralContacts)..where((t) => t.id.equals(id))).write(
        ReferralContactsCompanion(
          referralCount: Value(existing.referralCount + 1),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> deleteContact(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.referralContacts)..where((t) => t.id.equals(id))).write(
        ReferralContactsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }
}

final referralCrmNotifierProvider =
    StateNotifierProvider<ReferralCrmNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return ReferralCrmNotifier(db);
});
