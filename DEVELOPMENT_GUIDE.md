# Development Guide - School Management System

## Project Architecture

This project follows **Clean Architecture** with separation of concerns:

```
lib/
├── models/          → Data structures & entities
├── providers/       → State management (ChangeNotifier)
├── services/        → Business logic & database
└── screens/         → UI components & pages
```

## Component Breakdown

### 1. Models (`lib/models/`)

Define data structures for your app.

**Example: UserModel**
```dart
class User {
  final String id;
  final String username;
  final String email;
  final String role;
  
  User({required this.id, required this.username, ...});
  
  // Convert to database map
  Map<String, dynamic> toMap() { ... }
  
  // Create from database map
  factory User.fromMap(Map<String, dynamic> map) { ... }
}
```

**Adding a New Model:**
1. Create `lib/models/your_model.dart`
2. Add `toMap()` and `fromMap()` methods
3. Add `copyWith()` for immutability

### 2. Providers (`lib/providers/`)

Manage state using ChangeNotifier pattern with Provider package.

**Example: StudentProvider**
```dart
class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  
  List<Student> get students => _students;
  
  Future<void> loadStudents() async {
    _students = await _dbService.getAllStudents();
    notifyListeners();
  }
  
  Future<void> addStudent(Student student) async {
    await _dbService.insertStudent(student);
    _students.add(student);
    notifyListeners();
  }
}
```

**Adding a New Provider:**
1. Create `lib/providers/your_provider.dart`
2. Extend `ChangeNotifier`
3. Add getters for public data
4. Call `notifyListeners()` after state changes
5. Register in `MultiProvider` in `main.dart`

### 3. Services (`lib/services/`)

Handle database and business logic.

**DatabaseService Architecture:**
- Manages SQLite connection
- Handles CRUD operations
- Manages table schemas

**Adding a New Table:**
```dart
// In _createTables method
await db.execute('''
  CREATE TABLE IF NOT EXISTS your_table (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    ...
  )
''');

// Add CRUD methods
Future<void> insertYourModel(YourModel model) async {
  final db = await database;
  await db.insert('your_table', model.toMap());
}
```

### 4. Screens (`lib/screens/`)

Build UI using Flutter widgets.

**Screen Structure:**
```dart
class YourScreen extends StatefulWidget {
  @override
  State<YourScreen> createState() => _YourScreenState();
}

class _YourScreenState extends State<YourScreen> {
  @override
  void initState() {
    super.initState();
    // Load data from providers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Title')),
      body: Consumer<YourProvider>(
        builder: (context, provider, _) {
          // Build UI using provider data
        },
      ),
    );
  }
}
```

## Common Development Tasks

### Adding a New Feature

#### Step 1: Create Model
```dart
// lib/models/your_model.dart
class YourModel {
  final String id;
  final String name;
  
  YourModel({required this.id, required this.name});
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };
  
  factory YourModel.fromMap(Map<String, dynamic> map) =>
    YourModel(id: map['id'], name: map['name']);
}
```

#### Step 2: Update Database Service
```dart
// In lib/services/database_service.dart

// In _createTables
await db.execute('''
  CREATE TABLE IF NOT EXISTS your_models (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL
  )
''');

// Add CRUD methods
Future<void> insertYourModel(YourModel model) async {
  final db = await database;
  await db.insert('your_models', model.toMap());
}

Future<List<YourModel>> getAllYourModels() async {
  final db = await database;
  final result = await db.query('your_models');
  return result.map((map) => YourModel.fromMap(map)).toList();
}
```

#### Step 3: Create Provider
```dart
// lib/providers/your_model_provider.dart
class YourModelProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<YourModel> _items = [];
  
  List<YourModel> get items => _items;
  
  Future<void> loadItems() async {
    _items = await _dbService.getAllYourModels();
    notifyListeners();
  }
  
  Future<void> addItem(YourModel item) async {
    await _dbService.insertYourModel(item);
    _items.add(item);
    notifyListeners();
  }
}
```

#### Step 4: Create Screen
```dart
// lib/screens/your_screen.dart
class YourScreen extends StatefulWidget {
  @override
  State<YourScreen> createState() => _YourScreenState();
}

class _YourScreenState extends State<YourScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<YourModelProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Feature')),
      body: Consumer<YourModelProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: provider.items
              .map((item) => ListTile(title: Text(item.name)))
              .toList(),
          );
        },
      ),
    );
  }
}
```

#### Step 5: Register Routes
```dart
// In main.dart routes
'/your-route': (context) => const YourScreen(),
```

#### Step 6: Register Provider
```dart
// In MultiProvider in main.dart
ChangeNotifierProvider(create: (_) => YourModelProvider()),
```

## State Management with Provider

### Pattern: Using Consumer
```dart
Consumer<YourProvider>(
  builder: (context, provider, child) {
    return Text(provider.items.length.toString());
  },
)
```

### Pattern: Reading Provider
```dart
final provider = context.read<YourProvider>();
provider.addItem(item);
```

### Pattern: Watching Provider (Rebuilds on change)
```dart
final provider = context.watch<YourProvider>();
```

## Database Operations

### Insert
```dart
await dbService.insertStudent(student);
```

### Read
```dart
final student = await dbService.getStudent(id);
final allStudents = await dbService.getAllStudents();
```

### Update
```dart
await dbService.updateStudent(student);
```

### Delete
```dart
await dbService.deleteStudent(id);
```

## UI Best Practices

### 1. Use Constants for Colors
```dart
const Color primaryColor = Color(0xFF1E88E5);
const Color accentColor = Color(0xFF1565C0);
```

### 2. Reusable Widgets
```dart
Widget _buildCard({required String title, required String value}) {
  return Card(
    child: ListTile(
      title: Text(title),
      subtitle: Text(value),
    ),
  );
}
```

### 3. Form Validation
```dart
TextFormField(
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'This field is required';
    }
    return null;
  },
)
```

### 4. Error Handling
```dart
try {
  await provider.operation();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Success!')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

## Navigation

### Named Routes
```dart
Navigator.pushNamed(context, '/route-name');
```

### With Arguments
```dart
Navigator.pushNamed(
  context,
  '/student-detail',
  arguments: studentId,
);
```

### Receive Arguments
```dart
final studentId = ModalRoute.of(context)?.settings.arguments as String;
```

### Pop with Result
```dart
Navigator.pop(context, result);
```

## Testing Considerations

### Unit Tests
```dart
test('addStudent should add to list', () {
  final provider = StudentProvider();
  final student = Student(...);
  provider.addStudent(student);
  expect(provider.students.length, 1);
});
```

### Widget Tests
```dart
testWidgets('StudentListScreen renders', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: StudentListScreen(),
  ));
  expect(find.byType(ListView), findsOneWidget);
});
```

## Performance Optimization

1. **Use const constructors**
   ```dart
   const SizedBox(height: 16)
   ```

2. **Lazy load data**
   ```dart
   Future.microtask(() {
     context.read<Provider>().loadData();
   });
   ```

3. **Use keys for lists**
   ```dart
   ListView(
     key: ValueKey('list'),
     children: items,
   )
   ```

4. **Limit rebuilds with selectors**
   ```dart
   Selector<YourProvider, List<Student>>(
     selector: (context, provider) => provider.students,
     builder: (context, students, _) => ...,
   )
   ```

## Debugging

### Print statements
```dart
print('Debug: ${variable}');
```

### Use debugPrint for large outputs
```dart
debugPrint('Large output: $data');
```

### Logging provider changes
```dart
@override
void notifyListeners() {
  print('Provider notified');
  super.notifyListeners();
}
```

## Code Style Guidelines

- Use meaningful variable names
- Keep methods small and focused
- Add comments for complex logic
- Use const wherever possible
- Follow dart formatting rules
  ```bash
  dart format lib/
  ```

## Common Patterns

### Initialization in StatefulWidget
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    context.read<Provider>().load();
  });
}
```

### Error Messages
```dart
if (provider.errorMessage.isNotEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(provider.errorMessage)),
  );
  provider.clearError();
}
```

### Loading State
```dart
if (provider.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### Empty State
```dart
if (provider.items.isEmpty) {
  return Center(
    child: Column(
      children: [
        const Icon(Icons.inbox, size: 64),
        const Text('No items found'),
      ],
    ),
  );
}
```

## Next Steps

1. **Study the existing code** - Understand current patterns
2. **Create a test feature** - Add a simple model
3. **Test thoroughly** - Before pushing to main
4. **Document changes** - Update README if needed
5. **Follow conventions** - Keep code consistent

---

**Happy Coding!** 🚀
