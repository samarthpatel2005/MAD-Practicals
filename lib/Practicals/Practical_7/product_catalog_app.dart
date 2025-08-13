import 'package:flutter/material.dart';

void main() => runApp(ProductCatalogApp());

// --- Cart Manager: Business Logic Unchanged ---
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _cartItems.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );
  void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
  }
  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.name == product.name);
  }
  void updateQuantity(Product product, int quantity) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );
    if (existingIndex >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(existingIndex);
      } else {
        _cartItems[existingIndex].quantity = quantity;
      }
    }
  }
  void clearCart() => _cartItems.clear();
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, required this.quantity});
}

// --- Modern Material 3 Theme ---
class ProductCatalogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: ProductCatalogScreen(),
    );
  }
}

class ProductCatalogScreen extends StatefulWidget {
  @override
  _ProductCatalogScreenState createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    List<Product> filtered =
      _selectedCategory == 'All'
        ? Product.sampleProducts
        : Product.sampleProducts
            .where((p) => p.category == _selectedCategory)
            .toList();
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Product Catalog',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.black87),
                if (_cartManager.totalItems > 0)
                  Positioned(
                    right: 0, top: 2,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text('${_cartManager.totalItems}',
                        style: TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Search Bar
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.09),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ) : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
            ),
          ),
          // Modern Category Chips
          Container(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 14),
              children: [
                for (final cat in ['All','Electronics','Fashion','Home','Sports'])
                  CategoryChip(
                    label: cat,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  ),
              ],
            ),
          ),
          // Modern Responsive Grid of Cards
          Expanded(
            child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size:64, color: Colors.grey[400]),
                      SizedBox(height: 12),
                      Text('No products found',
                        style: TextStyle(fontSize: 17, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      double childAspectRatio = 0.75;
                      if (constraints.maxWidth > 700) {
                        crossAxisCount = 3; childAspectRatio = 0.85;
                      }
                      if (constraints.maxWidth > 1100) {
                        crossAxisCount = 4; childAspectRatio = 0.9;
                      }
                      return GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                          ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, i) {
                          final product = _filteredProducts[i];
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 0.22), end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(i * 0.07, 1.0, curve: Curves.easeOutCubic),
                              ),
                            ),
                            child: FadeTransition(
                              opacity: _animationController,
                              child: ProductCard(
                                product: product,
                                onTap: () => _showProductDetails(product),
                                onAddToCart: () => _addToCart(product),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product) {
    setState(() { _cartManager.addToCart(product); });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(
        product: product,
        onAddToCart: () => _addToCart(product),
      ),
    );
  }
}

// --- Category Chip (UI Only) ---
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final grad = isSelected
      ? LinearGradient(colors:[Colors.blueAccent, Colors.blue.shade400])
      : null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 240),
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white,
          gradient: grad,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.18),
                blurRadius: 10,
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

// --- Product Card (Modern) ---
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 4,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with network URL
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    height: 120,
                    width: double.infinity,
                    errorBuilder: (_,__,___) => Container(
                      height:120,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 54, color:Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal:10, vertical:4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${product.discount}% OFF',
                        style: TextStyle(
                          color: Colors.white, fontSize:11, fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite_outline, size:16, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(13, 11, 13, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87,
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height:3),
                    Text(product.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue,
                              ),
                            ),
                            if (product.originalPrice > product.price)
                              Text(
                                '\$${product.originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(Icons.add_shopping_cart, size:16, color:Colors.white),
                          ),
                        ),
                      ],
                    )
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

// --- Product Detail Bottom Sheet (Modern) ---
class ProductDetailSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailSheet({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [BoxShadow(blurRadius: 24, color: Colors.black12)],
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top:10),
            width:40, height:4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern product image display
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      product.imageUrl,
                      height:200, width:double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(
                        height:200,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, size:72, color:Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height:15),
                  Text(product.name,
                    style: TextStyle(fontSize:24, fontWeight:FontWeight.bold, color:Colors.black87),
                  ),
                  SizedBox(height:7),
                  Chip(label: Text(product.category,
                    style: TextStyle(fontSize:15, color:Colors.blue),
                  ),
                  backgroundColor: Colors.blue.shade50, shape: StadiumBorder(),),
                  SizedBox(height:14),
                  // Price Row
                  Row(
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize:28, fontWeight:FontWeight.bold, color:Colors.blue),
                      ),
                      if (product.originalPrice > product.price) ...[
                        SizedBox(width:12),
                        Text('\$${product.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize:18,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height:17),
                  Text('Description',
                    style: TextStyle(
                      fontSize:18, fontWeight:FontWeight.bold, color: Colors.black87
                    ),
                  ),
                  SizedBox(height:7),
                  Text(product.longDescription,
                    style: TextStyle(fontSize:15, color:Colors.grey[700], height:1.55),
                  ),
                  SizedBox(height:21),
                  Row(
                    children: [
                      Icon(Icons.star, color:Colors.amber, size:20),
                      SizedBox(width:4),
                      Text('${product.rating}', style: TextStyle(fontSize:15, fontWeight:FontWeight.bold)),
                      SizedBox(width:7),
                      Text('(${product.reviews} reviews)', style: TextStyle(fontSize:13, color:Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.23), blurRadius:12, offset: Offset(0,-3)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to wishlist!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text('Add to Wishlist'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical:15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width:18),
                Expanded(
                  flex:2,
                  child: ElevatedButton(
                    onPressed: () {
                      onAddToCart();
                      Navigator.pop(context);
                    },
                    child: Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical:15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Product Model With Image URLs ---
class Product {
  final String name;
  final String description;
  final String longDescription;
  final double price;
  final double originalPrice;
  final String category;
  final String imageUrl; // <- NEW for image URLs
  final List<Color> gradientColors;
  final double rating;
  final int reviews;
  final int discount;

  Product({
    required this.name,
    required this.description,
    required this.longDescription,
    required this.price,
    required this.originalPrice,
    required this.category,
    required this.imageUrl,
    required this.gradientColors,
    required this.rating,
    required this.reviews,
    required this.discount,
  });

  static List<Product> sampleProducts = [
    Product(
      name: 'iPhone 15 Pro',
      description: 'Latest Apple smartphone',
      longDescription: 'Titanium body, A17 Pro chip etc.',
      price: 999.99,
      originalPrice: 1199.99,
      category: 'Electronics',
      imageUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-model-unselect-gallery-1-202309?wid=445&hei=891&fmt=jpeg&qlt=80&.v=1694292430131',
      gradientColors: [Colors.purple, Colors.blue],
      rating: 4.8,
      reviews: 1250,
      discount: 17,
    ),
    Product(
      name: 'Nike Air Max',
      description: 'Comfortable running shoes for all terrains',
      longDescription: 'Nike Air Max shoes provide exceptional comfort and support for runners. Features Nike Air cushioning technology and durable construction.',
      price: 129.99,
      originalPrice: 159.99,
      category: 'Sports',
      imageUrl: 'https://static.nike.com/a/images/t_PDP_864_v1/f_auto,q_auto:eco/bd279c51-1b89-466d-9d2d-49d39cd06876/air-max-90-shoes-rKtrcTo6.png',
      gradientColors: [Colors.orange, Colors.red],
      rating: 4.6,
      reviews: 890,
      discount: 19,
    ),
    Product(
      name: 'MacBook Pro M3',
      description: 'Powerful laptop for professionals',
      longDescription: 'The MacBook Pro with M3 chip delivers incredible performance for creative professionals. Features Liquid Retina XDR display and all-day battery life.',
      price: 1999.99,
      originalPrice: 2299.99,
      category: 'Electronics',
      imageUrl: 'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/mbp14-spacegray-select-202311_GEO_IN?wid=904&hei=840&fmt=jpeg&qlt=90&.v=1698701512059',
      gradientColors: [Colors.indigo, Colors.teal],
      rating: 4.9,
      reviews: 560,
      discount: 13,
    ),
    Product(
      name: 'Designer Jacket',
      description: 'Stylish winter jacket for fashion lovers',
      longDescription: 'Premium designer jacket made from high-quality materials. Perfect for cold weather with a stylish and modern design.',
      price: 249.99,
      originalPrice: 349.99,
      category: 'Fashion',
      imageUrl: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=500&q=80',
      gradientColors: [Colors.pink, Colors.purple],
      rating: 4.4,
      reviews: 320,
      discount: 29,
    ),
    Product(
      name: 'Smart Home Hub',
      description: 'Control your smart home devices',
      longDescription: 'Connect and control your IoT devices. Includes voice control and energy monitoring.',
      price: 149.99,
      originalPrice: 199.99,
      category: 'Home',
      imageUrl: 'https://images.samsung.com/is/image/samsung/assets/ae/smartthings/smart-home-hub.jpg',
      gradientColors: [Colors.green, Colors.lightGreen],
      rating: 4.5,
      reviews: 450,
      discount: 25,
    ),
    Product(
      name: 'Wireless Headphones',
      description: 'Premium audio experience',
      longDescription: 'High-quality wireless headphones with noise cancellation and premium sound quality. Long battery life and comfortable design.',
      price: 299.99,
      originalPrice: 399.99,
      category: 'Electronics',
      imageUrl: 'https://images.sony.com/is/image/gwtprod/4bd203b5d34c9b2fae344370e03452d6?fmt=png-alpha&wid=720',
      gradientColors: [Colors.deepPurple, Colors.indigo],
      rating: 4.7,
      reviews: 780,
      discount: 25,
    ),
    Product(
      name: 'Yoga Mat',
      description: 'Non-slip premium yoga mat',
      longDescription: 'Eco-friendly yoga mat with superior grip and cushioning. Perfect for yoga, pilates, and other fitness activities.',
      price: 49.99,
      originalPrice: 69.99,
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=500&q=80',
      gradientColors: [Colors.teal, Colors.cyan],
      rating: 4.3,
      reviews: 290,
      discount: 29,
    ),
    Product(
      name: 'Coffee Maker',
      description: 'Programmable coffee machine',
      longDescription: 'Programmable coffee maker with grinder and multiple brew settings for the perfect cup.',
      price: 179.99,
      originalPrice: 229.99,
      category: 'Home',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=500&q=80',
      gradientColors: [Colors.brown, Colors.orange],
      rating: 4.6,
      reviews: 340,
      discount: 22,
    ),
  ];
}

// --- Modern Cart Screen ---
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartManager _cartManager = CartManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Shopping Cart',
          style: TextStyle(color: Colors.black87,fontWeight:FontWeight.bold,fontSize:24),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          if (_cartManager.cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear Cart'),
                    content: Text('Are you sure you want to clear all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() { _cartManager.clearCart(); });
                          Navigator.pop(context);
                        },
                        child: Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Clear All'),
            ),
        ],
      ),
      body: _cartManager.cartItems.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size:80, color:Colors.grey[400]),
                SizedBox(height:20),
                Text('Your cart is empty',
                  style: TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:Colors.grey[600])),
                SizedBox(height:10),
                Text('Add some products to get started',
                  style: TextStyle(fontSize:16,color:Colors.grey[500])),
                SizedBox(height:30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Continue Shopping'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal:30, vertical:15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _cartManager.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = _cartManager.cartItems[index];
                    return CartItemWidget(
                      cartItem: cartItem,
                      onQuantityChanged: (newQ) {
                        setState(() {
                          _cartManager.updateQuantity(cartItem.product, newQ);
                        });
                      },
                      onRemove: () {
                        setState(() {
                          _cartManager.removeFromCart(cartItem.product);
                        });
                      },
                    );
                  },
                ),
              ),
              // Cart Summary
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.16),blurRadius:10,offset: Offset(0,-2))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Items:', style:TextStyle(fontSize:16,fontWeight:FontWeight.w500)),
                        Text('${_cartManager.totalItems}', style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height:10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price:', style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
                        Text('\$${_cartManager.totalPrice.toStringAsFixed(2)}', style:TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:Colors.blue)),
                      ],
                    ),
                    SizedBox(height:20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Checkout'),
                              content: Text('Order placed!\nTotal: \$${_cartManager.totalPrice.toStringAsFixed(2)}'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _cartManager.clearCart();
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context); // Go back to catalog
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical:16),
                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}

// --- Modern Cart Item Widget ---
class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom:16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                cartItem.product.imageUrl,
                width:80,height:80,fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(
                  width:80,height:80,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size:34, color:Colors.grey),
                ),
              ),
            ),
            SizedBox(width:12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem.product.name,
                    style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold,color:Colors.black87),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height:4),
                  Text(cartItem.product.category, style:TextStyle(fontSize:14,color:Colors.grey[600])),
                  SizedBox(height:8),
                  Text('\$${cartItem.product.price.toStringAsFixed(2)}',
                    style:TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:Colors.blue)),
                ],
              ),
            ),
            // Quantity controls
            Column(
              children: [
                IconButton(onPressed: onRemove, icon: Icon(Icons.delete_outline,color:Colors.red)),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (cartItem.quantity > 1)
                            onQuantityChanged(cartItem.quantity - 1);
                          else onRemove();
                        },
                        icon: Icon(Icons.remove, size: 18),
                        constraints: BoxConstraints(minWidth:30, minHeight:30),
                      ),
                      Text('${cartItem.quantity}', style:TextStyle(fontWeight:FontWeight.bold)),
                      IconButton(
                        onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                        icon: Icon(Icons.add, size: 18),
                        constraints: BoxConstraints(minWidth:30, minHeight:30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
