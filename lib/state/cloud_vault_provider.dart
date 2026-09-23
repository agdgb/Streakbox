import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/cloud_vault_service.dart';
import 'repository_provider.dart';

final cloudVaultServiceProvider = Provider<CloudVaultService>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return CloudVaultService(repository: repository);
});

class CloudVaultNotifier extends Notifier<CloudVaultState> {
  @override
  CloudVaultState build() {
    return const CloudVaultState();
  }

  void toggleAutoBackup(bool enabled) {
    state = state.copyWith(isAutoBackupEnabled: enabled);
  }

  Future<String> backupNow() async {
    state = state.copyWith(isSyncing: true, lastError: null);
    try {
      final service = ref.read(cloudVaultServiceProvider);
      final jsonString = await service.createVaultSnapshot();
      final repository = ref.read(habitRepositoryProvider);
      final habits = await repository.getAllHabits();
      final entries = await repository.getAllEntries();

      state = state.copyWith(
        isSyncing: false,
        lastBackupTime: DateTime.now(),
        totalHabitsBackedUp: habits.length,
        totalEntriesBackedUp: entries.length,
      );
      return jsonString;
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastError: e.toString());
      rethrow;
    }
  }

  Future<({int habitsRestored, int entriesRestored})> restoreFromSnapshot(
    String jsonString, {
    bool overwrite = false,
  }) async {
    state = state.copyWith(isSyncing: true, lastError: null);
    try {
      final service = ref.read(cloudVaultServiceProvider);
      final result = await service.restoreVaultSnapshot(jsonString, overwriteExisting: overwrite);

      state = state.copyWith(
        isSyncing: false,
        lastBackupTime: DateTime.now(),
        totalHabitsBackedUp: result.habitsRestored,
        totalEntriesBackedUp: result.entriesRestored,
      );
      return result;
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastError: e.toString());
      rethrow;
    }
  }

  Future<int> syncToCloud(String userId) async {
    state = state.copyWith(isSyncing: true, lastError: null);
    try {
      final service = ref.read(cloudVaultServiceProvider);
      final count = await service.syncToFirestore(userId);
      state = state.copyWith(
        isSyncing: false,
        lastBackupTime: DateTime.now(),
        totalHabitsBackedUp: count,
      );
      return count;
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastError: e.toString());
      rethrow;
    }
  }

  Future<({int habitsRestored, int entriesRestored})?> syncFromCloud(
    String userId, {
    bool overwrite = false,
  }) async {
    state = state.copyWith(isSyncing: true, lastError: null);
    try {
      final service = ref.read(cloudVaultServiceProvider);
      final result = await service.syncFromFirestore(userId, overwrite: overwrite);
      if (result != null) {
        state = state.copyWith(
          isSyncing: false,
          lastBackupTime: DateTime.now(),
          totalHabitsBackedUp: result.habitsRestored,
          totalEntriesBackedUp: result.entriesRestored,
        );
      } else {
        state = state.copyWith(isSyncing: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastError: e.toString());
      rethrow;
    }
  }
}

final cloudVaultProvider = NotifierProvider<CloudVaultNotifier, CloudVaultState>(
  CloudVaultNotifier.new,
);
