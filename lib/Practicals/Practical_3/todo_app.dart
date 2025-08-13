import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _todos = [];
  late AnimationController _fabController;
  late AnimationController _headerController;
  late Animation<double> _fabAnimation;
  late Animation<double> _headerAnimation;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    
    _headerController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _addTodo() {
    String task = _controller.text.trim();
    if (task.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _todos.add({
          'task': task,
          'done': false,
          'id': DateTime.now().millisecondsSinceEpoch,
        });
        _controller.clear();
      });
      _listKey.currentState?.insertItem(_todos.length - 1);
      _fabController.forward().then((_) => _fabController.reverse());
    }
  }

  void _toggleDone(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _todos[index]['done'] = !_todos[index]['done'];
    });
  }

  void _deleteTodo(int index) {
    HapticFeedback.mediumImpact();
    final removedItem = _todos[index];
    setState(() {
      _todos.removeAt(index);
    });
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildTodoItem(removedItem, index, animation),
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todo, int index, Animation<double>? animation) {
    final slideAnimation = animation ?? const AlwaysStoppedAnimation(1.0);
    
    return SlideTransition(
      position: slideAnimation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: FadeTransition(
        opacity: slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            color: Colors.grey[850]?.withOpacity(0.8),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: todo['done'] 
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: todo['done']
                        ? [
                            const Color(0xFF4CAF50).withOpacity(0.1),
                            const Color(0xFF2E7D32).withOpacity(0.05),
                          ]
                        : [
                            Colors.grey[850]!.withOpacity(0.8),
                            Colors.grey[800]!.withOpacity(0.6),
                          ],
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          todo['done']
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          key: ValueKey(todo['done']),
                          color: todo['done']
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[400],
                          size: 28,
                        ),
                      ),
                      onPressed: () => _toggleDone(index),
                      tooltip: todo['done'] ? 'Mark as not done' : 'Mark as done',
                    ),
                  ),
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: todo['done'] ? Colors.white38 : Colors.white,
                      decoration: todo['done']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontWeight: todo['done'] ? FontWeight.w400 : FontWeight.w500,
                    ),
                    child: Text(todo['task']),
                  ),
                  trailing: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      onPressed: () => _deleteTodo(index),
                      tooltip: 'Delete Task',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -50 * (1 - _headerAnimation.value)),
              child: Opacity(
                opacity: _headerAnimation.value,
                child: const Text(
                  'TODO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _headerAnimation.value,
                child: Opacity(
                  opacity: _headerAnimation.value,
                  child: IconButton(
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white70,
                      size: 24,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Total: ${_todos.length} | Completed: ${_todos.where((t) => t['done']).length}',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          backgroundColor: const Color(0xFF2196F3),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Input Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900]?.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'What needs to be done?',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          onSubmitted: (value) => _addTodo(),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _fabAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_fabAnimation.value * 0.1),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2196F3),
                                        Color(0xFF1976D2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onPressed: _addTodo,
                                tooltip: 'Add Task',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Tasks Section
                Expanded(
                  child: _todos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1000),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (value * 0.2),
                                    child: Opacity(
                                      opacity: value,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Column(
                                          children: const [
                                            Icon(
                                              Icons.task_alt_rounded,
                                              size: 60,
                                              color: Colors.white24,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No tasks yet',
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 20,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Add your first task above',
                                              style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : AnimatedList(
                          key: _listKey,
                          initialItemCount: _todos.length,
                          itemBuilder: (context, index, animation) {
                            if (index >= _todos.length) return const SizedBox();
                            return _buildTodoItem(_todos[index], index, animation);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}