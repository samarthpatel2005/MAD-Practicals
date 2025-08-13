import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(NotesApp());

class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> with TickerProviderStateMixin {
  List<Note> _notes = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool _isDarkMode = false;
  bool _rememberMe = false;
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _loadPreferences();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String> noteStrings = prefs.getStringList('notes') ?? [];
      _notes =
          noteStrings.map((noteString) => Note.fromJson(noteString)).toList();
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
    _listAnimationController.forward();
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> noteStrings = _notes.map((note) => note.toJson()).toList();
    await prefs.setStringList('notes', noteStrings);
  }

  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    await prefs.setBool('darkMode', value);
  }

  Future<void> _toggleRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = value;
    });
    await prefs.setBool('rememberMe', value);
  }

  void _showAddNoteDialog() {
    _titleController.clear();
    _contentController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    _isDarkMode
                        ? [Color(0xFF23272F), Color(0xFF181A20)]
                        : [Colors.white, Color(0xFFF8F9FA)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.note_add,
                        color: Colors.indigo,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Create New Note',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Note Title',
                    prefixIcon: Icon(Icons.title, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        _isDarkMode
                            ? Color(0xFF2A2D36).withOpacity(0.6)
                            : Colors.grey[100],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.indigo, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Note Content',
                    prefixIcon: Icon(Icons.description, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        _isDarkMode
                            ? Color(0xFF2A2D36).withOpacity(0.6)
                            : Colors.grey[100],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.indigo, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel', style: TextStyle(fontSize: 16)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addNote,
                        child: Text(
                          'Add Note',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNote() {
    if (_titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty) {
      setState(() {
        _notes.insert(
          0,
          Note(
            title:
                _titleController.text.isEmpty
                    ? 'Untitled'
                    : _titleController.text,
            content: _contentController.text,
            createdAt: DateTime.now(),
            color: _getRandomColor(),
          ),
        );
      });
      _saveNotes();
      Navigator.of(context).pop();
      HapticFeedback.lightImpact();
    }
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notes.removeAt(index);
                });
                _saveNotes();
                Navigator.of(context).pop();
                HapticFeedback.mediumImpact();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Color _getRandomColor() {
    List<Color> colors = [
      Colors.indigo,
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.blue,
      Colors.amber,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor:
            _isDarkMode ? Color(0xFF0D1117) : Color(0xFFF8F9FA),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          iconTheme: IconThemeData(
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('My Notes'),
          centerTitle: false,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: (_isDarkMode ? Colors.white : Colors.black).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    ),
                    onPressed: () => _toggleDarkMode(!_isDarkMode),
                    tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
                  ),
                  Switch(
                    value: _rememberMe,
                    onChanged: _toggleRememberMe,
                    activeColor: Colors.indigo,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Text(
                      'Remember',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  _isDarkMode
                      ? [Color(0xFF0D1117), Color(0xFF161B22)]
                      : [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Search Bar
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Color(0xFF21262D) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                // Notes Count
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredNotes.length} ${_filteredNotes.length == 1 ? 'note' : 'notes'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Notes List
                Expanded(
                  child:
                      _filteredNotes.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.note_add,
                                    size: 64,
                                    color: Colors.indigo.withOpacity(0.5),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No notes yet!'
                                      : 'No notes found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Create your first note to get started'
                                      : 'Try searching with different keywords',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _showAddNoteDialog,
                                  icon: Icon(Icons.add),
                                  label: Text('Add Note'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : AnimatedBuilder(
                            animation: _listAnimationController,
                            builder: (context, child) {
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = _filteredNotes[index];
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: _listAnimationController,
                                        curve: Interval(
                                          index * 0.1,
                                          1.0,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                    ),
                                    child: FadeTransition(
                                      opacity: _listAnimationController,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        child: Card(
                                          color:
                                              _isDarkMode
                                                  ? Color(0xFF21262D)
                                                  : Colors.white,
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Implement note editing
                                              HapticFeedback.selectionClick();
                                            },
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 4,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: note.color,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              note.title,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              note.formattedDate,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .grey[500],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuButton(
                                                        icon: Icon(
                                                          Icons.more_vert,
                                                          color: Colors.grey,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        itemBuilder:
                                                            (context) => [
                                                              PopupMenuItem(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .edit,
                                                                      size: 20,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 12,
                                                                    ),
                                                                    Text(
                                                                      'Edit',
                                                                    ),
                                                                  ],
                                                                ),
                                                                value: 'edit',
                                                              ),
                                                              PopupMenuItem(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .share,
                                                                      size: 20,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 12,
                                                                    ),
                                                                    Text(
                                                                      'Share',
                                                                    ),
                                                                  ],
                                                                ),
                                                                value: 'share',
                                                              ),
                                                              PopupMenuItem(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size: 20,
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 12,
                                                                    ),
                                                                    Text(
                                                                      'Delete',
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.red,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                value: 'delete',
                                                              ),
                                                            ],
                                                        onSelected: (value) {
                                                          if (value ==
                                                              'delete') {
                                                            _deleteNote(index);
                                                          }
                                                          // TODO: Implement edit and share functionality
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  if (note
                                                      .content
                                                      .isNotEmpty) ...[
                                                    SizedBox(height: 12),
                                                    Text(
                                                      note.content,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        height: 1.5,
                                                        color: Colors.grey[700],
                                                      ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _fabAnimationController,
              curve: Curves.elasticOut,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigoAccent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _showAddNoteDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'New Note',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Note {
  final String title;
  final String content;
  final DateTime createdAt;
  final Color color;

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
    required this.color,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String toJson() {
    return '${title}|${content}|${createdAt.millisecondsSinceEpoch}|${color.value}';
  }

  static Note fromJson(String json) {
    final parts = json.split('|');
    return Note(
      title: parts[0],
      content: parts.length > 1 ? parts[1] : '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        parts.length > 2
            ? int.parse(parts[2])
            : DateTime.now().millisecondsSinceEpoch,
      ),
      color: Color(
        parts.length > 3 ? int.parse(parts[3]) : Colors.indigo.value,
      ),
    );
  }
}
