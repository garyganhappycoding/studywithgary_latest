import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

// =========================================================================
//                          IMPORT MODELS
// =========================================================================
import '../models/battle_session.dart';
import '../models/study_session.dart';
import '../models/knowledge_card.dart';
import '../models/reward.dart';
import '../models/chest.dart';
import '../models/folder.dart';

// =========================================================================
//                             USER PROVIDER
// =========================================================================

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // User basic info
  String _userId = '';
  String _displayName = '';

  // Arena & Points
  int _arenaPoints = 0;
  int _currentArena = 1;
  static const int pointsPerArena = 1000;

  // Timer & Study Stats
  int _totalStudyMinutes = 0;
  int _totalFocusSessions = 0;
  int _totalBreakSessions = 0;
  List<StudySession> _studySessions = [];

  // Battle Stats (Self-Battles Only)
  int _totalBattles = 0;
  int _totalBattlesWon = 0;
  int _totalBattlesLost = 0;
  int _battleStreak = 0;
  List<BattleSession> _battleSessions = [];

  // Cards & Rewards
  int _totalCards = 0;
  List<Folder> _folders = [];
  List<KnowledgeCard> _knowledgeCards = [];
  List<Reward> _rewards = [];
  List<Chest> _chests = [];
  int _totalChests = 0;
  int _unopenedChests = 0;

  bool _isLoading = false;

  // ============ GETTERS ============
  String get userId => _userId;
  String get displayName => _displayName;
  int get arenaPoints => _arenaPoints;
  int get currentArena => _currentArena;
  int get totalStudyMinutes => _totalStudyMinutes;
  int get totalFocusSessions => _totalFocusSessions;
  int get totalBreakSessions => _totalBreakSessions;
  List<StudySession> get studySessions => _studySessions;
  int get totalBattles => _totalBattles;
  int get totalBattlesWon => _totalBattlesWon;
  int get totalBattlesLost => _totalBattlesLost;
  int get battleStreak => _battleStreak;
  List<BattleSession> get battleSessions => _battleSessions;
  int get totalCards => _totalCards;
  List<Folder> get folders => _folders;
  List<KnowledgeCard> get knowledgeCards => _knowledgeCards;
  List<Reward> get rewards => _rewards;
  List<Chest> get chests => _chests;
  int get totalChests => _totalChests;
  int get unopenedChests => _unopenedChests;
  bool get isLoading => _isLoading;

  /// Calculate progress to next arena (0.0 to 1.0)
  double get progressToNextArena {
    final currentArenaStart = (_currentArena - 1) * pointsPerArena;
    final nextArenaStart = _currentArena * pointsPerArena;
    final pointsInCurrentArena = _arenaPoints - currentArenaStart;
    final progressInArena = pointsInCurrentArena / pointsPerArena;
    return progressInArena.clamp(0.0, 1.0);
  }

  /// Get win rate percentage
  double get winRate {
    if (_totalBattles == 0) return 0.0;
    return (_totalBattlesWon / _totalBattles) * 100;
  }

  UserProvider() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        _userId = user.uid;
        _displayName = user.displayName ?? 'User';
        loadUserData();
      } else {
        // Clear all data when user logs out
        _userId = '';
        _displayName = '';
        _arenaPoints = 0;
        _currentArena = 1;
        _totalStudyMinutes = 0;
        _totalFocusSessions = 0;
        _totalBreakSessions = 0;
        _studySessions.clear(); // Use clear() for lists
        _totalBattles = 0;
        _totalBattlesWon = 0;
        _totalBattlesLost = 0;
        _battleStreak = 0;
        _battleSessions.clear(); // Use clear() for lists
        _totalCards = 0;
        _folders.clear(); // Use clear() for lists
        _knowledgeCards.clear(); // Use clear() for lists
        _rewards.clear(); // Use clear() for lists
        _chests.clear(); // Use clear() for lists
        _totalChests = 0;
        _unopenedChests = 0;
        notifyListeners();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> loadUserData() async {
    if (_userId.isEmpty) return;

    try {
      _isLoading = true;
      notifyListeners();

      final docSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;

        _displayName = data['displayName'] ?? 'User';

        // Arena & Points
        _arenaPoints = data['arenaPoints'] ?? 0;
        _currentArena = data['currentArena'] ?? 1;

        // Study Stats
        _totalStudyMinutes = data['totalStudyMinutes'] ?? 0;
        _totalFocusSessions = data['totalFocusSessions'] ?? 0;
        _totalBreakSessions = data['totalBreakSessions'] ?? 0;
        // Map lists directly for better type safety
        _studySessions = (data['studySessions'] as List?)
            ?.map((s) => StudySession.fromMap(s as Map<String, dynamic>))
            .toList() ??
            [];

        // Battle Stats (Self-Battles Only)
        _totalBattles = data['totalBattles'] ?? 0;
        _totalBattlesWon = data['totalBattlesWon'] ?? 0;
        _totalBattlesLost = data['totalBattlesLost'] ?? 0;
        _battleStreak = data['battleStreak'] ?? 0;
        _battleSessions = (data['battleSessions'] as List?)
            ?.map((b) => BattleSession.fromMap(b as Map<String, dynamic>))
            .toList() ??
            [];

        // Cards & Rewards
        _totalCards = data['totalCards'] ?? 0;
        _folders = (data['folders'] as List?)
            ?.map((f) => Folder.fromMap(f as Map<String, dynamic>))
            .toList() ??
            [];
        _knowledgeCards = (data['knowledgeCards'] as List?)
            ?.map((c) => KnowledgeCard.fromMap(c as Map<String, dynamic>))
            .toList() ??
            [];
        _rewards = (data['rewards'] as List?)
            ?.map((r) => Reward.fromMap(r as Map<String, dynamic>))
            .toList() ??
            [];
        _chests = (data['chests'] as List?)
            ?.map((c) => Chest.fromMap(c as Map<String, dynamic>))
            .toList() ??
            [];
        _totalChests = data['totalChests'] ?? 0;
        _unopenedChests = data['unopenedChests'] ?? 0;

      } else {
        // Create new user document if doesn't exist
        await _createNewUserDocument();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user data: $e');
      _isLoading = false;
      notifyListeners();
      // Optionally rethrow or handle error more gracefully
    }
  }

  /// Create new user document on first login
  Future<void> _createNewUserDocument() async {
    if (_userId.isEmpty) return; // Should not happen if _firebaseAuth listener works
    try {
      await _firestore.collection('users').doc(_userId).set({
        // Basic Info
        'displayName': _displayName,
        'userId': _userId,

        // Arena & Points
        'arenaPoints': 0,
        'currentArena': 1,

        // Study Stats
        'totalStudyMinutes': 0,
        'totalFocusSessions': 0,
        'totalBreakSessions': 0,
        'studySessions': [],

        // Battle Stats (Self-Battles Only)
        'totalBattles': 0,
        'totalBattlesWon': 0,
        'totalBattlesLost': 0,
        'battleStreak': 0,
        'battleSessions': [],

        // Cards & Rewards
        'totalCards': 0,
        'folders': [],
        'knowledgeCards': [],
        'rewards': [], // Initialize as empty list
        'totalChests': 0,
        'unopenedChests': 0,
        'chests': [], // Initialize as empty list

        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge: true to avoid overwriting existing data if any

      // Reset local state to match newly created document
      _arenaPoints = 0;
      _currentArena = 1;
      _totalStudyMinutes = 0;
      _totalFocusSessions = 0;
      _totalBreakSessions = 0;
      _studySessions.clear();
      _totalBattles = 0;
      _totalBattlesWon = 0;
      _totalBattlesLost = 0;
      _battleStreak = 0;
      _battleSessions.clear();
      _totalCards = 0;
      _folders.clear();
      _knowledgeCards.clear();
      _rewards.clear();
      _chests.clear();
      _totalChests = 0;
      _unopenedChests = 0;

      print('✅ New user document created for $_userId');
      notifyListeners();
    } catch (e) {
      print('❌ Error creating user document: $e');
      // Optionally rethrow or handle error more gracefully
    }
  }

  // ============ TIMER & STUDY METHODS ============

  /// Add a study session
  Future<void> addStudySession(StudySession session) async {
    if (_userId.isEmpty) return;
    try {
      _studySessions.add(session);
      _totalStudyMinutes += session.durationMinutes;

      // Logic to determine focus vs. break session
      // This part might need refinement based on how you differentiate them in the UI
      // For now, assuming any session is a 'focus' session for points
      _totalFocusSessions++; // Increment focus for any completed session for simplicity
      int pointsEarned = (session.durationMinutes / 5).round() * 10; // Example: 10 points per 5 mins
      await addArenaPoints(pointsEarned);
      print('✅ Study session completed: +$pointsEarned points');

      await _firestore.collection('users').doc(_userId).update({
        'studySessions': _studySessions.map((s) => s.toMap()).toList(),
        'totalStudyMinutes': _totalStudyMinutes,
        'totalFocusSessions': _totalFocusSessions,
        'totalBreakSessions': _totalBreakSessions, // Update this if you track break sessions explicitly
        'arenaPoints': _arenaPoints, // Update arena points here since addArenaPoints updates it locally
        'currentArena': _currentArena, // Also update currentArena
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      print('❌ Error adding study session: $e');
    }
  }

  // ============ ARENA & POINTS METHODS ============

  /// Add arena points and check for arena level up
  Future<void> addArenaPoints(int points) async {
    if (_userId.isEmpty) return;
    try {
      _arenaPoints += points;
      _updateArenaIfNeeded(); // Update local state first

      // Firestore update will happen from the calling function if needed,
      // or here if it's a standalone points addition.
      // For now, let's keep it here for any direct calls.
      await _firestore.collection('users').doc(_userId).update({
        'arenaPoints': _arenaPoints,
        'currentArena': _currentArena,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      print('❌ Error adding arena points: $e');
    }
  }

  /// Update arena based on points
  void _updateArenaIfNeeded() {
    int newArena = (_arenaPoints ~/ pointsPerArena) + 1;
    if (newArena > _currentArena) {
      _currentArena = newArena;
      print('🎉 Arena level up! Now in Arena $_currentArena');
    }
  }

  /// Get user stats (for home screen)
  Map<String, dynamic> getUserStats() {
    return {
      'totalStudyMinutes': _totalStudyMinutes,
      'totalFocusSessions': _totalFocusSessions,
      'totalBreakSessions': _totalBreakSessions,
      'totalBattles': _totalBattles,
      'totalBattlesWon': _totalBattlesWon,
      'totalBattlesLost': _totalBattlesLost,
      'battleStreak': _battleStreak,
      'winRate': winRate,
      'arenaPoints': _arenaPoints,
      'currentArena': _currentArena,
      'totalCards': _totalCards,
      'totalChests': _totalChests,
      'unopenedChests': _unopenedChests,
    };
  }

  // ============ BATTLE METHODS (SELF-BATTLES ONLY) ============

  /// Add a new battle session
  Future<void> addBattleSession(BattleSession battle) async {
    if (_userId.isEmpty) return;
    try {
      _battleSessions.add(battle);
      _totalBattles++;

      if (battle.isVictory) {
        _totalBattlesWon++;
        _battleStreak++;
        // Points are now added via updateBattleSession for completed battles,
        // or by other means if victory is declared earlier.
      } else {
        _totalBattlesLost++;
        _battleStreak = 0;
      }

      await _firestore.collection('users').doc(_userId).update({
        'battleSessions': _battleSessions.map((b) => b.toMap()).toList(),
        'totalBattles': _totalBattles,
        'totalBattlesWon': _totalBattlesWon,
        'totalBattlesLost': _totalBattlesLost,
        'battleStreak': _battleStreak,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      print('❌ Error adding battle session: $e');
    }
  }

  /// Update an existing battle session
  Future<void> updateBattleSession(BattleSession updatedBattle) async {
    if (_userId.isEmpty) return;
    try {
      final index = _battleSessions.indexWhere((b) => b.id == updatedBattle.id);
      if (index != -1) {
        // Check if completion status changed and points need to be awarded
        bool wasNotCompleted = !_battleSessions[index].completedAt;
        _battleSessions[index] = updatedBattle; // Update local list

        // ✅ NEW: If battle is now completed AND points are set, add them
        if (wasNotCompleted && updatedBattle.completedAt && updatedBattle.pointsAwarded > 0) {
          await addArenaPoints(updatedBattle.pointsAwarded); // This also updates Firestore
          print('✅ Battle points awarded: +${updatedBattle.pointsAwarded}');
        }

        // Only update Firestore for battleSessions and lastUpdated here
        await _firestore.collection('users').doc(_userId).update({
          'battleSessions': _battleSessions.map((b) => b.toMap()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print('✅ Battle session updated: ${updatedBattle.id}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error updating battle session: $e');
    }
  }

  // ============ KNOWLEDGE CARDS & FOLDERS METHODS ============

  /// Add a new folder
  Future<void> addFolder(String folderName) async {
    if (_userId.isEmpty) return;
    try {
      final newFolder = Folder(id: DateTime.now().millisecondsSinceEpoch.toString(), name: folderName); // Ensure ID is generated
      _folders.add(newFolder);

      await _firestore.collection('users').doc(_userId).update({
        'folders': _folders.map((f) => f.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Folder "$folderName" added.');
      notifyListeners();
    } catch (e) {
      print('❌ Error adding folder: $e');
    }
  }

  /// Delete a folder and all its cards
  Future<void> deleteFolder(String folderId) async {
    if (_userId.isEmpty) return;
    try {
      _folders.removeWhere((folder) => folder.id == folderId);
      final cardsToDeleteCount = _knowledgeCards.where((card) => card.folderId == folderId).length;
      _knowledgeCards.removeWhere((card) => card.folderId == folderId);
      _totalCards -= cardsToDeleteCount;

      await _firestore.collection('users').doc(_userId).update({
        'folders': _folders.map((f) => f.toMap()).toList(),
        'knowledgeCards': _knowledgeCards.map((c) => c.toMap()).toList(), // Update cards too
        'totalCards': _totalCards,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Folder and its cards deleted. Remaining cards: $_totalCards');
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting folder: $e');
    }
  }

  /// Add a knowledge card
  Future<void> addCard(KnowledgeCard card) async {
    if (_userId.isEmpty) return;
    try {
      _knowledgeCards.add(card);
      _totalCards++;

      await _firestore.collection('users').doc(_userId).update({
        'knowledgeCards': _knowledgeCards.map((c) => c.toMap()).toList(),
        'totalCards': _totalCards,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Knowledge card added. Total: $_totalCards');
      notifyListeners();
    } catch (e) {
      print('❌ Error adding knowledge card: $e');
    }
  }

  /// Update an existing knowledge card
  Future<void> updateCard(KnowledgeCard updatedCard) async {
    if (_userId.isEmpty) return;
    try {
      final index = _knowledgeCards.indexWhere((card) => card.id == updatedCard.id);
      if (index != -1) {
        _knowledgeCards[index] = updatedCard;

        await _firestore.collection('users').doc(_userId).update({
          'knowledgeCards': _knowledgeCards.map((c) => c.toMap()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print('✅ Knowledge card updated: ${updatedCard.id}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error updating knowledge card: $e');
    }
  }

  /// Delete a knowledge card
  Future<void> deleteCard(String cardId) async {
    if (_userId.isEmpty) return;
    try {
      _knowledgeCards.removeWhere((card) => card.id == cardId);
      _totalCards--;

      await _firestore.collection('users').doc(_userId).update({
        'knowledgeCards': _knowledgeCards.map((c) => c.toMap()).toList(),
        'totalCards': _totalCards,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Knowledge card deleted. Total: $_totalCards');
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting knowledge card: $e');
    }
  }

  /// Get cards in a specific folder
  List<KnowledgeCard> getCardsInFolder(String folderId) {
    return _knowledgeCards.where((card) => card.folderId == folderId).toList();
  }

  /// Toggle folder expanded state (local UI state only, not persisted to Firestore for simplicity)
  void toggleFolderExpanded(String folderId) {
    final index = _folders.indexWhere((folder) => folder.id == folderId);
    if (index != -1) {
      _folders[index].isExpanded = !_folders[index].isExpanded;
      notifyListeners();
      // If you want to persist this, you'd add a Firestore update here.
    }
  }

  // ============ CHEST & REWARDS METHODS ============

  /// Add a chest
  Future<void> addChest(Chest chest) async {
    if (_userId.isEmpty) return;
    try {
      _totalChests++;
      _unopenedChests++;
      _chests.add(chest);

      await _firestore.collection('users').doc(_userId).update({
        'chests': _chests.map((c) => c.toMap()).toList(),
        'totalChests': _totalChests,
        'unopenedChests': _unopenedChests,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Chest added! Total: $_totalChests, Unopened: $_unopenedChests');
      notifyListeners();
    } catch (e) {
      print('❌ Error adding chest: $e');
    }
  }

  /// Delete a chest
  Future<void> deleteChest(String chestId) async {
    if (_userId.isEmpty) return;
    try {
      final chestIndex = _chests.indexWhere((c) => c.id == chestId);
      if (chestIndex != -1) {
        if (!_chests[chestIndex].opened) {
          _unopenedChests--;
        }
        _chests.removeAt(chestIndex);
        _totalChests--; // Decrement total chests as well

        await _firestore.collection('users').doc(_userId).update({
          'chests': _chests.map((c) => c.toMap()).toList(),
          'totalChests': _totalChests,
          'unopenedChests': _unopenedChests,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print('✅ Chest deleted');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error deleting chest: $e');
    }
  }

  /// Open a chest and get the reward inside. This marks the chest as opened.
  /// The *reward itself* is added to the user's inventory by `addReward` later.
  Future<Reward?> openChest(String chestId) async {
    if (_userId.isEmpty) return null;
    try {
      final chestIndex = _chests.indexWhere((c) => c.id == chestId);
      if (chestIndex != -1) {
        final chest = _chests[chestIndex];

        // Find the reward that was associated with this chest (from the user's rewards list).
        // If the specific reward was deleted or never properly added, create a generic one.
        final reward = _rewards.firstWhere(
              (r) => r.id == chest.rewardId,
          orElse: () => Reward( // Fallback if reward not found in _rewards list (unlikely if logic is consistent)
            id: chest.rewardId,
            title: chest.rewardTitle,
            description: 'A reward from an opened chest!',
            type: chest.rewardType,
          ),
        );

        // Mark the chest as opened locally
        _chests[chestIndex] = _chests[chestIndex].copyWith(
          opened: true,
          openedAt: DateTime.now(),
        );
        _unopenedChests--;

        // Update Firestore for chests and unopened count
        await _firestore.collection('users').doc(_userId).update({
          'chests': _chests.map((c) => c.toMap()).toList(),
          'unopenedChests': _unopenedChests,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print('✅ Chest opened! Reward: ${reward.title}, Unopened remaining: $_unopenedChests');
        notifyListeners();
        return reward;
      }
    } catch (e) {
      print('❌ Error opening chest: $e');
    }
    return null;
  }

  /// Add a reward to inventory. This is usually called AFTER a chest is opened
  /// and the user chooses to claim the reward.
  Future<void> addReward(Reward reward) async {
    if (_userId.isEmpty) return;
    try {
      // ✅ FIX: Prevent duplicate rewards based on ID
      final existingRewardIndex = _rewards.indexWhere((r) => r.id == reward.id);
      if (existingRewardIndex == -1) {
        // Only add if it's a new reward, otherwise update it
        _rewards.add(reward);
      } else {
        // If reward with same ID exists, update it (e.g., if description or type changed)
        _rewards[existingRewardIndex] = reward;
      }

      await _firestore.collection('users').doc(_userId).update({
        'rewards': _rewards.map((r) => r.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Reward added/updated: ${reward.title}');
      notifyListeners();
    } catch (e) {
      print('❌ Error adding reward: $e');
    }
  }

  /// Claim a reward (sets claimed to true)
  Future<void> claimReward(String rewardId) async {
    if (_userId.isEmpty) return;
    try {
      final index = _rewards.indexWhere((r) => r.id == rewardId);
      if (index != -1) {
        _rewards[index] = _rewards[index].copyWith(claimed: true);

        await _firestore.collection('users').doc(_userId).update({
          'rewards': _rewards.map((r) => r.toMap()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print('✅ Reward claimed: ${_rewards[index].title}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error claiming reward: $e');
    }
  }

  /// Unclaim a reward (sets claimed to false)
  Future<void> unclaimReward(String rewardId) async {
    if (_userId.isEmpty) return;
    try {
      final index = _rewards.indexWhere((r) => r.id == rewardId);
      if (index != -1) {
        _rewards[index] = _rewards[index].copyWith(claimed: false);

        await _firestore.collection('users').doc(_userId).update({
          'rewards': _rewards.map((r) => r.toMap()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print('✅ Reward unclaimed: ${_rewards[index].title}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error unclaiming reward: $e');
    }
  }

  /// Delete a reward
  Future<void> deleteReward(String rewardId) async {
    if (_userId.isEmpty) return;
    try {
      _rewards.removeWhere((reward) => reward.id == rewardId);

      await _firestore.collection('users').doc(_userId).update({
        'rewards': _rewards.map((r) => r.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Reward deleted');
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting reward: $e');
    }
  }

  /// Get a random reward from user-created rewards, ensuring it's non-null.
  /// If no user-created rewards exist, a generic fallback reward is returned.
  Reward getRandomRewardFromUserCreated() {
    if (_rewards.isEmpty) {
      print('⚠️ No user-created rewards found. Using fallback reward.');
      return Reward(
        id: 'fallback_reward_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Mystery Reward',
        description: 'A mystery reward from the depths of your study!',
        type: RewardType.common,
      );
    }

    final Random random = Random();
    final randomReward = _rewards[random.nextInt(_rewards.length)];

    print('✅ Random reward selected: ${randomReward.title}');
    return randomReward;
  }

  /// Refresh user data manually
  Future<void> refreshUserData() async {
    await loadUserData();
  }

  /// Clear all local state (useful for logout)
  void clearState() {
    _userId = '';
    _displayName = '';
    _arenaPoints = 0;
    _currentArena = 1;
    _totalStudyMinutes = 0;
    _totalFocusSessions = 0;
    _totalBreakSessions = 0;
    _studySessions.clear();
    _totalBattles = 0;
    _totalBattlesWon = 0;
    _totalBattlesLost = 0;
    _battleStreak = 0;
    _battleSessions.clear();
    _totalCards = 0;
    _folders.clear();
    _knowledgeCards.clear();
    _rewards.clear();
    _chests.clear();
    _totalChests = 0;
    _unopenedChests = 0;
    _isLoading = false;
    notifyListeners();
  }
}
