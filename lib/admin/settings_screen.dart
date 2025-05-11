import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:provider/provider.dart';
import '../data/providers/settings_provider.dart'; // Import the provider
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables
  final _newUserRewardController = TextEditingController();
  final _correctAnswerRewardController = TextEditingController();
  final _incorrectAnswerPenaltyController = TextEditingController();
  final _requiredPointsSelfChallengeController = TextEditingController();

  bool _selfChallengeModeEnabled = true;

  // State for Special Categories section
  bool _specialCategoryEnabled = true;
  String? _selectedCategory1; // Nullable string to hold the selected value
  String? _selectedCategory2;

  // Dummy data for category dropdowns
  final List<String> _dummyCategories = [
    'Learn English',
    'History Buff',
    'Science Wiz',
    'Movie Mania',
    'General Knowledge',
  ];

  bool _isInit = true; // Flag to fetch data only once

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isInit = false; // Keep the flag to prevent multiple runs if needed elsewhere
  }

  @override
  void dispose() {
    // Dispose controllers
    _newUserRewardController.dispose();
    _correctAnswerRewardController.dispose();
    _incorrectAnswerPenaltyController.dispose();
    _requiredPointsSelfChallengeController.dispose();
    // TODO: Dispose Special Categories controllers if any
    super.dispose();
  }

  // Function to update UI fields from provider data
  void _updateUIFields(SettingsProvider provider) {
     if (provider.pointsSettings != null) {
      _newUserRewardController.text = provider.pointsSettings!.newUserReward.toString();
      _correctAnswerRewardController.text = provider.pointsSettings!.correctAnswerReward.toString();
      _incorrectAnswerPenaltyController.text = provider.pointsSettings!.incorrectAnswerPenalty.toString();
      _selfChallengeModeEnabled = provider.pointsSettings!.selfChallengeModeEnabled;
      _requiredPointsSelfChallengeController.text = provider.pointsSettings!.requiredPointsSelfChallenge.toString();
    }
     if (provider.specialCategorySettings != null) {
        _specialCategoryEnabled = provider.specialCategorySettings!.specialCategoryEnabled;
        // TODO: Load actual categories and match IDs later
        // For now, keep using dummy data and potentially null IDs
        _selectedCategory1 = provider.specialCategorySettings!.category1Id ?? _dummyCategories[0]; 
        _selectedCategory2 = provider.specialCategorySettings!.category2Id ?? _dummyCategories[0];
    }
    // Use WidgetsBinding to schedule state update after build if called during build
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  // Function to handle updating points settings
  void _handleUpdatePoints(BuildContext context, SettingsProvider provider) {
    final pointsData = PointsSettingsDTO(
      newUserReward: int.tryParse(_newUserRewardController.text) ?? 0,
      correctAnswerReward: int.tryParse(_correctAnswerRewardController.text) ?? 0,
      incorrectAnswerPenalty: int.tryParse(_incorrectAnswerPenaltyController.text) ?? 0,
      selfChallengeModeEnabled: _selfChallengeModeEnabled,
      requiredPointsSelfChallenge: int.tryParse(_requiredPointsSelfChallengeController.text) ?? 0,
    );
    provider.updatePointsSettings(pointsData).then((success) {
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Points settings updated successfully!'), backgroundColor: Colors.green)
        );
      } else if (!success && provider.error != null && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: ${provider.error}'), backgroundColor: Colors.red)
        );
      }
    });
  }

   // Function to handle updating special category settings
  void _handleUpdateSpecialCategories(BuildContext context, SettingsProvider provider) {
     final specialData = SpecialCategorySettingsDTO(
      specialCategoryEnabled: _specialCategoryEnabled,
      // TODO: Use actual selected category IDs later
      category1Id: _selectedCategory1, 
      category2Id: _selectedCategory2,
    );
     provider.updateSpecialCategorySettings(specialData).then((success) {
       if (success && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Special category settings updated successfully!'), backgroundColor: Colors.green)
         );
       } else if (!success && provider.error != null && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: ${provider.error}'), backgroundColor: Colors.red)
         );
       }
     });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double cardPadding = 24.0;
    const double fieldPadding = 16.0;
    const double sectionSpacing = 30.0;
    const primaryColor = AppTheme.primaryColor;

    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        // Update UI fields when provider notifies changes (after initial load or update)
        // Check if not loading to avoid updating fields during intermediate loading states
        if (!provider.isLoading && (provider.pointsSettings != null || provider.specialCategorySettings != null)) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) {
               _updateUIFields(provider); 
               // Trigger rebuild ONLY IF data actually changed references or initial load completed
               // This check might need refinement depending on how provider updates state.
                if (provider.pointsSettings != _previousPointsSettings || provider.specialCategorySettings != _previousSpecialCategorySettings) {
                  setState(() {}); 
                   _previousPointsSettings = provider.pointsSettings;
                   _previousSpecialCategorySettings = provider.specialCategorySettings;
                }
             }
           });
        }
        
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show error message if any
                  if (provider.error != null && !provider.isLoading) 
                     Padding(
                       padding: const EdgeInsets.only(bottom: 16.0),
                       child: Text('Error: ${provider.error}', style: TextStyle(color: Colors.red)),
                     ),
                     
                  // --- Points Settings Card ---
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'Points Settings',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: fieldPadding * 1.5),
                          // Fields...
                          _buildSettingsRow(
                            label: 'New User Reward',
                            child: _buildNumericTextField(_newUserRewardController),
                          ),
                          SizedBox(height: fieldPadding),
                          _buildSettingsRow(
                            label: 'Correct Answer Reward Per Question',
                            child: _buildNumericTextField(_correctAnswerRewardController),
                          ),
                           SizedBox(height: fieldPadding),
                          _buildSettingsRow(
                            label: 'Incorrect Answer Penalty Per Question',
                            child: _buildNumericTextField(_incorrectAnswerPenaltyController),
                          ),
                           SizedBox(height: fieldPadding),
                           _buildSettingsRow(
                            label: 'Self Challenge Mode Enabled',
                            child: Switch(
                              value: _selfChallengeModeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _selfChallengeModeEnabled = value;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                          ),
                           SizedBox(height: fieldPadding),
                          _buildSettingsRow(
                            label: 'Required Points To Play Self Challenge',
                            child: _buildNumericTextField(_requiredPointsSelfChallengeController),
                            enabled: _selfChallengeModeEnabled, 
                          ),
                          const SizedBox(height: fieldPadding * 2),
                          Center(
                            child: ElevatedButton(
                              onPressed: provider.isLoading ? null : () => _handleUpdatePoints(context, provider),
                              child: const Text('Update Data'),
                               style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: sectionSpacing),
                  // --- Special Categories Card ---
                  Card(
                     elevation: 2.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                     child: Padding(
                       padding: const EdgeInsets.all(cardPadding),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                            'Special Categories',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: fieldPadding * 1.5),
                           _buildSettingsRow(
                            label: 'Special Category Enabled',
                            child: Switch(
                              value: _specialCategoryEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _specialCategoryEnabled = value;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                          ),
                          const SizedBox(height: fieldPadding),
                           AbsorbPointer(
                             absorbing: !_specialCategoryEnabled || provider.isLoading, // Also disable when loading
                             child: Opacity(
                               opacity: _specialCategoryEnabled ? 1.0 : 0.5,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('Category 1', style: theme.textTheme.titleMedium),
                                   const SizedBox(height: 8),
                                   _buildCategoryDropdown(
                                     value: _selectedCategory1,
                                     // TODO: Load actual categories here
                                     items: _dummyCategories, 
                                     onChanged: (newValue) {
                                       setState(() {
                                         _selectedCategory1 = newValue;
                                       });
                                     },
                                   ),
                                   const SizedBox(height: fieldPadding),
                                   Text('Category 2', style: theme.textTheme.titleMedium),
                                   const SizedBox(height: 8),
                                    _buildCategoryDropdown(
                                     value: _selectedCategory2,
                                      // TODO: Load actual categories here
                                     items: _dummyCategories,
                                     onChanged: (newValue) {
                                       setState(() {
                                         _selectedCategory2 = newValue;
                                       });
                                     },
                                   ),
                                 ],
                               ),
                             ),
                          ),
                           const SizedBox(height: fieldPadding * 2),
                           Center(
                            child: ElevatedButton(
                               onPressed: provider.isLoading ? null : () => _handleUpdateSpecialCategories(context, provider),
                               child: const Text('Update Data'),
                                style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                            ),
                          ),
                         ],
                       ),
                     ),
                  ),
                  const SizedBox(height: sectionSpacing),
                ],
              ),
            ),
             // Loading Indicator Overlay
            if (provider.isLoading)
              Container(
                 color: Colors.black.withOpacity(0.3),
                 child: const Center(child: CircularProgressIndicator()),
               ),
          ],
        );
      },
    );
  }

  // Keep previous state to compare for rebuild trigger
  PointsSettingsDTO? _previousPointsSettings;
  SpecialCategorySettingsDTO? _previousSpecialCategorySettings;

  // Helper widget for consistent row layout
  Widget _buildSettingsRow({required String label, required Widget child, bool enabled = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: enabled ? Colors.black87 : Colors.grey[500],
            ),
          ),
        ),
        const SizedBox(width: 20), // Add spacing between label and child
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: AbsorbPointer(
              absorbing: !enabled,
              child: Opacity(
                  opacity: enabled ? 1.0 : 0.5,
                  child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper for numeric text fields
  Widget _buildNumericTextField(TextEditingController controller) {
    return SizedBox(
      width: 80, // Fixed width for numeric fields
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  // Helper for category dropdowns
  Widget _buildCategoryDropdown({
    required String? value,
    required List<String> items, // Accept list of items
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String category) { // Use the passed items
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      isExpanded: true,
    );
  }
} 