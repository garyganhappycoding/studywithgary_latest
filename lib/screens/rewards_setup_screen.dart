

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/reward.dart';
import '../providers/user_provider.dart';


class RewardsSetupScreen extends StatefulWidget {
  const RewardsSetupScreen({super.key});


  @override
  State<RewardsSetupScreen> createState() => _RewardsSetupScreenState();
}


class _RewardsSetupScreenState extends State<RewardsSetupScreen> {
  final List<Map<String, dynamic>> tempRewards = [];


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set Up Your Rewards'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create your reward system!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set up rewards by rarity level. Earn them from battles!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildRaritySection('Common', Colors.grey),
                const SizedBox(height: 16),
                _buildRaritySection('Rare', Colors.blue),
                const SizedBox(height: 16),
                _buildRaritySection('Epic', Colors.purple),
                const SizedBox(height: 16),
                _buildRaritySection('Legendary', Colors.orange),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveRewards,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save Rewards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildRaritySection(String rarity, Color color) {
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
              '$rarity Rewards',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._buildRewardInputs(rarity, color),
      ],
    );
  }


  List<Widget> _buildRewardInputs(String rarity, Color color) {
    final rarityLower = rarity.toLowerCase();
    final count = rarityLower == 'common'
        ? 2
        : rarityLower == 'rare'
        ? 2
        : rarityLower == 'epic'
        ? 2
        : 1;


    List<Widget> widgets = [];


    for (int i = 0; i < count; i++) {
      widgets.add(
        _RewardInput(
          rarity: rarity,
          color: color,
          index: i,
          onChanged: (title, description) {
            _updateTempReward(rarity, i, title, description);
          },
        ),
      );
      if (i < count - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }


    return widgets;
  }


  void _updateTempReward(String rarity, int index, String title, String description) {
    final key = '${rarity.toLowerCase()}_$index';
    setState(() {
      tempRewards.removeWhere((r) => r['key'] == key);
      if (title.isNotEmpty) {
        tempRewards.add({
          'key': key,
          'title': title,
          'description': description,
          'rarity': rarity,
        });
      }
    });
  }


  void _saveRewards() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);


    if (tempRewards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one reward'),
        ),
      );
      return;
    }


    for (final rewardData in tempRewards) {
      final reward = Reward(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            rewardData['key'].toString(),
        title: rewardData['title'] as String,
        description: rewardData['description'] as String,
        type: _getRarityType(rewardData['rarity'] as String),
        claimed: false,
      );
      userProvider.addReward(reward);
    }


    Navigator.pop(context);
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


class _RewardInput extends StatefulWidget {
  final String rarity;
  final Color color;
  final int index;
  final Function(String title, String description) onChanged;


  const _RewardInput({
    required this.rarity,
    required this.color,
    required this.index,
    required this.onChanged,
  });


  @override
  State<_RewardInput> createState() => _RewardInputState();
}


class _RewardInputState extends State<_RewardInput> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;


  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();


    titleController.addListener(_notifyParent);
    descriptionController.addListener(_notifyParent);
  }


  void _notifyParent() {
    widget.onChanged(titleController.text, descriptionController.text);
  }


  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.rarity} Reward ${widget.index + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Reward Name',
              hintText: 'e.g., Extra Gaming Time',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'e.g., 1 hour',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

