import 'package:flutter/material.dart';

void main() => runApp(RecipeApp());

class RecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RecipeScreen(),
    );
  }
}

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> get _filteredRecipes {
    List<Recipe> filtered =
        _selectedCategory == 'All'
            ? Recipe.sampleRecipes
            : Recipe.sampleRecipes
                .where((recipe) => recipe.category == _selectedCategory)
                .toList();

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (recipe) =>
                    recipe.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    recipe.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          'Recipe Book',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              // TODO: Show favorites
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
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

          // Category Filter
          Container(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                RecipeChip(
                  label: 'All',
                  isSelected: _selectedCategory == 'All',
                  onTap: () => setState(() => _selectedCategory = 'All'),
                ),
                RecipeChip(
                  label: 'Breakfast',
                  isSelected: _selectedCategory == 'Breakfast',
                  onTap: () => setState(() => _selectedCategory = 'Breakfast'),
                ),
                RecipeChip(
                  label: 'Lunch',
                  isSelected: _selectedCategory == 'Lunch',
                  onTap: () => setState(() => _selectedCategory = 'Lunch'),
                ),
                RecipeChip(
                  label: 'Dinner',
                  isSelected: _selectedCategory == 'Dinner',
                  onTap: () => setState(() => _selectedCategory = 'Dinner'),
                ),
                RecipeChip(
                  label: 'Dessert',
                  isSelected: _selectedCategory == 'Dessert',
                  onTap: () => setState(() => _selectedCategory = 'Dessert'),
                ),
                RecipeChip(
                  label: 'Snacks',
                  isSelected: _selectedCategory == 'Snacks',
                  onTap: () => setState(() => _selectedCategory = 'Snacks'),
                ),
              ],
            ),
          ),

          // Recipes Content
          Expanded(
            child:
                _filteredRecipes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recipes found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return _isGridView
                            ? _buildGridView()
                            : _buildListView();
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.5),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
            ),
          ),
          child: FadeTransition(
            opacity: _animationController,
            child: RecipeCard(
              recipe: recipe,
              onTap: () => _showRecipeDetails(recipe),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(-1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
            ),
          ),
          child: FadeTransition(
            opacity: _animationController,
            child: RecipeListItem(
              recipe: recipe,
              onTap: () => _showRecipeDetails(recipe),
            ),
          ),
        );
      },
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }
}

// Reusable Custom Widget - Recipe Chip
class RecipeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RecipeChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Reusable Custom Widget - Recipe Card
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({Key? key, required this.recipe, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: recipe.gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        recipe.icon,
                        size: 50,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${recipe.cookTime}m',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recipe Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 2),
                            Text(
                              '${recipe.rating}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          recipe.difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Custom Widget - Recipe List Item
class RecipeListItem extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeListItem({Key? key, required this.recipe, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: recipe.gradientColors,
                ),
              ),
              child: Center(
                child: Icon(
                  recipe.icon,
                  size: 40,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${recipe.cookTime}m',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 2),
                        Text(
                          '${recipe.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          recipe.difficulty,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recipe Detail Screen
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.green,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: recipe.gradientColors,
                  ),
                ),
                child: Center(
                  child: Icon(
                    recipe.icon,
                    size: 100,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Add to favorites
                },
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  // TODO: Share recipe
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),

                  // Recipe Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Cook Time',
                          '${recipe.cookTime}m',
                          Icons.access_time,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Difficulty',
                          recipe.difficulty,
                          Icons.trending_up,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Rating',
                          '${recipe.rating}',
                          Icons.star,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Ingredients
                  Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ...recipe.ingredients
                      .map(
                        (ingredient) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 8,
                                color: Colors.green,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  SizedBox(height: 24),

                  // Instructions
                  Text(
                    'Instructions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    int index = entry.key;
                    String instruction = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instruction,
                              style: TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// Recipe Model
class Recipe {
  final String name;
  final String description;
  final String category;
  final int cookTime;
  final String difficulty;
  final double rating;
  final IconData icon;
  final List<Color> gradientColors;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    required this.name,
    required this.description,
    required this.category,
    required this.cookTime,
    required this.difficulty,
    required this.rating,
    required this.icon,
    required this.gradientColors,
    required this.ingredients,
    required this.instructions,
  });

  static List<Recipe> sampleRecipes = [
    Recipe(
      name: 'Pancakes',
      description: 'Fluffy breakfast pancakes with maple syrup',
      category: 'Breakfast',
      cookTime: 20,
      difficulty: 'Easy',
      rating: 4.8,
      icon: Icons.breakfast_dining,
      gradientColors: [Colors.orange, Colors.amber],
      ingredients: [
        '2 cups all-purpose flour',
        '2 tablespoons sugar',
        '2 teaspoons baking powder',
        '1/2 teaspoon salt',
        '2 eggs',
        '1 3/4 cups milk',
        '1/4 cup melted butter',
      ],
      instructions: [
        'Mix dry ingredients in a large bowl',
        'Beat eggs and milk in another bowl',
        'Add wet ingredients to dry ingredients',
        'Heat pan and cook pancakes until golden',
        'Serve with maple syrup and butter',
      ],
    ),
    Recipe(
      name: 'Caesar Salad',
      description: 'Fresh romaine lettuce with Caesar dressing',
      category: 'Lunch',
      cookTime: 15,
      difficulty: 'Easy',
      rating: 4.5,
      icon: Icons.lunch_dining,
      gradientColors: [Colors.green, Colors.lightGreen],
      ingredients: [
        'Romaine lettuce',
        'Parmesan cheese',
        'Croutons',
        'Caesar dressing',
        'Anchovy fillets',
        'Lemon juice',
      ],
      instructions: [
        'Wash and chop romaine lettuce',
        'Add croutons and parmesan cheese',
        'Drizzle with Caesar dressing',
        'Toss gently and serve immediately',
      ],
    ),
    Recipe(
      name: 'Beef Stir Fry',
      description: 'Quick and healthy beef stir fry with vegetables',
      category: 'Dinner',
      cookTime: 25,
      difficulty: 'Medium',
      rating: 4.6,
      icon: Icons.dinner_dining,
      gradientColors: [Colors.red, Colors.orange],
      ingredients: [
        '1 lb beef strips',
        'Mixed vegetables',
        'Soy sauce',
        'Garlic',
        'Ginger',
        'Vegetable oil',
        'Rice for serving',
      ],
      instructions: [
        'Heat oil in wok or large pan',
        'Cook beef strips until browned',
        'Add vegetables and stir fry',
        'Add sauce and seasonings',
        'Serve over rice',
      ],
    ),
    Recipe(
      name: 'Chocolate Cake',
      description: 'Rich and moist chocolate layer cake',
      category: 'Dessert',
      cookTime: 60,
      difficulty: 'Hard',
      rating: 4.9,
      icon: Icons.cake,
      gradientColors: [Colors.brown, Colors.deepOrange],
      ingredients: [
        '2 cups flour',
        '3/4 cup cocoa powder',
        '2 cups sugar',
        '2 eggs',
        '1 cup buttermilk',
        '1/2 cup oil',
        'Chocolate frosting',
      ],
      instructions: [
        'Preheat oven to 350°F',
        'Mix dry ingredients',
        'Combine wet ingredients',
        'Mix everything together',
        'Bake for 30-35 minutes',
        'Cool and frost',
      ],
    ),
    Recipe(
      name: 'Trail Mix',
      description: 'Healthy mix of nuts, seeds, and dried fruits',
      category: 'Snacks',
      cookTime: 5,
      difficulty: 'Easy',
      rating: 4.3,
      icon: Icons.grain,
      gradientColors: [Colors.purple, Colors.indigo],
      ingredients: [
        'Mixed nuts',
        'Dried fruits',
        'Seeds',
        'Dark chocolate chips',
        'Coconut flakes',
      ],
      instructions: [
        'Combine all ingredients in a bowl',
        'Mix well',
        'Store in airtight container',
        'Enjoy as a healthy snack',
      ],
    ),
  ];
}
