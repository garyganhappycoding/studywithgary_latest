import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/reward.dart';
import '../providers/user_provider.dart';




class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});


  @override
  State<RewardScreen> createState() => _RewardScreenState();
}


class _RewardScreenState extends State<RewardScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
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
            'Add a reward to get started!',
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
    // Group rewards by rarity
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
      List<Reward> rewards,
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
              '${rewards.where((r) => r.claimed).length}/${rewards.length}',
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
      Reward reward,
      UserProvider userProvider,
      Color color,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: reward.claimed ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: reward.claimed ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: reward.claimed,
                onChanged: (value) {
                  if (value == true) {
                    userProvider.claimReward(reward.id);
                  } else {
                    userProvider.unclaimReward(reward.id);
                  }
                },
                activeColor: color,
              ),
              const SizedBox(width: 12),
              // Reward details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: reward.claimed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: reward.claimed ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (reward.description.isNotEmpty)
                      Text(
                        reward.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          decoration: reward.claimed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Delete button
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () {
                      userProvider.deleteReward(reward.id);
                    },
                  ),
                ],
                child: Icon(Icons.more_vert, color: Colors.grey[600]),
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
    RewardType selectedType = RewardType.common;


    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Reward'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reward Title
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Reward Name',
                    hintText: 'e.g., Extra Study Break',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Reward Description
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g., 30 minutes free time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                // Rarity Selection
                const Text(
                  'Rarity Level',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRarityButton(
                      label: 'Common',
                      type: RewardType.common,
                      color: Colors.grey,
                      isSelected: selectedType == RewardType.common,
                      onTap: () => setState(() => selectedType = RewardType.common),
                    ),
                    _buildRarityButton(
                      label: 'Rare',
                      type: RewardType.rare,
                      color: Colors.blue,
                      isSelected: selectedType == RewardType.rare,
                      onTap: () => setState(() => selectedType = RewardType.rare),
                    ),
                    _buildRarityButton(
                      label: 'Epic',
                      type: RewardType.epic,
                      color: Colors.purple,
                      isSelected: selectedType == RewardType.epic,
                      onTap: () => setState(() => selectedType = RewardType.epic),
                    ),
                    _buildRarityButton(
                      label: 'Legendary',
                      type: RewardType.legendary,
                      color: Colors.orange,
                      isSelected: selectedType == RewardType.legendary,
                      onTap: () =>
                          setState(() => selectedType = RewardType.legendary),
                    ),
                  ],
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
                    type: selectedType,
                    claimed: false,
                  );
                  userProvider.addReward(reward);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reward name'),
                    ),
                  );
                }
              },
              child: const Text('Add Reward'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRarityButton({
    required String label,
    required RewardType type,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

