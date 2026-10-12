import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../providers/app_providers.dart';
import '../providers/user_provider.dart';

class EditProfileScreen
    extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  ConsumerState<EditProfileScreen>
      createState() =>
          _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<
        EditProfileScreen> {
  final _meterController =
      TextEditingController();

  final _feetController =
      TextEditingController();

  final _inchController =
      TextEditingController();

  final _weightController =
      TextEditingController();

  final _goalController =
      TextEditingController();

  final _startController =
      TextEditingController();

  String _heightUnit =
      'meter';

  bool _profileFilled =
      false;

  @override
  void initState() {
    super.initState();

    _loadHeightUnitPreference();
  }

  @override
  void dispose() {
    _meterController.dispose();
    _feetController.dispose();
    _inchController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _startController.dispose();

    super.dispose();
  }

  Future<void>
      _loadHeightUnitPreference() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final savedUnit =
        prefs.getString(
              'height_input_unit',
            ) ??
            'meter';

    if (!mounted) {
      return;
    }

    setState(
      () {
        _heightUnit =
            savedUnit;
      },
    );
  }

  Future<void>
      _saveHeightUnitPreference() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      'height_input_unit',
      _heightUnit,
    );
  }

  void _fillProfile(
    Map<String, dynamic> profile,
  ) {
    if (_profileFilled) {
      return;
    }

    _profileFilled =
        true;

    final heightMeters =
        (profile['height']
                as num)
            .toDouble();

    final weight =
        (profile['weight']
                as num)
            .toDouble();

    final goal =
        (profile['goal_weight']
                as num)
            .toDouble();

    final start =
        (profile['starting_weight']
                as num)
            .toDouble();

    _meterController.text =
        heightMeters
            .toStringAsFixed(
      2,
    );

    _setFeetAndInchesFromMeters(
      heightMeters,
    );

    _weightController.text =
        weight.toStringAsFixed(
      1,
    );

    _goalController.text =
        goal.toStringAsFixed(
      1,
    );

    _startController.text =
        start.toStringAsFixed(
      1,
    );
  }

  void _setFeetAndInchesFromMeters(
    double meters,
  ) {
    final totalInches =
        meters *
            39.3700787;

    final feet =
        totalInches ~/ 12;

    final inches =
        totalInches -
            (feet * 12);

    _feetController.text =
        feet.toString();

    _inchController.text =
        inches.toStringAsFixed(
      1,
    );
  }

  void _setMetersFromFeetAndInches() {
    final feet =
        double.tryParse(
              _feetController.text
                  .trim(),
            ) ??
            0;

    final inches =
        double.tryParse(
              _inchController.text
                  .trim(),
            ) ??
            0;

    if (feet <= 0) {
      return;
    }

    final totalInches =
        (feet * 12) +
            inches;

    final meters =
        totalInches *
            0.0254;

    _meterController.text =
        meters.toStringAsFixed(
      2,
    );
  }

  void _setFeetFromMeters() {
    final meters =
        double.tryParse(
      _meterController.text
          .trim(),
    );

    if (meters == null ||
        meters <= 0) {
      return;
    }

    _setFeetAndInchesFromMeters(
      meters,
    );
  }

  Future<void> _save() async {
    double? height;

    if (_heightUnit ==
        'meter') {
      height =
          double.tryParse(
        _meterController.text
            .trim(),
      );
    } else {
      final feet =
          double.tryParse(
        _feetController.text
            .trim(),
      );

      final inches =
          double.tryParse(
                _inchController.text
                    .trim(),
              ) ??
              0;

      if (feet != null) {
        final totalInches =
            (feet * 12) +
                inches;

        height =
            totalInches *
                0.0254;
      }
    }

    final weight =
        double.tryParse(
      _weightController.text
          .trim(),
    );

    final goal =
        double.tryParse(
      _goalController.text
          .trim(),
    );

    final start =
        double.tryParse(
      _startController.text
          .trim(),
    );

    if (height == null ||
        weight == null ||
        goal == null ||
        start == null ||
        height <= 0 ||
        weight <= 0 ||
        goal <= 0 ||
        start <= 0) {
      _showError(
        'Please enter valid profile values.',
      );

      return;
    }

    if (height < 0.8 ||
        height > 2.5) {
      _showError(
        'Please enter a valid height.',
      );

      return;
    }

    if (_heightUnit ==
        'feet') {
      final inches =
          double.tryParse(
                _inchController.text
                    .trim(),
              ) ??
              0;

      if (inches < 0 ||
          inches >= 12) {
        _showError(
          'Inches must be between 0 and 11.9.',
        );

        return;
      }
    }

    await _saveHeightUnitPreference();

    await ref
        .read(
          profileNotifierProvider
              .notifier,
        )
        .updateProfile(
          height:
              height,
          weight:
              weight,
          goalWeight:
              goal,
          startingWeight:
              start,
        );

    ref.invalidate(
      weightHistoryNotifierProvider,
    );

    if (mounted) {
      Navigator.pop(
        context,
      );
    }
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(
          message,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final state =
        ref.watch(
      profileNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Edit profile',
        ),
      ),
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            colors: [
              AppTheme.bgColor,
              Color(0xFF071827),
            ],
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
          ),
        ),
        child: state.when(
          loading: () =>
              const Center(
            child:
                CircularProgressIndicator(
              color:
                  AppTheme.accentColor,
            ),
          ),
          error:
              (error, stack) =>
                  Center(
            child:
                Text(
              'Error: $error',
            ),
          ),
          data:
              (profile) {
            _fillProfile(
              profile,
            );

            return SafeArea(
              top: false,
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  32,
                ),
                children: [
                  _infoBanner(),

                  const SizedBox(
                    height:
                        22,
                  ),

                  const Text(
                    'Height',
                    style:
                        TextStyle(
                      fontSize:
                          17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                        12,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        SegmentedButton<
                            String>(
                      segments:
                          const [
                        ButtonSegment<
                            String>(
                          value:
                              'meter',
                          label:
                              Text(
                            'Meter',
                          ),
                          icon:
                              Icon(
                            Icons
                                .straighten_rounded,
                          ),
                        ),
                        ButtonSegment<
                            String>(
                          value:
                              'feet',
                          label:
                              Text(
                            'Feet & Inch',
                          ),
                          icon:
                              Icon(
                            Icons
                                .height_rounded,
                          ),
                        ),
                      ],
                      selected:
                          {
                        _heightUnit,
                      },
                      onSelectionChanged:
                          (
                            selection,
                          ) {
                        final newUnit =
                            selection.first;

                        if (newUnit ==
                            _heightUnit) {
                          return;
                        }

                        if (newUnit ==
                            'feet') {
                          _setFeetFromMeters();
                        } else {
                          _setMetersFromFeetAndInches();
                        }

                        setState(
                          () {
                            _heightUnit =
                                newUnit;
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    height:
                        14,
                  ),

                  if (_heightUnit ==
                      'meter')
                    TextField(
                      controller:
                          _meterController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal:
                            true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Height',
                        hintText:
                            'e.g. 1.75',
                        suffixText:
                            'm',
                        prefixIcon:
                            Icon(
                          Icons
                              .height_rounded,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child:
                              TextField(
                            controller:
                                _feetController,
                            keyboardType:
                                TextInputType.number,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Feet',
                              hintText:
                                  '5',
                              suffixText:
                                  'ft',
                            ),
                          ),
                        ),

                        const SizedBox(
                          width:
                              12,
                        ),

                        Expanded(
                          child:
                              TextField(
                            controller:
                                _inchController,
                            keyboardType:
                                const TextInputType
                                    .numberWithOptions(
                              decimal:
                                  true,
                            ),
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Inches',
                              hintText:
                                  '8',
                              suffixText:
                                  'in',
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(
                    height:
                        26,
                  ),

                  const Text(
                    'Weight',
                    style:
                        TextStyle(
                      fontSize:
                          17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                        12,
                  ),

                  TextField(
                    controller:
                        _startController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal:
                          true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Starting weight',
                      suffixText:
                          'kg',
                      prefixIcon:
                          Icon(
                        Icons
                            .flag_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        14,
                  ),

                  TextField(
                    controller:
                        _weightController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal:
                          true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Current weight',
                      suffixText:
                          'kg',
                      prefixIcon:
                          Icon(
                        Icons
                            .monitor_weight_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        14,
                  ),

                  TextField(
                    controller:
                        _goalController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal:
                          true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Goal weight',
                      suffixText:
                          'kg',
                      prefixIcon:
                          Icon(
                        Icons
                            .track_changes_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        30,
                  ),

                  ElevatedButton.icon(
                    onPressed:
                        _save,
                    icon:
                        const Icon(
                      Icons
                          .save_outlined,
                    ),
                    label:
                        const Text(
                      'Save changes',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          AppTheme.premiumCard(
        borderColor:
            AppTheme.accentColor
                .withOpacity(
          .18,
        ),
      ),
      child:
          const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .insights_rounded,
            color:
                AppTheme.accentColor,
          ),
          SizedBox(
            width:
                12,
          ),
          Expanded(
            child:
                Text(
              'Choose meters or feet & inches for height. '
              'Changing your current weight automatically adds '
              'a new point to your weight history.',
              style:
                  TextStyle(
                color:
                    AppTheme.textSecondary,
                fontSize:
                    12,
                height:
                    1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../providers/app_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _meterController = TextEditingController();

  final _feetController = TextEditingController();
  final _inchController = TextEditingController();

  final _weightController = TextEditingController();
  final _goalController = TextEditingController();
  final _startController = TextEditingController();

  String _heightUnit = 'meter';

  bool _profileFilled = false;

  @override
  void initState() {
    super.initState();

    _loadHeightUnitPreference();
  }

  @override
  void dispose() {
    _meterController.dispose();

    _feetController.dispose();
    _inchController.dispose();

    _weightController.dispose();
    _goalController.dispose();
    _startController.dispose();

    super.dispose();
  }

  // ============================================================
  // HEIGHT UNIT PREFERENCE
  // ============================================================

  Future<void> _loadHeightUnitPreference() async {
    final prefs = await SharedPreferences.getInstance();

    final savedUnit = prefs.getString(
          'height_input_unit',
        ) ??
        'meter';

    if (!mounted) {
      return;
    }

    setState(() {
      _heightUnit = savedUnit;
    });
  }

  Future<void> _saveHeightUnitPreference() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'height_input_unit',
      _heightUnit,
    );
  }

  // ============================================================
  // INITIAL PROFILE VALUES
  // ============================================================

  void _fillProfile(
    Map<String, dynamic> profile,
  ) {
    if (_profileFilled) {
      return;
    }

    _profileFilled = true;

    final heightMeters = (profile['height'] as num).toDouble();

    final weight = (profile['weight'] as num).toDouble();

    final goal = (profile['goal_weight'] as num).toDouble();

    final start = (profile['starting_weight'] as num).toDouble();

    _meterController.text = heightMeters.toStringAsFixed(2);

    _setFeetAndInchesFromMeters(
      heightMeters,
    );

    _weightController.text = weight.toStringAsFixed(1);

    _goalController.text = goal.toStringAsFixed(1);

    _startController.text = start.toStringAsFixed(1);
  }

  void _setFeetAndInchesFromMeters(
    double meters,
  ) {
    final totalInches = meters * 39.3700787;

    final feet = totalInches ~/ 12;

    final inches = totalInches - (feet * 12);

    _feetController.text = feet.toString();

    _inchController.text = inches.toStringAsFixed(1);
  }

  void _setMetersFromFeetAndInches() {
    final feet = double.tryParse(
          _feetController.text.trim(),
        ) ??
        0;

    final inches = double.tryParse(
          _inchController.text.trim(),
        ) ??
        0;

    if (feet <= 0) {
      return;
    }

    final totalInches = (feet * 12) + inches;

    final meters = totalInches * 0.0254;

    _meterController.text = meters.toStringAsFixed(2);
  }

  void _setFeetFromMeters() {
    final meters = double.tryParse(
      _meterController.text.trim(),
    );

    if (meters == null || meters <= 0) {
      return;
    }

    _setFeetAndInchesFromMeters(
      meters,
    );
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _save() async {
    double? height;

    if (_heightUnit == 'meter') {
      height = double.tryParse(
        _meterController.text.trim(),
      );
    } else {
      final feet = double.tryParse(
        _feetController.text.trim(),
      );

      final inches = double.tryParse(
            _inchController.text.trim(),
          ) ??
          0;

      if (feet != null) {
        final totalInches = (feet * 12) + inches;

        height = totalInches * 0.0254;
      }
    }

    final weight = double.tryParse(
      _weightController.text.trim(),
    );

    final goal = double.tryParse(
      _goalController.text.trim(),
    );

    final start = double.tryParse(
      _startController.text.trim(),
    );

    if (height == null ||
        weight == null ||
        goal == null ||
        start == null ||
        height <= 0 ||
        weight <= 0 ||
        goal <= 0 ||
        start <= 0) {
      _showError(
        'Please enter valid profile values.',
      );

      return;
    }

    if (height < 0.8 || height > 2.5) {
      _showError(
        'Please enter a valid height.',
      );

      return;
    }

    if (_heightUnit == 'feet') {
      final inches = double.tryParse(
            _inchController.text.trim(),
          ) ??
          0;

      if (inches < 0 || inches >= 12) {
        _showError(
          'Inches must be between 0 and 11.9.',
        );

        return;
      }
    }

    await _saveHeightUnitPreference();

    await ref.read(profileNotifierProvider.notifier).updateProfile(
          height: height,
          weight: weight,
          goalWeight: goal,
          startingWeight: start,
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      profileNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit profile',
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.bgColor,
              Color(0xFF071827),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: state.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentColor,
            ),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
            ),
          ),
          data: (profile) {
            _fillProfile(
              profile,
            );

            return SafeArea(
              top: false,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  32,
                ),
                children: [
                  _infoBanner(),

                  const SizedBox(height: 22),

                  // ==================================================
                  // HEIGHT
                  // ==================================================

                  const Text(
                    'Height',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'meter',
                          label: Text(
                            'Meter',
                          ),
                          icon: Icon(
                            Icons.straighten_rounded,
                          ),
                        ),
                        ButtonSegment<String>(
                          value: 'feet',
                          label: Text(
                            'Feet & Inch',
                          ),
                          icon: Icon(
                            Icons.height_rounded,
                          ),
                        ),
                      ],
                      selected: {
                        _heightUnit,
                      },
                      onSelectionChanged: (selection) {
                        final newUnit = selection.first;

                        if (newUnit == _heightUnit) {
                          return;
                        }

                        if (newUnit == 'feet') {
                          _setFeetFromMeters();
                        } else {
                          _setMetersFromFeetAndInches();
                        }

                        setState(() {
                          _heightUnit = newUnit;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (_heightUnit == 'meter')
                    TextField(
                      controller: _meterController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        hintText: 'e.g. 1.75',
                        suffixText: 'm',
                        prefixIcon: Icon(
                          Icons.height_rounded,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _feetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Feet',
                              hintText: '5',
                              suffixText: 'ft',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _inchController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Inches',
                              hintText: '8',
                              suffixText: 'in',
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // WEIGHT
                  // ==================================================

                  const Text(
                    'Weight',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _startController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Starting weight',
                      suffixText: 'kg',
                      prefixIcon: Icon(
                        Icons.flag_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Current weight',
                      suffixText: 'kg',
                      prefixIcon: Icon(
                        Icons.monitor_weight_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _goalController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Goal weight',
                      suffixText: 'kg',
                      prefixIcon: Icon(
                        Icons.track_changes_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      'Save changes',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCard(
        borderColor: AppTheme.accentColor.withOpacity(.18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.insights_rounded,
            color: AppTheme.accentColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Choose either meters or feet & inches for height. '
              'The app converts everything internally to meters so '
              'BMI calculation remains accurate.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/