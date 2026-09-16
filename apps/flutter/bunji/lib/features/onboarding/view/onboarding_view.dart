import 'package:bunji/app/di.dart';
import 'package:bunji/features/onboarding/viewcontrollers/onboarding_vc.dart';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/ai/services/bunji_device_capabilities.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingViewController>()..init(),
      child: const _OnboardingContent(),
    );
  }
}

class _OnboardingContent extends StatefulWidget {
  const _OnboardingContent();

  @override
  State<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<_OnboardingContent> {
  late final TextEditingController _nameController;
  String? _expandedModelId;

  static const List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDob(
    BuildContext context,
    OnboardingViewController controller,
    DateTime? currentDob,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: cs.copyWith(primary: cs.primary)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.updateDob(picked);
    }
  }

  Future<void> _selectGender(
    BuildContext context,
    OnboardingViewController controller,
    String? currentGender,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Select Gender',
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ..._genders.map((gender) {
                  final isSelected = currentGender == gender;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: isSelected
                        ? cs.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.4),
                    ),
                    title: Text(
                      gender,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? cs.primary : cs.onSurface,
                      ),
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(gender),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      controller.updateGender(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<OnboardingViewController, OnboardingState>(
      listenWhen: (previous, current) =>
          current.ui.action != null ||
          current.isConfirmingDownload != previous.isConfirmingDownload ||
          current.storageError != previous.storageError,
      listener: (context, state) {
        final action = state.ui.action;
        final controller = context.read<OnboardingViewController>();

        if (action is NavigateTo) {
          if (action.replace) {
            context.go(action.route.path, extra: action.args);
          } else {
            context.push(action.route.path, extra: action.args);
          }
          controller.clearAction();
        } else if (action is ShowError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          controller.clearAction();
        }

        // Show confirmation bottom sheet if triggered
        if (state.isConfirmingDownload) {
          _showConfirmationSheet(context, controller, state);
        }

        // Show storage error dialog if triggered
        if (state.storageError != null) {
          _showStorageErrorDialog(context, controller, state.storageError!);
        }
      },
      builder: (context, state) {
        final controller = context.read<OnboardingViewController>();

        // Sync name controller if state updated from database recovery
        if (_nameController.text != state.name && state.name.isNotEmpty) {
          _nameController.text = state.name;
        }

        return Scaffold(
          body: GlassScaffold(
            extendBody: true,
            bottomEdgeFade: true,
            appBar: GlassAppBar(
              leading:
                  (state.step > 0 &&
                      state.step < 3 &&
                      !state.isLoading &&
                      !state.isDownloading)
                  ? BunjiButton(
                      height: 40,
                      width: 40,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onTap: controller.previousStep,
                    )
                  : null,
              actions: [
                if (state.step < 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        'Step ${state.step + 1} of 3',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _buildCurrentStepView(
                          context,
                          controller,
                          state,
                          cs,
                          tt,
                        ),
                      ),
                    ),
                    if (state.step < 3 || state.step == 4)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, top: 12.0),
                        child: _buildBottomActionButton(
                          context,
                          controller,
                          state,
                          cs,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStepView(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    switch (state.step) {
      case 0:
        return Center(
          child: SingleChildScrollView(
            child: _buildStepOne(context, controller, state, cs, tt),
          ),
        );
      case 1:
        return Center(
          child: SingleChildScrollView(
            child: _buildStepTwo(context, controller, state, cs, tt),
          ),
        );
      case 2:
        return _buildModelSelectionStep(context, controller, state, cs, tt);
      case 3:
        return _buildDownloadStep(context, controller, state, cs, tt);
      case 4:
        return _buildAiReadyStep(context, controller, state, cs, tt);
      default:
        return const SizedBox.shrink();
    }
  }

  // -------------------------------------------------------------
  // Step 0: Name (Profile Part 1)
  // -------------------------------------------------------------
  Widget _buildStepOne(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Column(
      key: const ValueKey('step_0_name'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What should Bunji call you?',
          textAlign: TextAlign.start,
          style: tt.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          autofocus: true,
          textAlign: TextAlign.center,
          style: tt.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: tt.displayMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: controller.updateName,
          onSubmitted: (_) => controller.nextStep(),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Step 1: Gender & DOB (Profile Part 2)
  // -------------------------------------------------------------
  Widget _buildStepTwo(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final displayName = state.name.trim();

    return Column(
      key: const ValueKey('step_1_details'),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nice to meet you, $displayName!',
          textAlign: TextAlign.start,
          style: tt.bodyLarge?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A little more about you',
          textAlign: TextAlign.start,
          style: tt.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 32),

        // Gender Selection Section
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Gender',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectGender(context, controller, state.gender),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: state.gender != null
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.15),
                width: state.gender != null ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: state.gender != null
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    state.gender ?? 'Select your gender',
                    style: tt.bodyLarge?.copyWith(
                      color: state.gender != null
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: state.gender != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Date of Birth Section
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Date of Birth',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDob(context, controller, state.dob),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: state.dob != null
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.15),
                width: state.dob != null ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: state.dob != null
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    state.dob != null
                        ? _formatDate(state.dob!)
                        : 'Select your date of birth',
                    style: tt.bodyLarge?.copyWith(
                      color: state.dob != null
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: state.dob != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_month_rounded,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Step 2: Choose Your AI Model
  // -------------------------------------------------------------
  IconData _getTierIcon(BunjiModelTier tier) {
    switch (tier) {
      case BunjiModelTier.fast:
        return Icons.bolt_rounded;
      case BunjiModelTier.balanced:
        return Icons.tune_rounded;
      case BunjiModelTier.reasoning:
        return Icons.psychology_rounded;
      case BunjiModelTier.quality:
        return Icons.auto_awesome_rounded;
    }
  }

  Widget _buildModelSelectionStep(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final availableModels = state.onboardingModels.isNotEmpty
        ? state.onboardingModels
        : (state.selectedModel != null ? [state.selectedModel!] : <BunjiModel>[]);
    final leftColModels = <BunjiModel>[];
    final rightColModels = <BunjiModel>[];

    for (var i = 0; i < availableModels.length; i++) {
      if (i.isEven) {
        leftColModels.add(availableModels[i]);
      } else {
        rightColModels.add(availableModels[i]);
      }
    }

    return SingleChildScrollView(
      key: const ValueKey('step_2_models'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Privacy Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your conversations stay on your device.',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Choose your AI',
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bunji runs AI directly on your device. Choose the model that best fits how you want to use Bunji.',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // 2-Column Asymmetric Tile Listing (matches home_view)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  children: [
                    for (final model in leftColModels) ...[
                      _buildModelCard(
                        context: context,
                        model: model,
                        isSelected: state.selectedModel?.id == model.id,
                        isExpanded: _expandedModelId == model.id,
                        suitability: state.modelSuitability[model.id],
                        onTap: () {
                          setState(() {
                            _expandedModelId = (_expandedModelId == model.id)
                                ? null
                                : model.id;
                          });
                          controller.selectModel(model);
                        },
                        cs: cs,
                        tt: tt,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Right Column (Asymmetric offset matching home_view)
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    for (final model in rightColModels) ...[
                      _buildModelCard(
                        context: context,
                        model: model,
                        isSelected: state.selectedModel?.id == model.id,
                        isExpanded: _expandedModelId == model.id,
                        suitability: state.modelSuitability[model.id],
                        onTap: () {
                          setState(() {
                            _expandedModelId = (_expandedModelId == model.id)
                                ? null
                                : model.id;
                          });
                          controller.selectModel(model);
                        },
                        cs: cs,
                        tt: tt,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModelCard({
    required BuildContext context,
    required BunjiModel model,
    required bool isSelected,
    required bool isExpanded,
    required DeviceModelSuitability? suitability,
    required VoidCallback onTap,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final borderColor = isSelected
        ? cs.primary
        : cs.outline.withValues(alpha: 0.25);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: isSelected ? 2.0 : 0.8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header: Tier Badge & Radio indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTierIcon(model.tier),
                            size: 13,
                            color: isSelected ? cs.onPrimary : cs.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            model.tier.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isSelected ? cs.onPrimary : cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.35),
                      size: 20,
                    ),
                  ],
                ),

                if (model.recommended) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Model Title
                Text(
                  model.displayName,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Size Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    model.formattedSize,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),

                // Animated Details Section (Expanded vs Collapsed)
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  child: isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: cs.outline.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 10),

                            // Description
                            Text(
                              model.description,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                height: 1.35,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Highlights
                            for (final bullet in model.highlights) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: isSelected
                                            ? cs.primary
                                            : cs.onSurface.withValues(
                                                alpha: 0.6,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        bullet,
                                        style: tt.bodySmall?.copyWith(
                                          fontSize: 11,
                                          color: cs.onSurface.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Device Suitability
                            if (suitability != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                suitability.badgeText,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: suitability.isWarning
                                      ? Colors.orange.shade800
                                      : (suitability.isError
                                            ? cs.error
                                            : cs.onSurface.withValues(
                                                alpha: 0.6,
                                              )),
                                ),
                              ),
                            ],
                          ],
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),

                const SizedBox(height: 8),

                // Expand / Collapse Chevron indicator
                Center(
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Step 3: Dedicated Download & Verification State
  // -------------------------------------------------------------
  Widget _buildDownloadStep(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final model = state.selectedModel ??
        (state.onboardingModels.isNotEmpty ? state.onboardingModels.first : null);
    if (model == null) {
      return const SizedBox();
    }
    final isFailed = state.downloadState == BunjiModelDownloadState.failed;
    final isPaused = state.downloadState == BunjiModelDownloadState.paused;

    return Center(
      key: const ValueKey('step_3_download'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated Status Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFailed
                      ? cs.error.withValues(alpha: 0.1)
                      : cs.primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: isFailed
                      ? Icon(
                          Icons.error_outline_rounded,
                          size: 38,
                          color: cs.error,
                        )
                      : (isPaused
                            ? Icon(
                                Icons.pause_circle_outline_rounded,
                                size: 38,
                                color: cs.primary,
                              )
                            : CircularProgressIndicator(
                                value: state.downloadProgress > 0
                                    ? state.downloadProgress
                                    : null,
                                strokeWidth: 3.5,
                                color: cs.primary,
                              )),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                isFailed
                    ? "Couldn't finish downloading"
                    : (state.statusMessage.isNotEmpty
                          ? state.statusMessage
                          : 'Preparing Bunji AI...'),
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isFailed ? cs.error : cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Model badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  model.displayName,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              if (!isFailed) ...[
                // Percentage Display
                Text(
                  '${state.downloadPercentage}%',
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Sleek Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: state.downloadProgress > 0
                        ? state.downloadProgress
                        : null,
                    minHeight: 12,
                    backgroundColor: cs.surfaceContainerHigh.withValues(
                      alpha: 0.8,
                    ),
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Size metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.formattedDownloaded} / ${state.formattedTotal}',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      state.statusMessage,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Download Controls: Pause / Resume & Cancel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isPaused
                          ? controller.resumeDownload
                          : controller.pauseDownload,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 20,
                      ),
                      label: Text(isPaused ? 'Resume' : 'Pause'),
                    ),
                    const SizedBox(width: 14),
                    TextButton(
                      onPressed: controller.cancelDownload,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Failed State Actions
                Text(
                  state.errorMessage ??
                      'The AI model was not downloaded completely.',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.startDownloadAndInstall,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: controller.chooseAnotherModel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Choose Another Model',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Step 4: AI Ready Celebration Screen
  // -------------------------------------------------------------
  Widget _buildAiReadyStep(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final model = state.selectedModel ??
        (state.onboardingModels.isNotEmpty ? state.onboardingModels.first : null);
    if (model == null) {
      return const SizedBox();
    }

    return Center(
      key: const ValueKey('step_4_ready'),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 54,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bunji is ready',
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${model.displayName} has been verified and installed.',
              textAlign: TextAlign.center,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Inference engine is initialized and ready to run completely offline on your device.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Bottom Action Button based on Step
  // -------------------------------------------------------------
  Widget _buildBottomActionButton(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
    ColorScheme cs,
  ) {
    if (state.step == 0) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: state.isNameValid ? controller.nextStep : null,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      );
    } else if (state.step == 1) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: (state.canSubmitProfile && !state.isLoading)
              ? controller.submitProfile
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: state.isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: cs.onPrimary,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      );
    } else if (state.step == 2) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: state.selectedModel != null
              ? controller.showDownloadConfirmation
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      );
    } else if (state.step == 4) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: controller.completeOnboarding,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start Using Bunji',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // -------------------------------------------------------------
  // Download Confirmation Bottom Sheet
  // -------------------------------------------------------------
  void _showConfirmationSheet(
    BuildContext context,
    OnboardingViewController controller,
    OnboardingState state,
  ) {
    final model = state.selectedModel;
    if (model == null) return;

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "You're about to download:",
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  model.displayName,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Size: ${model.formattedSize}',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'This model will be stored on your device and used for local AI conversations.',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    controller.startDownloadAndInstall();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Download & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    controller.cancelConfirmation();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (state.isConfirmingDownload) {
        controller.cancelConfirmation();
      }
    });
  }

  // -------------------------------------------------------------
  // Storage Error Dialog
  // -------------------------------------------------------------
  void _showStorageErrorDialog(
    BuildContext context,
    OnboardingViewController controller,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.storage_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('Not enough storage'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.chooseAnotherModel();
              },
              child: const Text('Choose Another Model'),
            ),
          ],
        );
      },
    );
  }
}
