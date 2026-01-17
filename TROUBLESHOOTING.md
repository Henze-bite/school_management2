# Troubleshooting Guide - School Management System

## Common Issues & Solutions

### 🔴 App Won't Start

**Error: "No route named '/login' found"**
```
Solution: Ensure all routes are defined in main.dart routes map
```

**Error: "Provider not found"**
```
Solution: Check that all Providers are registered in MultiProvider in main.dart
Make sure imports are correct
```

**Error: "Flutter package not found"**
```bash
# Run:
flutter clean
flutter pub get
flutter run
```

---

### 🔴 Build Errors

**Error: "Module not found"**
```bash
# Solution:
flutter pub get
flutter clean
flutter pub get
```

**Error: "Gradle error" (Android)**
```bash
# Solution:
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

**Error: "Build failed" (iOS)**
```bash
# Solution:
flutter clean
cd ios
rm -rf Pods
rm -rf Podfile.lock
cd ..
flutter run
```

---

### 🔴 Runtime Errors

**Error: "Unhandled Exception: type 'Null' is not a subtype"**
```
Cause: Null safety issue
Solution: Check for null values in your code, use ? operator or provide default values
Example:
  final name = student?.name ?? 'Unknown';
```

**Error: "Bad state: No element"**
```
Cause: Trying to access empty list element
Solution: Check if list is empty before accessing
Example:
  if (list.isNotEmpty) {
    final item = list.first;
  }
```

**Error: "Failed to initialize database"**
```
Solution: 
1. Check if app has storage permission
2. Try: flutter clean && flutter run
3. Delete app and reinstall
4. Check available device storage
```

---

### 🟡 Login Issues

**Problem: Can't login**
```
Solution: 
- Try any username and password (demo mode)
- No validation of credentials in demo
- Check console for error messages
```

**Problem: Session lost after app restart**
```
Solution:
- This is expected in demo mode
- In production, implement persistent storage:
  - Use flutter_secure_storage
  - Save token after login
  - Check token on app start
```

---

### 🟡 Database Issues

**Problem: Data not saving**
```
Solution:
1. Check app has storage permissions
2. Verify database is initialized
3. Check database path is writable
4. Try: adb shell pm grant com.example.school_management android.permission.WRITE_EXTERNAL_STORAGE
```

**Problem: Database locked**
```
Solution:
1. Close other connections
2. Restart app
3. In code: ensure using async operations properly
```

**Problem: Table doesn't exist**
```
Solution:
1. Clear app data: Settings → Apps → School Management → Clear Data
2. Reinstall app
3. Ensure _createTables is called in _initDatabase
```

---

### 🟡 Screen Issues

**Problem: Screen doesn't load**
```
Solution:
1. Check Future.microtask in initState
2. Verify provider is properly initialized
3. Check for exceptions in console
4. Use Consumer<Provider> correctly
```

**Problem: Data doesn't appear after adding**
```
Solution:
1. Verify notifyListeners() is called in provider
2. Check if item is actually added to list
3. Verify navigation doesn't pop before save
4. Check database.insert returned correctly
```

**Problem: Buttons not responding**
```
Solution:
1. Check if button is disabled (loading state)
2. Verify onPressed function exists
3. Check form validation isn't blocking
4. Look for errors in console
```

---

### 🟡 Navigation Issues

**Problem: Can't navigate to screen**
```
Solution:
1. Verify route is defined in main.dart
2. Check route name spelling
3. Use correct argument type if passing arguments
4. Example:
   Navigator.pushNamed(context, '/add-student');
```

**Problem: Lost arguments when navigating**
```
Solution:
1. Pass arguments properly:
   Navigator.pushNamed(
     context,
     '/student-detail',
     arguments: studentId,
   );

2. Receive correctly:
   final studentId = ModalRoute.of(context)?.settings.arguments as String;
```

**Problem: Back button goes to wrong screen**
```
Solution:
1. Use pushReplacementNamed to clear history:
   Navigator.pushReplacementNamed(context, '/home');
2. Or handle WillPopScope
```

---

### 🟡 Performance Issues

**Problem: App is slow**
```
Solution:
1. Reduce list rebuild: Use Selector<> instead of Consumer<>
2. Use const constructors: const SizedBox(height: 16)
3. Lazy load data instead of loading everything
4. Check for infinite loops in code
5. Profile with DevTools: flutter pub global activate devtools
```

**Problem: List stutters when scrolling**
```
Solution:
1. Use ListView.builder instead of ListView
2. Each item should be const if possible
3. Avoid rebuilding entire list on data change
4. Use key: ValueKey(item.id) for each item
```

**Problem: Form is slow**
```
Solution:
1. Don't rebuild entire form on every keystroke
2. Use TextEditingController instead of state variable
3. Validate only on blur, not on every character
```

---

### 🟡 State Management Issues

**Problem: Provider not updating UI**
```
Solution:
1. Verify notifyListeners() called after state change
2. Check Consumer is watching right provider
3. Verify data actually changed
4. Use debugPrint to track state changes
   debugPrint('Provider updated: ${items.length}');
```

**Problem: Widget rebuilds too often**
```
Solution:
1. Use Selector to watch only specific data:
   Selector<YourProvider, int>(
     selector: (_, provider) => provider.count,
     builder: (_, count, __) => Text('$count'),
   )
2. Use const constructors where possible
```

**Problem: Provider shows old data**
```
Solution:
1. Clear cache: context.read<Provider>().clearCache()
2. Reload data: context.read<Provider>().loadData()
3. Check if data is properly updated in database
```

---

### 🟡 Form Validation Issues

**Problem: Validation always fails**
```
Solution:
1. Check validator logic
2. Verify empty check: if (value?.isEmpty ?? true)
3. Don't call validate() too early
4. Clear previous errors before resubmitting
```

**Problem: Form submits with invalid data**
```
Solution:
1. Call formKey.currentState!.validate() first
2. Check all required fields have validators
3. Don't skip validation for any field
```

**Problem: Input field shows error incorrectly**
```
Solution:
1. Return null from validator if valid
2. Only return error message if invalid
3. Clear error when user fixes input
```

---

### 🟡 Search/Filter Issues

**Problem: Search not working**
```
Solution:
1. Verify searchStudents() is called in provider
2. Check search term is passed correctly
3. Verify list is populated before searching
4. Use case-insensitive search:
   query.toLowerCase().contains(text.toLowerCase())
```

**Problem: Results update too slowly**
```
Solution:
1. Move heavy operations to background
2. Debounce search (delay before searching)
3. Use more specific search terms
4. Index commonly searched fields
```

---

### 🟡 Delete Issues

**Problem: Can't delete items**
```
Solution:
1. Verify item ID is correct
2. Check database delete method works
3. Verify item is removed from list
4. Check if references exist (foreign keys)
5. Try: Delete in database manually, refresh UI
```

**Problem: Delete shows in database but not UI**
```
Solution:
1. Call notifyListeners() after database delete
2. Make sure item is removed from _items list
3. Refresh list view
```

---

### 🔵 UI/UX Issues

**Problem: Text overflows**
```
Solution:
1. Wrap in Expanded or Flexible
2. Use overflow: TextOverflow.ellipsis
3. Adjust font size
4. Use maxLines property
```

**Problem: Buttons too small/big**
```
Solution:
1. Use SizedBox to set dimensions
2. Adjust padding: EdgeInsets.all(16)
3. Check parent widget constraints
```

**Problem: Colors look wrong in dark mode**
```
Solution:
1. Check theme in theme_provider.dart
2. Use context colors: Theme.of(context).primaryColor
3. Don't hardcode colors for dark/light separation
```

**Problem: Keyboard hides input**
```
Solution:
1. Wrap screen in SingleChildScrollView
2. Use Column with mainAxisSize: MainAxisSize.min
3. Reduce padding/margins at bottom
4. Use focusNode.unfocus() to hide keyboard
```

---

### 🔵 Date Issues

**Problem: Date picker not working**
```
Solution:
1. Ensure context is available
2. Handle null return (user cancels)
3. Format date correctly: DateFormat('yyyy-MM-dd')
4. Verify date is valid before saving
```

**Problem: Date displayed incorrectly**
```
Solution:
1. Format consistently: DateFormat('MMMM dd, yyyy')
2. Handle timezone issues
3. Store as ISO format in database
```

---

### 🔵 Image Issues

**Problem: Image picker not working**
```
Solution:
1. Check permissions (camera/gallery)
2. Handle null when user cancels
3. Verify image_picker is installed
4. For Android: Add permissions to AndroidManifest.xml
5. For iOS: Add permissions to Info.plist
```

**Problem: Image not displaying**
```
Solution:
1. Check file path is correct
2. Verify image exists
3. Use Image.file() for local files
4. Add error handling:
   Image.file(
     File(path),
     errorBuilder: (_, __, ___) => Placeholder(),
   )
```

---

### 🆘 Debugging Tips

**Enable Debug Printing**
```dart
debugPrint('Variable value: $value');
```

**Use DevTools**
```bash
flutter pub global activate devtools
devtools
```

**Check Console for Errors**
- Look for red errors
- Check stack traces
- Use grep: `flutter run 2>&1 | grep "Error"`

**Step through Code**
- Add breakpoints in VS Code
- Use debugger to inspect variables
- Step through functions

**Log Provider Changes**
```dart
@override
void notifyListeners() {
  debugPrint('Provider ${runtimeType} notified');
  super.notifyListeners();
}
```

---

### 📞 Still Having Issues?

1. **Search this guide** - Most common issues covered
2. **Check console errors** - Often contains solution
3. **Try clean rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
4. **Check Flutter installation**:
   ```bash
   flutter doctor
   ```
5. **Review source code** - Comments explain logic
6. **Check Flutter docs** - flutter.dev

---

### 🎓 Prevention Tips

1. **Test after each change** - Don't accumulate changes
2. **Use const constructors** - Prevents rebuild issues
3. **Validate inputs** - Catch errors early
4. **Clear old data** - Delete unused records
5. **Keep databases small** - Archive old records
6. **Follow patterns** - Use existing code as template
7. **Document changes** - Remember what you did
8. **Backup regularly** - Export important data

---

### 🔧 Quick Fixes Checklist

- [ ] flutter clean
- [ ] flutter pub get
- [ ] flutter run
- [ ] Check console for errors
- [ ] Verify routes in main.dart
- [ ] Check providers are initialized
- [ ] Verify database permissions
- [ ] Try uninstalling/reinstalling app
- [ ] Check device storage space
- [ ] Update Flutter: flutter upgrade

---

**Remember**: Most issues can be solved by:**
1. Cleaning and rebuilding
2. Checking the error message carefully
3. Looking for typos in names
4. Ensuring null safety
5. Verifying all components are connected

**Happy Debugging!** 🐛🔍
