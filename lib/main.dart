import 'package:flutter/material.dart';

void main() => runApp(const QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcards Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QuizHomePage(),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<Map<String, String>> _flashcards = [
    {'question': 'What is Flutter?', 'answer': 'An open-source UI toolkit by Google.'},
    {'question': 'What language does Flutter use?', 'answer': 'Dart programming language.'},
    {'question': 'What is a Widget?', 'answer': 'The basic building block of a Flutter UI.'},
    {'question': 'What is Hot Reload?', 'answer': 'A feature to instantly see code changes.'},
  ];

  int learnedCount = 0;
  bool _showAnswer = false;

  // ✅ Refresh the flashcards list
  Future<void> _refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _flashcards = [
        {'question': 'What is State in Flutter?', 'answer': 'Data that can change during the app’s lifetime.'},
        {'question': 'What is a StatelessWidget?', 'answer': 'A widget that does not maintain state.'},
        {'question': 'What is a StatefulWidget?', 'answer': 'A widget that maintains state.'},
        {'question': 'What is the BuildContext?', 'answer': 'A handle to the location of a widget in the widget tree.'},
      ];
      learnedCount = 0;
    });
  }

  // ✅ Add a new question dynamically
  void _addNewQuestion() {
    final newItem = {
      'question': 'New question at ${DateTime.now().toLocal()}',
      'answer': 'This question was added dynamically!',
    };
    _flashcards.insert(0, newItem);
    _listKey.currentState!.insertItem(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(), // ✅ Smooth scrolling
          slivers: [
            // ✅ Collapsing header with progress
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 140,
              backgroundColor: Colors.blueAccent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  "Learned $learnedCount of ${_flashcards.length}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            // ✅ Animated flashcards list
            SliverToBoxAdapter(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _flashcards.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index, animation) {
                  final item = _flashcards[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Dismissible(
                      key: Key(item['question']!),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _flashcards.removeAt(index);
                          learnedCount++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Marked "${item['question']}" as learned')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            item['question']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: _showAnswer
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    item['answer']!,
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text("Tap to reveal answer..."),
                                ),
                          onTap: () {
                            setState(() => _showAnswer = !_showAnswer);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ✅ Floating button to add new question
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
