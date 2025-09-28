// import 'package:device_apps/device_apps.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'app_selection_screen.dart';

// void main() {
//   runApp(const StudyModeApp());
// }

// // The root widget of the application.
// class StudyModeApp extends StatelessWidget {
//   const StudyModeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
   

//     // Defines the visual styling for the light mode.
//     final ThemeData lightTheme = ThemeData(
//       useMaterial3: true,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.blue,
//         brightness: Brightness.light,
//         primary: Colors.blue.shade800,
//         background: const Color(0xFFF8F9FA), // Lighter, cleaner background
//         surface: Colors.white,
//         secondary: Colors.blueGrey.shade600,
//         onPrimary: Colors.white,
//         onSurface: Colors.black87,
//       ),
//       textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
//       appBarTheme: AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.blue.shade800,
//         elevation: 1,
//         centerTitle: true,
//         titleTextStyle: GoogleFonts.inter(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: Colors.blue.shade800,
//         ),
//       ),
//       cardTheme: CardThemeData(
//         elevation: 2,
//         shadowColor: Colors.black12,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         color: Colors.white,
//       ),
//       switchTheme: SwitchThemeData(
//         thumbColor: MaterialStateProperty.all(Colors.white),
//         trackColor: MaterialStateProperty.resolveWith((states) {
//           if (states.contains(MaterialState.selected)) {
//             return Colors.blue.shade700;
//           }
//           return Colors.grey.shade400;
//         }),
//       ),
//     );

//     // Defines the visual styling for the dark mode.
//     final ThemeData darkTheme = ThemeData(
//       useMaterial3: true,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.teal,
//         brightness: Brightness.dark,
//         primary: Colors.tealAccent.shade400,
//         background: const Color(0xFF121212), // Standard dark background
//         surface: const Color(0xFF1E1E1E), // Darker card background
//         secondary: Colors.blueGrey.shade300,
//         onPrimary: Colors.black,
//         onSurface: Colors.white70,
//       ),
//       textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
//       appBarTheme: AppBarTheme(
//         backgroundColor: const Color(0xFF1E1E1E),
//         foregroundColor: Colors.tealAccent.shade400,
//         elevation: 1,
//         centerTitle: true,
//         titleTextStyle: GoogleFonts.inter(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: Colors.tealAccent.shade400,
//         ),
//       ),
//       cardTheme: CardThemeData(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         color: const Color(0xFF1E1E1E),
//       ),
//       switchTheme: SwitchThemeData(
//         thumbColor: MaterialStateProperty.all(const Color(0xFF1E1E1E)),
//         trackColor: MaterialStateProperty.resolveWith((states) {
//           if (states.contains(MaterialState.selected)) {
//             return Colors.tealAccent.shade400;
//           }
//           return Colors.grey.shade700;
//         }),
//       ),
//     );

//     //  BUILD THE MATERIAL APP
//     return MaterialApp(
//       title: 'Study Mode App',
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: ThemeMode.system, // Adapt to system's light/dark mode setting.
//       home: const StudyModeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// // The main screen of the application.
// class StudyModeScreen extends StatefulWidget {
//   const StudyModeScreen({super.key});

//   @override
//   State<StudyModeScreen> createState() => _StudyModeScreenState();
// }

// class _StudyModeScreenState extends State<StudyModeScreen>
//     with TickerProviderStateMixin {
//   // Channel for communicating with native Android code.
//   static const platform = MethodChannel('study_mode_channel');

//   // STATE VARIABLES
//   bool _isStudyModeEnabled = false;
//   bool _hasPermissions = false;
//   List<Application> _selectedApps = []; // Holds user-selected apps to block.

//   // ANIMATION CONTROLLERS
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimation();
//     _initializeState(); // Use a single initialization method
//   }

//   Future<void> _initializeState() async {
//     await _checkPermissions();
//     await _handleFirstLaunch(); // Check for first launch and set state
//     await _loadSelectedApps(); // Load saved app selection
//   }

//   Future<void> _handleFirstLaunch() async {
//     final prefs = await SharedPreferences.getInstance();
//     // If 'is_first_launch' is null (doesn't exist), it's the first launch.
//     final bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

//     if (isFirstLaunch) {
//       // On first launch, ensure Study Mode is OFF on both Flutter and native sides.
//       await platform.invokeMethod('setStudyMode', {
//         'enabled': false,
//         'blockedPackages': [],
//       });

//       if (mounted) {
//         setState(() {
//           _isStudyModeEnabled = false;
//         });
//       }
//       // Mark that the first launch has been completed.
//       await prefs.setBool('is_first_launch', false);
//     } else {
//       // If it's not the first launch, load the state from the native side as usual.
//       _loadStudyModeState();
//     }
//   }

//   // Loads the list of selected apps from shared preferences.
//   Future<void> _loadSelectedApps() async {
//     final prefs = await SharedPreferences.getInstance();
//     final packageNames = prefs.getStringList('blocked_apps') ?? [];

//     List<Application> apps = [];
//     for (String packageName in packageNames) {
//       // Fetch app details for each package name, including its icon.
//       final app = await DeviceApps.getApp(packageName, true);
//       if (app != null) {
//         apps.add(app);
//       }
//     }

//     // Update UI with the loaded apps.
//     if (mounted) {
//       setState(() {
//         _selectedApps = apps;
//       });
//     }
//   }

//   // Sets up the button animation controller.
//   void _initializeAnimation() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.1,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   // Asks the native side if necessary permissions are granted.
//   Future<void> _checkPermissions() async {
//     try {
//       final bool hasPermissions =
//           await platform.invokeMethod('checkPermissions');
//       if (mounted) {
//         setState(() {
//           _hasPermissions = hasPermissions;
//         });
//       }
//     } on PlatformException catch (e) {
//       print("Failed to check permissions: '${e.message}'.");
//     }
//   }

//   // Triggers the native permission request flow.
//   Future<void> _requestPermissions() async {
//     try {
//       await platform.invokeMethod('requestPermissions');
//       await _checkPermissions(); // Re-check after requesting.
//     } on PlatformException catch (e) {
//       print("Failed to request permissions: '${e.message}'.");
//     }
//   }

//   // Fetches the current study mode state from the native side.
//   Future<void> _loadStudyModeState() async {
//     try {
//       final bool isEnabled = await platform.invokeMethod('getStudyModeState');
//       if (mounted) {
//         setState(() {
//           _isStudyModeEnabled = isEnabled;
//         });
//       }
//     } on PlatformException catch (e) {
//       print("Failed to load study mode state: '${e.message}'.");
//     }
//   }

//   // Toggles study mode on/off and sends the app list to the native side.
//   Future<void> _toggleStudyMode() async {
//     if (!_hasPermissions) {
//       _showPermissionDialog();
//       return;
//     }

//     try {
//       _animationController.forward().then((_) {
//         _animationController.reverse();
//       });

//       final bool newState = !_isStudyModeEnabled;

//       // Get package names from the selected apps list.
//       final List<String> packagesToBlock =
//           _selectedApps.map((app) => app.packageName).toList();

//       // Send the new state and app list to the native code.
//       await platform.invokeMethod('setStudyMode', {
//         'enabled': newState,
//         'blockedPackages': packagesToBlock,
//       });

//       if (mounted) {
//         setState(() {
//           _isStudyModeEnabled = newState;
//         });
//       }

//       _showStatusSnackBar();
//     } on PlatformException catch (e) {
//       print("Failed to toggle study mode: '${e.message}'.");
//       _showErrorSnackBar();
//     }
//   }

//   // Navigates to the app selection screen.
//   void _navigateToAppSelection() async {
//     // Wait for the selection screen to close, then reload the app list.
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AppSelectionScreen()),
//     );
//     _loadSelectedApps();
//   }

//   // Displays a dialog explaining why permissions are needed.
//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Permissions Required'),
//           content: const Text(
//             'This app needs special permissions to block other apps. '
//             'Please grant the required permissions to use Study Mode.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _requestPermissions();
//               },
//               child: const Text('Grant'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Shows a confirmation snackbar when the mode changes.
//   void _showStatusSnackBar() {
//     final message = _isStudyModeEnabled
//         ? 'Study Mode ON: Distractions blocked!'
//         : 'Study Mode OFF: All apps are accessible.';

//     final color = _isStudyModeEnabled
//         ? Theme.of(context).colorScheme.primary
//         : Colors.green.shade600;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(10),
//       ),
//     );
//   }

//   // Shows an error snackbar if the native call fails.
//   void _showErrorSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Failed to toggle Study Mode. Please try again.',
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(10),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // NEW: Get colors from the theme for consistent UI
//     final Color activeColor = Theme.of(context).colorScheme.primary;
//     final Color inactiveColor = Theme.of(context).colorScheme.secondary;
//     final Color textColor = Theme.of(context).colorScheme.onSurface;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Focus Mode'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.checklist_rtl_rounded),
//             onPressed: _navigateToAppSelection,
//             tooltip: 'Select Apps to Block',
//           ),
//         ],
//       ),
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               //  Status Card 
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     children: [
//                       Icon(
//                         _isStudyModeEnabled
//                             ? Icons.shield_rounded
//                             : Icons.gpp_good_outlined,
//                         size: 64,
//                         color:
//                             _isStudyModeEnabled ? activeColor : inactiveColor,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Focus Mode',
//                         style: Theme.of(context)
//                             .textTheme
//                             .headlineMedium
//                             ?.copyWith(
//                                 fontWeight: FontWeight.bold, color: textColor),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _isStudyModeEnabled ? 'ACTIVE' : 'INACTIVE',
//                         style: Theme.of(context)
//                             .textTheme
//                             .headlineSmall
//                             ?.copyWith(
//                               color: _isStudyModeEnabled
//                                   ? activeColor
//                                   : inactiveColor,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.2,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               //  Toggle Switch Card 
//               ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Card(
//                   child: ListTile(
//                     contentPadding:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//                     leading: Icon(
//                       Icons.power_settings_new_rounded,
//                       color: textColor.withOpacity(0.7),
//                     ),
//                     title: Text(
//                       'Activate Focus Mode',
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium
//                           ?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: textColor,
//                           ),
//                     ),
//                     trailing: Switch(
//                       value: _isStudyModeEnabled,
//                       onChanged: (value) => _toggleStudyMode(),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               //  Blocked Apps List Card 
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Blocked Apps',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleLarge
//                             ?.copyWith(
//                                 fontWeight: FontWeight.bold, color: textColor),
//                       ),
//                       const SizedBox(height: 16),
//                       _selectedApps.isEmpty
//                           ? Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 24.0),
//                               child: Text(
//                                 'No apps selected to block.\nTap the checklist icon above to choose.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: inactiveColor, height: 1.5),
//                               ),
//                             )
//                           : ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: _selectedApps.length,
//                               itemBuilder: (context, index) {
//                                 final app = _selectedApps[index]
//                                     as ApplicationWithIcon;
//                                 return ListTile(
//                                   leading: Image.memory(app.icon,
//                                       width: 36, height: 36),
//                                   title: Text(app.appName,
//                                       style: TextStyle(color: textColor)),
//                                 );
//                               },
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Permissions Warning Card (conditional) 
//               if (!_hasPermissions)
//                 Card(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .errorContainer
//                       .withOpacity(0.5),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 8.0),
//                     child: Row(
//                       children: [
//                         Icon(Icons.warning_amber_rounded,
//                             color: Theme.of(context).colorScheme.error),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text('Permissions required.',
//                               style: TextStyle(
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .onErrorContainer)),
//                         ),
//                         TextButton(
//                           onPressed: _requestPermissions,
//                           child: const Text('GRANT'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// IMPORTS FIXED: Added the missing 'app_info.dart' import
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_selection_screen.dart';

void main() {
  runApp(const StudyModeApp());
}

// The root widget of the application.
class StudyModeApp extends StatelessWidget {
  const StudyModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Defines the visual styling for the light mode.
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        primary: Colors.blue.shade800,
        background: const Color(0xFFF8F9FA), // Lighter, cleaner background
        surface: Colors.white,
        secondary: Colors.blueGrey.shade600,
        onPrimary: Colors.white,
        onSurface: Colors.black87,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.white),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue.shade700;
          }
          return Colors.grey.shade400;
        }),
      ),
    );

    // Defines the visual styling for the dark mode.
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
        primary: Colors.tealAccent.shade400,
        background: const Color(0xFF121212), // Standard dark background
        surface: const Color(0xFF1E1E1E), // Darker card background
        secondary: Colors.blueGrey.shade300,
        onPrimary: Colors.black,
        onSurface: Colors.white70,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.tealAccent.shade400,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.tealAccent.shade400,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(const Color(0xFF1E1E1E)),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.tealAccent.shade400;
          }
          return Colors.grey.shade700;
        }),
      ),
    );

    //  BUILD THE MATERIAL APP
    return MaterialApp(
      title: 'Study Mode App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Adapt to system's light/dark mode setting.
      home: const StudyModeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// The main screen of the application.
class StudyModeScreen extends StatefulWidget {
  const StudyModeScreen({super.key});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen>
    with TickerProviderStateMixin {
  // Channel for communicating with native Android code.
  static const platform = MethodChannel('study_mode_channel');

  // STATE VARIABLES
  bool _isStudyModeEnabled = false;
  bool _hasPermissions = false;
  List<AppInfo> _selectedApps = [];

  // ANIMATION CONTROLLERS
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _checkPermissions();
    await _handleFirstLaunch();
    await _loadSelectedApps();
  }

  Future<void> _handleFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    if (isFirstLaunch) {
      await platform.invokeMethod('setStudyMode', {
        'enabled': false,
        'blockedPackages': [],
      });
      if (mounted) {
        setState(() {
          _isStudyModeEnabled = false;
        });
      }
      await prefs.setBool('is_first_launch', false);
    } else {
      _loadStudyModeState();
    }
  }

  Future<void> _loadSelectedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final packageNames = prefs.getStringList('blocked_apps') ?? [];

    if (packageNames.isEmpty) {
      if (mounted) setState(() => _selectedApps = []);
      return;
    }

    // Get all apps once, then filter the list. This is much faster.
    final allApps = await InstalledApps.getInstalledApps(true, true);
    final selected = allApps
        .where((app) => packageNames.contains(app.packageName))
        .toList();

    if (mounted) {
      setState(() {
        _selectedApps = selected;
      });
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      final bool hasPermissions =
          await platform.invokeMethod('checkPermissions');
      if (mounted) {
        setState(() {
          _hasPermissions = hasPermissions;
        });
      }
    } on PlatformException catch (e) {
      print("Failed to check permissions: '${e.message}'.");
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await platform.invokeMethod('requestPermissions');
      await _checkPermissions();
    } on PlatformException catch (e) {
      print("Failed to request permissions: '${e.message}'.");
    }
  }

  Future<void> _loadStudyModeState() async {
    try {
      final bool isEnabled = await platform.invokeMethod('getStudyModeState');
      if (mounted) {
        setState(() {
          _isStudyModeEnabled = isEnabled;
        });
      }
    } on PlatformException catch (e) {
      print("Failed to load study mode state: '${e.message}'.");
    }
  }

  Future<void> _toggleStudyMode() async {
    if (!_hasPermissions) {
      _showPermissionDialog();
      return;
    }

    try {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      final bool newState = !_isStudyModeEnabled;
      final List<String> packagesToBlock =
          _selectedApps.map((app) => app.packageName).toList();
      await platform.invokeMethod('setStudyMode', {
        'enabled': newState,
        'blockedPackages': packagesToBlock,
      });
      if (mounted) {
        setState(() {
          _isStudyModeEnabled = newState;
        });
      }
      _showStatusSnackBar();
    } on PlatformException catch (e) {
      print("Failed to toggle study mode: '${e.message}'.");
    }
  }

  void _navigateToAppSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppSelectionScreen()),
    );
    _loadSelectedApps();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app needs special permissions to block other apps. '
            'Please grant the required permissions to use Study Mode.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestPermissions();
              },
              child: const Text('Grant'),
            ),
          ],
        );
      },
    );
  }

  void _showStatusSnackBar() {
    final message = _isStudyModeEnabled
        ? 'Study Mode ON: Distractions blocked!'
        : 'Study Mode OFF: All apps are accessible.';
    final color = _isStudyModeEnabled
        ? Theme.of(context).colorScheme.primary
        : Colors.green.shade600;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Failed to toggle Study Mode. Please try again.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).colorScheme.primary;
    final Color inactiveColor = Theme.of(context).colorScheme.secondary;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rtl_rounded),
            onPressed: _navigateToAppSelection,
            tooltip: 'Select Apps to Block',
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        _isStudyModeEnabled
                            ? Icons.shield_rounded
                            : Icons.gpp_good_outlined,
                        size: 64,
                        color:
                            _isStudyModeEnabled ? activeColor : inactiveColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Focus Mode',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isStudyModeEnabled ? 'ACTIVE' : 'INACTIVE',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: _isStudyModeEnabled
                                  ? activeColor
                                  : inactiveColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    leading: Icon(
                      Icons.power_settings_new_rounded,
                      color: textColor.withOpacity(0.7),
                    ),
                    title: Text(
                      'Activate Focus Mode',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                    ),
                    trailing: Switch(
                      value: _isStudyModeEnabled,
                      onChanged: (value) => _toggleStudyMode(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Blocked Apps',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                                fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      _selectedApps.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24.0),
                              child: Text(
                                'No apps selected to block.\nTap the checklist icon above to choose.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: inactiveColor, height: 1.5),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedApps.length,
                              itemBuilder: (context, index) {
                                final app = _selectedApps[index];
                                return ListTile(
                                  leading: app.icon != null
                                      ? Image.memory(app.icon!,
                                          width: 36, height: 36)
                                      : const Icon(Icons.apps, size: 36),
                                  title: Text(app.name,
                                      style: TextStyle(color: textColor)),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_hasPermissions)
                Card(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Permissions required.',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer)),
                        ),
                        TextButton(
                          onPressed: _requestPermissions,
                          child: const Text('GRANT'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

