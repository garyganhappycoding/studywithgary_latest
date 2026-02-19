import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../main.dart'; // Make sure this path is correct
import '../models/study_session.dart';
import '../models/reward.dart';
import '../models/battle_session.dart';
import '../models/chest.dart';
import '../providers/user_provider.dart';
import '../services/background_timer_service.dart'; // Make sure this path is correct

class StudySessionScreen extends StatefulWidget {
  final VoidCallback? onStudyComplete;
  final BattleSession? battleSession;

  const StudySessionScreen({
    super.key,
    this.onStudyComplete,
    this.battleSession,
  });

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  static const int _pomodoroDurationMinutes = 25;
  static const int _shortBreakDurationMinutes = 5;
  static const int _longBreakDurationMinutes = 15;
  static const int _pomodorosBeforeLongBreak = 4;

  static const int _adjustmentIncrementMinutes = 5;
  static const int _minimumTimerMinutes = 1;

  Timer? _timer;
  int _secondsRemaining = _pomodoroDurationMinutes * 60;
  bool _isRunning = false;

  int _pomodoroCount = 0;
  bool _isBreak = false;
  bool _isLongBreak = false;
  DateTime? _sessionStartTime;
  DateTime? _pausedTime;

  int _customPomodoroDurationMinutes = _pomodoroDurationMinutes;
  int _customShortBreakMinutes = _shortBreakDurationMinutes;
  int _customLongBreakMinutes = _longBreakDurationMinutes;

  late bool _tower1Completed;
  late bool _tower2Completed;
  late bool _tower3Completed;
  late String _tower1Goal;
  late String _tower2Goal;
  late String _tower3Goal;

  BattleSession? _currentBattleSession;

  @override
  void initState() {
    super.initState();
    _currentBattleSession = widget.battleSession;

    if (_currentBattleSession != null) {
      _tower1Goal = _currentBattleSession!.tower1Goal;
      _tower2Goal = _currentBattleSession!.tower2Goal;
      _tower3Goal = _currentBattleSession!.tower3Goal;
      _tower1Completed = _currentBattleSession!.tower1Won > 0;
      _tower2Completed = _currentBattleSession!.tower2Won > 0;
      _tower3Completed = _currentBattleSession!.tower3Won > 0;
    } else {
      _tower1Goal = "Complete first objective"; // Default goal
      _tower2Goal = "Complete second objective"; // Default goal
      _tower3Goal = "Complete third objective"; // Default goal
      _tower1Completed = false;
      _tower2Completed = false;
      _tower3Completed = false;
    }
  }

  void _increaseTimer() {
    if (_isRunning) return;

    setState(() {
      _secondsRemaining += _adjustmentIncrementMinutes * 60;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⬆️ Timer increased by $_adjustmentIncrementMinutes minutes!',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _decreaseTimer() {
    if (_isRunning) return;

    final minimumSeconds = _minimumTimerMinutes * 60;

    setState(() {
      _secondsRemaining -= _adjustmentIncrementMinutes * 60;
      if (_secondsRemaining < minimumSeconds) {
        _secondsRemaining = minimumSeconds;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⬇️ Timer decreased by $_adjustmentIncrementMinutes minutes!',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      if (_sessionStartTime == null) {
        _sessionStartTime = DateTime.now();
      }
    });

    BackgroundTimerService.updateTimerInBackground(
      remainingSeconds: _secondsRemaining,
      isBreak: _isBreak,
      isLongBreak: _isLongBreak,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });

        BackgroundTimerService.updateTimerInBackground(
          remainingSeconds: _secondsRemaining,
          isBreak: _isBreak,
          isLongBreak: _isLongBreak,
        );
      } else {
        timer.cancel();
        _handleTimerEnd();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _pausedTime = DateTime.now();
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _customPomodoroDurationMinutes * 60;
      _pomodoroCount = 0;
      _isBreak = false;
      _isLongBreak = false;
      _sessionStartTime = null;
      _pausedTime = null;
    });
  }

  void _handleTimerEnd() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!_isBreak) {
      _pomodoroCount++;
      // Points from pomodoros are now part of study session addition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pomodoro #$_pomodoroCount completed!"),
          backgroundColor: Colors.green,
        ),
      );

      if (_pomodoroCount % _pomodorosBeforeLongBreak == 0) {
        _startLongBreak();
      } else {
        _startShortBreak();
      }
      _saveStudySession(userProvider, _customPomodoroDurationMinutes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Break over! Time to study."),
          backgroundColor: Colors.blue,
        ),
      );
      _startPomodoro();
    }
  }

  void _startPomodoro() {
    setState(() {
      _isBreak = false;
      _isLongBreak = false;
      _secondsRemaining = _customPomodoroDurationMinutes * 60;
    });
    _startTimer();
  }

  void _startShortBreak() {
    setState(() {
      _isBreak = true;
      _isLongBreak = false;
      _secondsRemaining = _customShortBreakMinutes * 60;
    });
    _startTimer();
  }

  void _startLongBreak() {
    setState(() {
      _isBreak = true;
      _isLongBreak = true;
      _secondsRemaining = _customLongBreakMinutes * 60;
    });
    _startTimer();
  }

  void _saveStudySession(UserProvider userProvider, int durationMinutes) {
    if (_sessionStartTime != null) {
      final session = StudySession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardId: _currentBattleSession?.id ?? 'default-card', // Using battleSession ID as cardId
        cardTitle: _currentBattleSession?.opponentName ?? 'Study Session',
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationMinutes: durationMinutes,
        completed: true,
        correctAnswers: _pomodoroCount, // Assuming pomodoros relate to correct answers
        totalQuestions: _pomodoroCount * 5, // Assuming 5 questions per pomodoro
      );
      userProvider.addStudySession(session); // This method now handles arena points
      _sessionStartTime = null; // Reset for next session
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool _areAllTowersCompleted() {
    return _tower1Completed && _tower2Completed && _tower3Completed;
  }

  void _toggleTower(int towerNumber) async { // Make async to await Firestore update
    if (_currentBattleSession == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool changed = false;

    setState(() {
      if (towerNumber == 1) {
        _tower1Completed = !_tower1Completed;
        _currentBattleSession = _currentBattleSession!.copyWith(tower1Won: _tower1Completed ? 1 : 0);
        changed = true;
      } else if (towerNumber == 2) {
        _tower2Completed = !_tower2Completed;
        _currentBattleSession = _currentBattleSession!.copyWith(tower2Won: _tower2Completed ? 1 : 0);
        changed = true;
      } else if (towerNumber == 3) {
        _tower3Completed = !_tower3Completed;
        _currentBattleSession = _currentBattleSession!.copyWith(tower3Won: _tower3Completed ? 1 : 0);
        changed = true;
      }
    });

    if (changed) {
      // Update the battle session in Firestore immediately
      await userProvider.updateBattleSession(_currentBattleSession!);

      if (_areAllTowersCompleted()) {
        _timer?.cancel();
        _isRunning = false;

        // Mark battle as completed and assign points before showing dialog
        _currentBattleSession = _currentBattleSession!.copyWith(
          completedAt: true,
          pointsAwarded: 100, // Example: 100 points for winning a battle
        );
        await userProvider.updateBattleSession(_currentBattleSession!); // Update with completed status and points

        _showBattleWonDialog(userProvider);
      }
    }
  }

  void _showBattleWonDialog(UserProvider userProvider) async { // Make async for addReward and addChest
    // ✅ FIXED: Get Reward object (always non-null now)
    final reward = userProvider.getRandomRewardFromUserCreated();

    // ✅ Add the reward to the user's inventory (persisted)
    await userProvider.addReward(reward);

    // ✅ Create a chest (persisted)
    final chest = Chest(
      rewardId: reward.id, // Associate chest with the reward ID
      rewardTitle: reward.title,
      rewardType: reward.type,
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID for the chest
      opened: false,
      createdAt: DateTime.now(),
    );
    await userProvider.addChest(chest);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Battle Won!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'All towers defeated!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You received: ${reward.title}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rarity: ${reward.type.toString().split('.').last.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: _getRewardColor(reward.type),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '🎁 Chest added to your inventory!',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endBattle();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Get color based on reward rarity
  Color _getRewardColor(RewardType type) {
    switch (type) {
      case RewardType.common:
        return Colors.grey;
      case RewardType.rare:
        return Colors.blue;
      case RewardType.epic:
        return Colors.purple;
      case RewardType.legendary:
        return Colors.orange;
      default:
        return Colors.grey; // Default color
    }
  }

  void _endBattle() async { // Make async to await Firestore update
    _timer?.cancel();
    _isRunning = false;

    BackgroundTimerService.stopBackgroundService();

    if (_currentBattleSession != null) {
      // Ensure current battle session is marked as completed if all towers are done
      // and it hasn't been marked yet. Points would have been awarded in _toggleTower
      if (_areAllTowersCompleted() && !_currentBattleSession!.completedAt) {
        _currentBattleSession = _currentBattleSession!.copyWith(
          completedAt: true,
          pointsAwarded: _currentBattleSession!.pointsAwarded == 0 ? 100 : _currentBattleSession!.pointsAwarded, // Ensure points are set if not already
        );
        await Provider.of<UserProvider>(context, listen: false).updateBattleSession(_currentBattleSession!);
      } else if (!_areAllTowersCompleted() && !_currentBattleSession!.completedAt) {
        // If battle was not won, update session without completing it
        await Provider.of<UserProvider>(context, listen: false).updateBattleSession(_currentBattleSession!);
      }
    }
    widget.onStudyComplete?.call();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to UserProvider for real-time updates to arena points
    final userProvider = Provider.of<UserProvider>(context);

    String currentMode;
    if (_isBreak && _isLongBreak) {
      currentMode = "Long Break";
    } else if (_isBreak) {
      currentMode = "Short Break";
    } else {
      currentMode = "Focus Time";
    }

    return WillPopScope(
      onWillPop: () async {
        if (!_isRunning) {
          _timer?.cancel();
          BackgroundTimerService.stopBackgroundService();
        }
        if (_currentBattleSession != null) {
          // Ensure the battle session state is saved when leaving the screen
          await Provider.of<UserProvider>(context, listen: false)
              .updateBattleSession(_currentBattleSession!);
        }
        widget.onStudyComplete?.call();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Study Session"),
          leading: BackButton(
            onPressed: () async { // Make async
              if (!_isRunning) {
                _timer?.cancel();
                BackgroundTimerService.stopBackgroundService();
              }
              if (_currentBattleSession != null) {
                await Provider.of<UserProvider>(context, listen: false)
                    .updateBattleSession(_currentBattleSession!);
              }
              widget.onStudyComplete?.call();
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Battle Towers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTowerCheckbox(
                        'Tower 1',
                        'Goal: $_tower1Goal',
                        _tower1Completed,
                            () => _toggleTower(1),
                      ),
                      const SizedBox(height: 8),
                      _buildTowerCheckbox(
                        'Tower 2',
                        'Goal: $_tower2Goal',
                        _tower2Completed,
                            () => _toggleTower(2),
                      ),
                      const SizedBox(height: 8),
                      _buildTowerCheckbox(
                        'Tower 3',
                        'Goal: $_tower3Goal',
                        _tower3Completed,
                            () => _toggleTower(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Text(
                  currentMode,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _isBreak ? Colors.green : Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy < 0) {
                      _increaseTimer();
                    } else if (details.velocity.pixelsPerSecond.dy > 0) {
                      _decreaseTimer();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isRunning
                            ? Colors.grey
                            : Colors.blue.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatTime(_secondsRemaining),
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (!_isRunning)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Swipe ⬆️/⬇️ to adjust',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _startTimer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? _pauseTimer : null,
                        icon: const Icon(Icons.pause),
                        label: const Text("Pause"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Reset"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  "Pomodoros Completed: $_pomodoroCount",
                  style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Arena Points: ${userProvider.arenaPoints}",
                  style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _endBattle,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("End Battle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTowerCheckbox(
      String title,
      String description,
      bool isCompleted,
      VoidCallback onToggle,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCompleted ? Colors.green : Colors.black,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
