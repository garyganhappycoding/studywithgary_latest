import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Assuming UserProvider is in main.dart
import '../models/knowledge_card.dart';
import '../models/knowledge_folder.dart';
import 'knowledge_card_detail_screen.dart'; // Import the new screen
import '../providers/user_provider.dart';


class KnowledgeCardsScreen extends StatefulWidget {
  const KnowledgeCardsScreen({super.key});


  @override
  State<KnowledgeCardsScreen> createState() => _KnowledgeCardsScreenState();
}


class _KnowledgeCardsScreenState extends State<KnowledgeCardsScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Cards'),
        centerTitle: true,
      ),
      body: userProvider.folders.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        itemCount: userProvider.folders.length,
        itemBuilder: (context, index) {
          final folder = userProvider.folders[index];
          final cardsInFolder = userProvider.getCardsInFolder(folder.id);


          return ExpansionTile(
            title: Text(folder.name),
            subtitle: Text('${cardsInFolder.length} cards'),
            onExpansionChanged: (isExpanded) {
              userProvider.toggleFolderExpanded(folder.id);
            },
            initiallyExpanded: folder.isExpanded,
            // ADD DELETE FOLDER OPTION
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteFolderConfirmation(
                      context, folder.id, folder.name, userProvider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Folder'),
                ),
              ],
            ),
            children: [
              // Add Card Button for the folder
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              KnowledgeCardDetailScreen(
                                folderId: folder.id,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Card'),
                  ),
                ),
              ),
              // List of cards in the folder
              ...cardsInFolder.map((card) {
                return GestureDetector(
                  onTap: () {
                    // OPEN CARD DIRECTLY WHEN TAPPED
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KnowledgeCardDetailScreen(
                          card: card,
                          folderId: folder.id,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        card.title.isEmpty ? 'Untitled Card' : card.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Notes: ${card.notes.isNotEmpty ? card.notes.substring(0, card.notes.length > 50 ? 50 : card.notes.length) + (card.notes.length > 50 ? '...' : '') : 'No main notes yet'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildLevelBadge(card.level),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteCardConfirmation(
                                context, card.id, userProvider);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete Card'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFolderDialog(context),
        tooltip: 'Add New Folder',
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }


  // Helper method to build level badge
  Widget _buildLevelBadge(int level) {
    String levelText;
    Color color;
    switch (level) {
      case 1:
        levelText = 'Level 1: Learn';
        color = Colors.blue;
        break;
      case 2:
        levelText = 'Level 2: Understand';
        color = Colors.green;
        break;
      case 3:
        levelText = 'Level 3: Practice';
        color = Colors.orange;
        break;
      default:
        levelText = 'Level $level';
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        levelText,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }


  // Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Knowledge Folders yet!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddFolderDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Folder'),
          ),
        ],
      ),
    );
  }


  // Dialog for adding a new folder
  void _showAddFolderDialog(BuildContext context) {
    final folderNameController = TextEditingController();
    final folderDescriptionController = TextEditingController();


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: folderNameController,
                decoration: const InputDecoration(labelText: 'Folder Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: folderDescriptionController,
                decoration:
                const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (folderNameController.text.isNotEmpty) {
                  Provider.of<UserProvider>(context, listen: false).addFolder(
                    folderNameController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }


  // DELETE FOLDER CONFIRMATION DIALOG
  void _showDeleteFolderConfirmation(BuildContext context, String folderId,
      String folderName, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Folder?'),
          content: Text(
              'Are you sure you want to delete "$folderName"? All cards in this folder will be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                userProvider.deleteFolder(folderId);
                Navigator.pop(context);
                // Show snackbar confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Folder "$folderName" deleted'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  // Delete card confirmation dialog
  void _showDeleteCardConfirmation(
      BuildContext context, String cardId, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Card?'),
          content: const Text('Are you sure you want to delete this card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                userProvider.deleteCard(cardId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

