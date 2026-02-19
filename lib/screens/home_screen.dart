import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'battle_screen.dart';
import 'knowledge_cards_screen.dart';
import 'chest_screen.dart';
import 'rewards_inventory_screen.dart';
import '../providers/user_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;


  final List<Widget> _screens = [
    const DashboardTab(),
    const KnowledgeCardsScreen(),
    const BattlesScreen(),
    const ChestScreen(),
    const RewardsInventoryScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Knowledge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi),
            label: 'Battles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Chests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }
}


class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Study with Gary'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArenaCard(userProvider),
              const SizedBox(height: 24),
              _buildStatsGrid(userProvider),
              const SizedBox(height: 24),
              _buildQuickStats(userProvider),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildArenaCard(UserProvider userProvider) {
    final arena = userProvider.currentArena;
    final progress = userProvider.progressToNextArena;


    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Arena',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Arena $arena',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${userProvider.arenaPoints} Points',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber[300]!,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress to Arena ${arena + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatsGrid(UserProvider userProvider) {
    final stats = userProvider.getUserStats();


    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Cards',
          '${stats['totalCards']}',
          Icons.collections,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Battles',
          '${stats['totalBattles']}',
          Icons.sports_kabaddi,
          Colors.orange,
        ),
        _buildStatCard(
          'Unopened Chests',
          '${stats['unopenedChests']}',
          Icons.card_giftcard,
          Colors.amber,
        ),
        _buildStatCard(
          'Rewards',
          '${stats['totalChests']}',
          Icons.card_travel,
          Colors.green,
        ),
      ],
    );
  }


  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildQuickStats(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickStatRow(
          'Total Battles',
          '${userProvider.totalBattles}',
          Icons.sports_kabaddi,
        ),
        const SizedBox(height: 8),
        _buildQuickStatRow(
          'Win Rate',
          userProvider.totalBattles > 0
              ? '${((userProvider.totalBattlesWon / userProvider.totalBattles) * 100).toStringAsFixed(1)}%'
              : '0%',
          Icons.trending_up,
        ),
        const SizedBox(height: 8),
        _buildQuickStatRow(
          'Total Chests',
          '${userProvider.totalChests}',
          Icons.card_giftcard,
        ),
      ],
    );
  }


  Widget _buildQuickStatRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

