

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/knowledge_card.dart';
import '../providers/user_provider.dart';


class KnowledgeCardDetailScreen extends StatefulWidget {
  final KnowledgeCard? card; // Null if creating a new card
  final String folderId; // Required for new cards


  const KnowledgeCardDetailScreen({
    super.key,
    this.card,
    required this.folderId,
  });


  @override
  State<KnowledgeCardDetailScreen> createState() => _KnowledgeCardDetailScreenState();
}


class _KnowledgeCardDetailScreenState extends State<KnowledgeCardDetailScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _understandingController = TextEditingController();
  final _practiceQuestionController = TextEditingController();
  final _practiceAnswerController = TextEditingController();


  late KnowledgeCard _currentCard; // Editable version of the card
  bool _isNewCard = false;


  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      // Editing an existing card
      _currentCard = widget.card!;
      _isNewCard = false;
      _titleController.text = _currentCard.title;
      _notesController.text = _currentCard.notes;
      _understandingController.text = _currentCard.understanding;
      _practiceQuestionController.text = _currentCard.practiceQuestion;
      _practiceAnswerController.text = _currentCard.practiceAnswer;
    } else {
      // Creating a new card
      _currentCard = KnowledgeCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        folderId: widget.folderId,
        title: '',
        notes: '',
        understanding: '',
        practiceQuestion: '',
        practiceAnswer: '',
        level: 1,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      _isNewCard = true;
    }


    // Add listeners to auto-save
    _titleController.addListener(_autoSave);
    _notesController.addListener(_autoSave);
    _understandingController.addListener(_autoSave);
    _practiceQuestionController.addListener(_autoSave);
    _practiceAnswerController.addListener(_autoSave);
  }


  @override
  void dispose() {
    _titleController.removeListener(_autoSave);
    _notesController.removeListener(_autoSave);
    _understandingController.removeListener(_autoSave);
    _practiceQuestionController.removeListener(_autoSave);
    _practiceAnswerController.removeListener(_autoSave);


    _titleController.dispose();
    _notesController.dispose();
    _understandingController.dispose();
    _practiceQuestionController.dispose();
    _practiceAnswerController.dispose();
    super.dispose();
  }


  void _autoSave() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);


    _currentCard = _currentCard.copyWith(
      title: _titleController.text,
      notes: _notesController.text,
      understanding: _understandingController.text,
      practiceQuestion: _practiceQuestionController.text,
      practiceAnswer: _practiceAnswerController.text,
      lastModified: DateTime.now(),
    );


    if (_isNewCard) {
      userProvider.addCard(_currentCard);
      _isNewCard = false; // Mark as no longer new after first save
    } else {
      userProvider.updateCard(_currentCard);
    }
  }


  void _levelUp() {
    setState(() {
      if (_currentCard.level < 3) {
        _currentCard = _currentCard.copyWith(level: _currentCard.level + 1);
        _autoSave(); // Save the level change
      }
    });
  }


  void _levelDown() {
    setState(() {
      if (_currentCard.level > 1) {
        _currentCard = _currentCard.copyWith(level: _currentCard.level - 1);
        _autoSave(); // Save the level change
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Final save before leaving
        _autoSave();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.card == null ? 'Create New Card' : 'Edit Card'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _autoSave(); // Save before going back
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Card Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),


              // Level Display and Control
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card Level: ${_currentCard.level}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _currentCard.level > 1 ? _levelDown : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _currentCard.level < 3 ? _levelUp : null,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 30),


              // Level 1: Notes
              Text(
                'Level 1: Learn (Main Notes)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _currentCard.level >= 1 ? Colors.deepPurple : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Enter your main notes or information here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),


              // Level 2: Understanding
              if (_currentCard.level >= 2) ...[
                Text(
                  'Level 2: Understand (Your Explanation)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _currentCard.level >= 2 ? Colors.deepPurple : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _understandingController,
                  decoration: const InputDecoration(
                    hintText: 'Explain this concept in your own words...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
              ],


              // Level 3: Practice
              if (_currentCard.level >= 3) ...[
                Text(
                  'Level 3: Practice (Self-Assessment)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _currentCard.level >= 3 ? Colors.deepPurple : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _practiceQuestionController,
                  decoration: const InputDecoration(
                    labelText: 'Your Practice Question',
                    hintText: 'e.g., What is the capital of France?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _practiceAnswerController,
                  decoration: const InputDecoration(
                    labelText: 'Your Practice Answer',
                    hintText: 'e.g., Paris',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
              ],


              // Extra padding at bottom
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

