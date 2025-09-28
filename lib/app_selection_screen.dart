
// import 'package:flutter/material.dart';
// import 'package:device_apps/device_apps.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // A screen that allows the user to select which applications to block.
// class AppSelectionScreen extends StatefulWidget {
//   const AppSelectionScreen({super.key});

//   @override
//   _AppSelectionScreenState createState() => _AppSelectionScreenState();
// }

// class _AppSelectionScreenState extends State<AppSelectionScreen> {
//   //  STATE VARIABLES 
//   List<Application> _apps = []; // Holds all installed applications.
//   List<Application> _filteredApps = []; // Holds apps matching the search query.
//   List<String> _selectedAppPackages = []; // Holds package names of selected apps.
//   bool _isLoading = true; // Tracks the loading state of the app list.
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadAppsAndSelection();
//     _searchController.addListener(_filterApps); // Re-filter on search text change.
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // Fetches installed apps and previously saved user selections.
//   Future<void> _loadAppsAndSelection() async {
//     // Load saved selections from local storage.
//     final prefs = await SharedPreferences.getInstance();
//     final selectedApps = prefs.getStringList('blocked_apps') ?? [];

//     // Get all non-system apps that can be launched.
//     final apps = await DeviceApps.getInstalledApplications(
//       includeAppIcons: true,
//       includeSystemApps: false,
//       onlyAppsWithLaunchIntent: true,
//     );

//     // Sort apps alphabetically.
//     apps.sort(
//         (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

//     if (mounted) {
//       setState(() {
//         _apps = apps;
//         _filteredApps = apps;
//         _selectedAppPackages = selectedApps;
//         _isLoading = false;
//       });
//     }
//   }

//   // Updates the filtered list based on the search input.
//   void _filterApps() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredApps = _apps.where((app) {
//         return app.appName.toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   // Selects or deselects all apps currently visible in the filtered list.
//   void _toggleSelectAll() {
//     setState(() {
//       final allVisibleSelected = _areAllVisibleAppsSelected();

//       for (var app in _filteredApps) {
//         if (allVisibleSelected) {
//           // If all are selected, deselect them.
//           _selectedAppPackages.remove(app.packageName);
//         } else {
//           // If not all are selected, add them to the selection.
//           if (!_selectedAppPackages.contains(app.packageName)) {
//             _selectedAppPackages.add(app.packageName);
//           }
//         }
//       }
//     });
//   }

//   // Helper to check if all visible (filtered) apps are currently selected.
//   bool _areAllVisibleAppsSelected() {
//     if (_filteredApps.isEmpty) return false;
//     for (var app in _filteredApps) {
//       if (!_selectedAppPackages.contains(app.packageName)) {
//         return false; // Found one that isn't selected.
//       }
//     }
//     return true; // All are selected.
//   }

//   // Saves the list of selected package names to SharedPreferences.
//   Future<void> _saveSelection() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('blocked_apps', _selectedAppPackages);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               Text('${_selectedAppPackages.length} apps saved to blocklist!'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       Navigator.of(context).pop(); // Return to the previous screen.
//     }
//   }

//   // Handles the state change when a user taps a checkbox.
//   void _onAppSelected(bool? isSelected, String packageName) {
//     setState(() {
//       if (isSelected == true) {
//         if (!_selectedAppPackages.contains(packageName)) {
//           _selectedAppPackages.add(packageName);
//         }
//       } else {
//         _selectedAppPackages.remove(packageName);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool allSelected = _areAllVisibleAppsSelected();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Apps'),
//         actions: [
//           // "Select/Deselect All" button.
//           TextButton(
//             onPressed: _filteredApps.isNotEmpty ? _toggleSelectAll : null,
//             child: Text(
//               allSelected ? 'Deselect All' : 'Select All',
//               style: TextStyle(
//                 color: Theme.of(context).appBarTheme.foregroundColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           // Counter for selected apps.
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 '${_selectedAppPackages.length} selected',
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _saveSelection,
//         icon: const Icon(Icons.save),
//         label: const Text('Save Selection'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary))
//           : Column(
//               children: [
//                 // Search Bar 
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                         hintText: 'Search for an app...',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30.0),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Theme.of(context)
//                             .colorScheme
//                             .surface
//                             .withOpacity(0.5),
//                         contentPadding: EdgeInsets.zero),
//                   ),
//                 ),
//                 // App List 
//                 Expanded(
//                   child: ListView.builder(
//                     // Padding to avoid overlap with the FAB.
//                     padding: const EdgeInsets.only(bottom: 80),
//                     itemCount: _filteredApps.length,
//                     itemBuilder: (context, index) {
//                       Application app = _filteredApps[index];
//                       final appWithIcon = app as ApplicationWithIcon;

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 4.0),
//                         child: Card(
//                           child: CheckboxListTile(
//                             title: Text(app.appName,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w600)),
//                             secondary: Image.memory(appWithIcon.icon,
//                                 width: 40, height: 40),
//                             value:
//                                 _selectedAppPackages.contains(app.packageName),
//                             onChanged: (bool? isSelected) {
//                               _onAppSelected(isSelected, app.packageName);
//                             },
//                             activeColor: Theme.of(context).colorScheme.primary,
//                             controlAffinity: ListTileControlAffinity.trailing,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// // 1. Change imports from 'device_apps' to 'installed_apps'
// import 'package:installed_apps/installed_apps.dart'; // <-- CHANGED
// import 'package:installed_apps/app_info.dart';     // <-- CHANGED
// import 'package:shared_preferences/shared_preferences.dart';

// // A screen that allows the user to select which applications to block.
// class AppSelectionScreen extends StatefulWidget {
//   const AppSelectionScreen({super.key});

//   @override
//   _AppSelectionScreenState createState() => _AppSelectionScreenState();
// }

// class _AppSelectionScreenState extends State<AppSelectionScreen> {
//   //  STATE VARIABLES 
//   // 2. Update list types from 'Application' to 'AppInfo'
//   List<AppInfo> _apps = []; // <-- CHANGED
//   List<AppInfo> _filteredApps = []; // <-- CHANGED
//   List<String> _selectedAppPackages = []; // Holds package names of selected apps.
//   bool _isLoading = true; // Tracks the loading state of the app list.
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadAppsAndSelection();
//     _searchController.addListener(_filterApps); // Re-filter on search text change.
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // Fetches installed apps and previously saved user selections.
//   // Future<void> _loadAppsAndSelection() async {
//   //   // Load saved selections from local storage.
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final selectedApps = prefs.getStringList('blocked_apps') ?? [];

//   //   // 3. Use 'InstalledApps' to get apps. This gets all apps including system apps.
//   //   List<AppInfo> apps = await InstalledApps.getInstalledApps(true); // <-- CHANGED

//   //   // 4. Manually filter out system apps to replicate old behavior.
//   //   // The 'AppInfo' object has an 'isSystemApp' property.
//   //   apps.removeWhere((app) => app.isSystemApp ?? true); // <-- ADDED THIS LINE

//   //   // 5. Sort apps alphabetically using 'app.name' instead of 'app.appName'.
//   //   apps.sort(
//   //       (a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase())); // <-- CHANGED

//   //   if (mounted) {
//   //     setState(() {
//   //       _apps = apps;
//   //       _filteredApps = apps;
//   //       _selectedAppPackages = selectedApps;
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> _loadSelectedApps() async {
//     final prefs = await SharedPreferences.getInstance();
//     final packageNames = prefs.getStringList('blocked_apps') ?? [];

//     List<AppInfo> apps = [];
//     for (String packageName in packageNames) {
//       try {
//         // THIS IS THE CORRECT CALL FOR VERSION 1.6.0
//         final app = await InstalledApps.getAppInfo(packageName, true);

//         if (app != null) {
//           apps.add(app);
//         }
//       } catch (e) {
//         print("Could not find app with package name: $packageName. It may have been uninstalled.");
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _selectedApps = apps;
//       });
//     }
//   }

//   // Updates the filtered list based on the search input.
//   void _filterApps() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredApps = _apps.where((app) {
//         // 6. Filter using 'app.name'
//         return (app.name ?? '').toLowerCase().contains(query); // <-- CHANGED
//       }).toList();
//     });
//   }

//   // Selects or deselects all apps currently visible in the filtered list.
//   void _toggleSelectAll() {
//     setState(() {
//       final allVisibleSelected = _areAllVisibleAppsSelected();

//       for (var app in _filteredApps) {
//         if (allVisibleSelected) {
//           // If all are selected, deselect them.
//           _selectedAppPackages.remove(app.packageName);
//         } else {
//           // If not all are selected, add them to the selection.
//           if (!_selectedAppPackages.contains(app.packageName)) {
//             _selectedAppPackages.add(app.packageName ?? '');
//           }
//         }
//       }
//       // Remove any empty strings that might have been added
//       _selectedAppPackages.removeWhere((item) => item.isEmpty);
//     });
//   }

//   // Helper to check if all visible (filtered) apps are currently selected.
//   bool _areAllVisibleAppsSelected() {
//     if (_filteredApps.isEmpty) return false;
//     for (var app in _filteredApps) {
//       if (!_selectedAppPackages.contains(app.packageName)) {
//         return false; // Found one that isn't selected.
//       }
//     }
//     return true; // All are selected.
//   }

//   // Saves the list of selected package names to SharedPreferences.
//   Future<void> _saveSelection() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('blocked_apps', _selectedAppPackages);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               Text('${_selectedAppPackages.length} apps saved to blocklist!'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       Navigator.of(context).pop(); // Return to the previous screen.
//     }
//   }

//   // Handles the state change when a user taps a checkbox.
//   void _onAppSelected(bool? isSelected, String packageName) {
//     setState(() {
//       if (isSelected == true) {
//         if (!_selectedAppPackages.contains(packageName)) {
//           _selectedAppPackages.add(packageName);
//         }
//       } else {
//         _selectedAppPackages.remove(packageName);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool allSelected = _areAllVisibleAppsSelected();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Apps'),
//         actions: [
//           // "Select/Deselect All" button.
//           TextButton(
//             onPressed: _filteredApps.isNotEmpty ? _toggleSelectAll : null,
//             child: Text(
//               allSelected ? 'Deselect All' : 'Select All',
//               style: TextStyle(
//                 color: Theme.of(context).appBarTheme.foregroundColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           // Counter for selected apps.
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 '${_selectedAppPackages.length} selected',
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _saveSelection,
//         icon: const Icon(Icons.save),
//         label: const Text('Save Selection'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary))
//           : Column(
//               children: [
//                 // Search Bar 
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                         hintText: 'Search for an app...',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30.0),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Theme.of(context)
//                             .colorScheme
//                             .surface
//                             .withOpacity(0.5),
//                         contentPadding: EdgeInsets.zero),
//                   ),
//                 ),
//                 // App List 
//                 Expanded(
//                   child: ListView.builder(
//                     // Padding to avoid overlap with the FAB.
//                     padding: const EdgeInsets.only(bottom: 80),
//                     itemCount: _filteredApps.length,
//                     itemBuilder: (context, index) {
//                       // 7. The app object is now of type 'AppInfo'
//                       AppInfo app = _filteredApps[index]; // <-- CHANGED
                      
//                       // The cast to 'ApplicationWithIcon' is no longer needed.

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 4.0),
//                         child: Card(
//                           child: CheckboxListTile(
//                             // 8. Use 'app.name' and provide a fallback value
//                             title: Text(app.name ?? 'Unknown App', // <-- CHANGED
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w600)),
//                             // 9. Get the icon directly from the 'app' object and check for null
//                             secondary: app.icon != null 
//                                 ? Image.memory(app.icon!, // <-- CHANGED
//                                     width: 40, height: 40)
//                                 : const Icon(Icons.apps, size: 40),
//                             value:
//                                 _selectedAppPackages.contains(app.packageName),
//                             onChanged: (bool? isSelected) {
//                               if (app.packageName != null) {
//                                 _onAppSelected(isSelected, app.packageName!);
//                               }
//                             },
//                             activeColor: Theme.of(context).colorScheme.primary,
//                             controlAffinity: ListTileControlAffinity.trailing,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  _AppSelectionScreenState createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  List<String> _selectedAppPackages = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAppsAndSelection();
    _searchController.addListener(_filterApps);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppsAndSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedApps = prefs.getStringList('blocked_apps') ?? [];

    List<AppInfo> apps = await InstalledApps.getInstalledApps(true);

    apps.removeWhere((app) =>
        app.packageName.startsWith("com.android.") ||
        app.packageName.startsWith("com.google.android."));

    apps.sort((a, b) =>
        (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));

    if (mounted) {
      setState(() {
        _apps = apps;
        _filteredApps = apps;
        _selectedAppPackages = selectedApps;
        _isLoading = false;
      });
    }
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = _apps.where((app) {
        return (app.name ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      final allVisibleSelected = _areAllVisibleAppsSelected();
      for (var app in _filteredApps) {
        if (allVisibleSelected) {
          _selectedAppPackages.remove(app.packageName);
        } else {
          if (!_selectedAppPackages.contains(app.packageName)) {
            if (app.packageName != null) {
              _selectedAppPackages.add(app.packageName!);
            }
          }
        }
      }
    });
  }

  bool _areAllVisibleAppsSelected() {
    if (_filteredApps.isEmpty) return false;
    for (var app in _filteredApps) {
      if (!_selectedAppPackages.contains(app.packageName)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blocked_apps', _selectedAppPackages);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${_selectedAppPackages.length} apps saved to blocklist!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _onAppSelected(bool? isSelected, String packageName) {
    setState(() {
      if (isSelected == true) {
        if (!_selectedAppPackages.contains(packageName)) {
          _selectedAppPackages.add(packageName);
        }
      } else {
        _selectedAppPackages.remove(packageName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool allSelected = _areAllVisibleAppsSelected();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps'),
        actions: [
          TextButton(
            onPressed: _filteredApps.isNotEmpty ? _toggleSelectAll : null,
            child: Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('${_selectedAppPackages.length} selected'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSelection,
        icon: const Icon(Icons.save),
        label: const Text('Save Selection'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for an app...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, index) {
                      AppInfo app = _filteredApps[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Card(
                          child: CheckboxListTile(
                            title: Text(app.name ?? 'Unknown App',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            secondary: app.icon != null
                                ? Image.memory(app.icon!,
                                    width: 40, height: 40)
                                : const Icon(Icons.apps, size: 40),
                            value: _selectedAppPackages
                                .contains(app.packageName),
                            onChanged: (bool? isSelected) {
                              if (app.packageName != null) {
                                _onAppSelected(isSelected, app.packageName!);
                              }
                            },
                            activeColor:
                                Theme.of(context).colorScheme.primary,
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

