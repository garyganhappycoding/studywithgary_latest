import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/reward.dart';
import '../models/chest.dart';
import '../providers/user_provider.dart';

class ChestScreen extends StatefulWidget {
  const ChestScreen({super.key});

  @override
  State<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends State<ChestScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chests'),
      ),
      body: userProvider.chests.isEmpty
          ? _buildEmptyState()
          : _buildChestsList(userProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No chests yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Earn chests by completing battles!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChestsList(UserProvider userProvider) {
    final unopened = userProvider.chests.where((c) => !c.opened).toList();
    final opened = userProvider.chests.where((c) => c.opened).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unopened.isNotEmpty) ...[
              const Text(
                'Unopened Chests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...unopened.map((chest) {
                return _buildChestCard(chest, userProvider, isOpened: false);
              }),
              const SizedBox(height: 24),
            ],
            if (opened.isNotEmpty) ...[
              const Text(
                'Opened Chests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              ...opened.map((chest) {
                return _buildChestCard(chest, userProvider, isOpened: true);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(RewardType type) {
    switch (type) {
      case RewardType.common:
        return Colors.grey;
      case RewardType.rare:
        return Colors.blue;
      case RewardType.epic:
        return Colors.purple;
      case RewardType.legendary:
        return Colors.orange;
    }
  }

  Widget _buildChestCard(
      Chest chest,
      UserProvider userProvider, {
        required bool isOpened,
      }) {
    final rarityColor = _getRarityColor(chest.rewardType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isOpened
              ? rarityColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOpened ? rarityColor : Colors.grey[400]!,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: isOpened ? rarityColor : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOpened
                          ? chest.rewardTitle // ✅ NOW SHOWS ACTUAL REWARD TITLE
                          : "A mystery reward!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOpened ? rarityColor : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOpened
                          ? 'Opened at ${chest.openedAt?.toString().split('.')[0]}'
                          : '${chest.rewardType.toString().split('.').last.toUpperCase()} chest',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isOpened)
                ElevatedButton.icon(
                  onPressed: () {
                    userProvider.openChest(chest.id);
                  },
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rarityColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
