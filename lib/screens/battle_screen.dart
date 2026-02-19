import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/battle_session.dart';
import '../providers/user_provider.dart';
import 'study_session_screen.dart';


class BattlesScreen extends StatefulWidget {
  const BattlesScreen({super.key});


  @override
  State<BattlesScreen> createState() => _BattlesScreenState();
}


class _BattlesScreenState extends State<BattlesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final battleSessions = userProvider.battleSessions;
        battleSessions.sort(
              (a, b) => b.battleTime.compareTo(a.battleTime),
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Battles')),
          body: battleSessions.isEmpty
              ? const Center(
            child: Text('No battles yet! Create one to start studying.'),
          )
              : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: battleSessions.length,
              itemBuilder: (context, index) {
                final battle = battleSessions[index];
                return BattleSessionCard(battle: battle);
              },
            ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showBattleDialog(context, userProvider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showBattleDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController goal1controller = TextEditingController();
    final TextEditingController goal2controller = TextEditingController();
    final TextEditingController goal3controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Battle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: goal1controller,
                decoration: const InputDecoration(labelText: 'Goal 1'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: goal2controller,
                decoration: const InputDecoration(labelText: 'Goal 2'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: goal3controller,
                decoration: const InputDecoration(labelText: 'Goal 3'),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tower1 = goal1controller.text;
              final tower2 = goal2controller.text;
              final tower3 = goal3controller.text;

              final battle = BattleSession(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                opponentId: 'opponent_${DateTime.now().millisecondsSinceEpoch}',
                opponentName: 'Study Battle',
                pointsAwarded: 0,
                isVictory: false,
                battleTime: DateTime.now(),
                questionsAnswered: 0,
                questionsCorrect: 0,
                tower1Goal: tower1,
                tower2Goal: tower2,
                tower3Goal: tower3,
                tower1Won: 0,
                tower2Won: 0,
                tower3Won: 0,
                focusCount: 0,
                completedAt: false,
              );
              userProvider.addBattleSession(battle);
              Navigator.pop(context);

              // Navigate to StudySessionScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudySessionScreen(battleSession: battle),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}


class BattleSessionCard extends StatelessWidget {
  final BattleSession battle;

  const BattleSessionCard({Key? key, required this.battle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          'Battle - ${battle.battleTime.toLocal().toString().split(' ')[0]}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: battle.completedAt
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            battle.completedAt ? 'Completed' : 'Incomplete',
            style: TextStyle(
              color: battle.completedAt ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTowerRow(
                  'Tower 1',
                  '${battle.tower1Goal} questions',
                  battle.tower1Won > 0,
                ),
                _buildTowerRow(
                  'Tower 2',
                  '${battle.tower2Goal} questions',
                  battle.tower2Won > 0,
                ),
                _buildTowerRow(
                  'Tower 3',
                  '${battle.tower3Goal} questions',
                  battle.tower3Won > 0,
                ),
                const SizedBox(height: 16),
                Text(
                  'Points Awarded: ${battle.pointsAwarded}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  // ✅ CHANGED: Disable button if battle is completed
                  child: ElevatedButton(
                    onPressed: battle.completedAt
                        ? null  // Disable button
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudySessionScreen(battleSession: battle),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // ✅ CHANGED: Style for disabled state
                      foregroundColor: battle.completedAt
                          ? Colors.grey
                          : Colors.black,
                    ),
                    child: Text(
                      battle.completedAt ? 'Battle Completed' : 'View / Resume Battle',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTowerRow(String title, String goal, bool won) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            won ? Icons.check_box : Icons.check_box_outline_blank,
            color: won ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: won
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  goal,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    decoration: won
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
