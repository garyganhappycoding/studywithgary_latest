

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/reward.dart';
import '../providers/user_provider.dart';


class RewardsInventoryScreen extends StatefulWidget {
  const RewardsInventoryScreen({super.key});


  @override
  State<RewardsInventoryScreen> createState() => _RewardsInventoryScreenState();
}


class _RewardsInventoryScreenState extends State<RewardsInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards'),
      ),
      body: userProvider.rewards.isEmpty
          ? _buildEmptyState()
          : _buildRewardsList(userProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRewardDialog(context, userProvider);
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
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
            'No rewards yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your rewards to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRewardsList(UserProvider userProvider) {
    final commonRewards =
    userProvider.rewards.where((r) => r.type == RewardType.common).toList();
    final rareRewards =
    userProvider.rewards.where((r) => r.type == RewardType.rare).toList();
    final epicRewards =
    userProvider.rewards.where((r) => r.type == RewardType.epic).toList();
    final legendaryRewards = userProvider.rewards
        .where((r) => r.type == RewardType.legendary)
        .toList();


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (commonRewards.isNotEmpty) ...[
              _buildRaritySection(
                'Common Rewards',
                commonRewards,
                Colors.grey,
                userProvider,
              ),
              const SizedBox(height: 24),
            ],
            if (rareRewards.isNotEmpty) ...[
              _buildRaritySection(
                'Rare Rewards',
                rareRewards,
                Colors.blue,
                userProvider,
              ),
              const SizedBox(height: 24),
            ],
            if (epicRewards.isNotEmpty) ...[
              _buildRaritySection(
                'Epic Rewards',
                epicRewards,
                Colors.purple,
                userProvider,
              ),
              const SizedBox(height: 24),
            ],
            if (legendaryRewards.isNotEmpty) ...[
              _buildRaritySection(
                'Legendary Rewards',
                legendaryRewards,
                Colors.orange,
                userProvider,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildRaritySection(
      String title,
      List<dynamic> rewards,
      Color color,
      UserProvider userProvider,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              '${rewards.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rewards.map((reward) {
          return _buildRewardCard(reward, userProvider, color);
        }),
      ],
    );
  }


  Widget _buildRewardCard(
      dynamic reward,
      UserProvider userProvider,
      Color color,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (reward.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          reward.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  userProvider.deleteReward(reward.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reward deleted'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showAddRewardDialog(BuildContext context, UserProvider userProvider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedRarity = 'common';


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reward'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Reward Name',
                  hintText: 'e.g., Extra Gaming Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., 1 hour',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedRarity,
                  decoration: InputDecoration(
                    labelText: 'Rarity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'common', child: Text('Common')),
                    DropdownMenuItem(value: 'rare', child: Text('Rare')),
                    DropdownMenuItem(value: 'epic', child: Text('Epic')),
                    DropdownMenuItem(
                        value: 'legendary', child: Text('Legendary')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRarity = value ?? 'common';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final reward = Reward(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  type: _getRarityType(selectedRarity),
                  claimed: false,
                );
                userProvider.addReward(reward);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }


  RewardType _getRarityType(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return RewardType.common;
      case 'rare':
        return RewardType.rare;
      case 'epic':
        return RewardType.epic;
      case 'legendary':
        return RewardType.legendary;
      default:
        return RewardType.common;
    }
  }
}

