import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/models/viewcontroller/models_state.dart';
import 'package:bunji/features/models/viewcontroller/models_vc.dart';
import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/widgets/button.dart';
import 'package:bunji/shared/widgets/label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class ModelsView extends StatelessWidget {
  const ModelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ModelsViewController>()..init(),
      child: const _ModelsViewContent(),
    );
  }
}

class _ModelsViewContent extends StatelessWidget {
  const _ModelsViewContent();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<ModelsViewController, ModelsState>(
      listenWhen: (previous, current) => current.ui.action != null,
      listener: (context, state) {
        final action = state.ui.action;
        final controller = context.read<ModelsViewController>();

        if (action is ShowError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          controller.clearAction();
        } else if (action is ShowSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action.message),
              backgroundColor: cs.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          controller.clearAction();
        }
      },
      builder: (context, state) {
        final controller = context.read<ModelsViewController>();
        final active = state.activeModel;

        return Scaffold(
          body: SafeArea(
            child: GlassScaffold(
              extendBody: true,
              bottomEdgeFade: true,
              appBar: GlassAppBar(
                title: Label(.models),
                leading: BunjiButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(Routes.home.path);
                    }
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      tooltip: 'Refresh Catalog',
                      onPressed: state.isRefreshingCatalog
                          ? null
                          : controller.refreshCatalog,
                      icon: state.isRefreshingCatalog
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                    ),
                  ),
                ],
              ),
              bottomBar: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 38,
                  vertical: 8,
                ),
                child: GlassSearchBar(onChanged: controller.setSearchQuery),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Tier Filter Chips
                    _buildTierFilterChips(context, controller, state, cs, tt),
                    const SizedBox(height: 18),

                    // 2. Active Model Hero Card
                    if (active != null) ...[
                      _buildActiveModelHeroCard(
                        context,
                        controller,
                        state,
                        active,
                        cs,
                        tt,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 3. Catalog Model Cards List
                    _buildCatalogSection(context, controller, state, cs, tt),
                    const SizedBox(height: 20),

                    // 4. Inference & Response Configurations
                    _buildInferenceSettingsCard(
                      context,
                      controller,
                      state,
                      cs,
                      tt,
                    ),
                    const SizedBox(height: 20),

                    // 5. Catalog Management & Diagnostics
                    _buildCatalogDiagnosticsCard(
                      context,
                      controller,
                      state,
                      cs,
                      tt,
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

  // --- 1. TIER FILTER CHIPS ---
  Widget _buildTierFilterChips(
    BuildContext context,
    ModelsViewController controller,
    ModelsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final filters = [
      {'id': 'all', 'label': 'All Models'},
      {
        'id': 'installed',
        'label': 'Installed (${state.installedModels.length})',
      },
      {'id': 'fast', 'label': 'Fast'},
      {'id': 'balanced', 'label': 'Balanced'},
      {'id': 'quality', 'label': 'Quality'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = state.selectedTierFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: cs.primary.withValues(alpha: 0.18),
              backgroundColor: cs.surfaceContainer,
              side: BorderSide(
                color: isSelected
                    ? cs.primary
                    : cs.outline.withValues(alpha: 0.2),
                width: isSelected ? 1.2 : 0.5,
              ),
              labelStyle: tt.labelMedium?.copyWith(
                color: isSelected ? cs.primary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (_) => controller.setTierFilter(f['id']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 2. ACTIVE MODEL HERO CARD ---
  Widget _buildActiveModelHeroCard(
    BuildContext context,
    ModelsViewController controller,
    ModelsState state,
    BunjiModel active,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final isInstalled = state.installedModels.any(
      (inst) => inst.id == active.id,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: cs.surfaceContainer,
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.12),
            blurRadius: 38,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  Icon(Icons.bolt_rounded, color: cs.primary, size: 20),
                  Text(
                    'ACTIVE MODEL',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ON-DEVICE',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Model Name & Tier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  active.name,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  active.tier.label,
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            active.description,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),

          // Status alerts if retired/deprecated
          if (active.status == BunjiModelStatus.retired) ...[
            _buildStatusAlert(
              title: 'This model is retired and no longer supported.',
              subtitle: 'Please select or download a modern replacement below.',
              color: cs.error,
              icon: Icons.error_outline_rounded,
              cs: cs,
              tt: tt,
            ),
            const SizedBox(height: 12),
          ] else if (active.status == BunjiModelStatus.deprecated) ...[
            _buildStatusAlert(
              title: 'This model is deprecated.',
              subtitle:
                  'It continues to function, but newer alternatives offer better speed and accuracy.',
              color: Colors.orange.shade800,
              icon: Icons.warning_amber_rounded,
              cs: cs,
              tt: tt,
            ),
            const SizedBox(height: 12),
          ],

          // Specs Grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpecItem(
                  'Size',
                  active.formattedSize,
                  Icons.save_outlined,
                  cs,
                  tt,
                ),
                _buildSpecItem(
                  'RAM',
                  '${active.minimumRecommendedRamMb} MB',
                  Icons.memory_rounded,
                  cs,
                  tt,
                ),
                _buildSpecItem('Format', 'GGUF', Icons.code_rounded, cs, tt),
                _buildSpecItem(
                  'State',
                  isInstalled ? 'Loaded' : 'Needs Download',
                  isInstalled
                      ? Icons.check_circle_outline_rounded
                      : Icons.downloading_rounded,
                  cs,
                  tt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(
    String label,
    String value,
    IconData icon,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 9.5,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAlert({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. CATALOG MODEL CARDS LIST ---
  Widget _buildCatalogSection(
    BuildContext context,
    ModelsViewController controller,
    ModelsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final models = state.filteredModels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Model Catalog',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Text(
              '${models.length} available',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (models.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: cs.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 40,
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'No matching models found',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
        else
          ...models.map(
            (m) => _buildModelCard(context, controller, state, m, cs, tt),
          ),
      ],
    );
  }

  Widget _buildModelCard(
    BuildContext context,
    ModelsViewController controller,
    ModelsState state,
    BunjiModel m,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final isSelected = state.selectedModelId == m.id;
    final isInstalled = state.installedModels.any((inst) => inst.id == m.id);
    final isDownloading = state.downloadingModelId == m.id;
    final isDeleting = state.deletingModelId == m.id;

    String badgeLabel;
    Color badgeColor;
    Color badgeTextColor;

    if (m.status == BunjiModelStatus.retired) {
      badgeLabel = 'Retired';
      badgeColor = cs.error.withValues(alpha: 0.15);
      badgeTextColor = cs.error;
    } else if (m.status == BunjiModelStatus.deprecated) {
      badgeLabel = 'Deprecated';
      badgeColor = Colors.orange.withValues(alpha: 0.15);
      badgeTextColor = Colors.orange.shade800;
    } else if (m.status == BunjiModelStatus.disabled) {
      badgeLabel = 'Disabled';
      badgeColor = Colors.amber.withValues(alpha: 0.15);
      badgeTextColor = Colors.amber.shade900;
    } else if (m.recommended) {
      badgeLabel = 'Recommended';
      badgeColor = cs.primary.withValues(alpha: 0.15);
      badgeTextColor = cs.primary;
    } else {
      badgeLabel = m.tier.label;
      badgeColor = cs.surfaceContainerHighest;
      badgeTextColor = cs.onSurface.withValues(alpha: 0.8);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 0.5,
          ),
          color: cs.surfaceContainer,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isInstalled
                  ? () => controller.updateSelectedModel(m.id)
                  : (!isDownloading &&
                            m.status != BunjiModelStatus.disabled &&
                            m.status != BunjiModelStatus.retired
                        ? () => controller.downloadAndInstallModel(m)
                        : null),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                m.name,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badgeLabel,
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: badgeTextColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m.formattedSize,
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          m.description,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.65),
                            fontSize: 11.5,
                          ),
                        ),
                        if (m.status == BunjiModelStatus.deprecated &&
                            isInstalled) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Installed. Consider migrating to a supported model.',
                            style: tt.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Download Progress Bar
            if (isDownloading) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: state.downloadProgress > 0
                      ? state.downloadProgress
                      : null,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.downloadStatusMessage ?? 'Downloading model...',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(state.downloadProgress * 100).toInt()}%',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),
            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isInstalled)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isSelected ? 'Active on device' : 'Installed',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                else if (!isDownloading)
                  Text(
                    'Not downloaded',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  )
                else
                  const SizedBox(),

                if (isInstalled)
                  Row(
                    children: [
                      if (!isSelected)
                        InkWell(
                          onTap: () => controller.updateSelectedModel(m.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Set Active',
                              style: tt.labelSmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: isDeleting
                            ? null
                            : () => _confirmDeleteModel(
                                context,
                                controller,
                                m,
                                cs,
                                tt,
                              ),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 14,
                                color: cs.error,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isDeleting ? 'Deleting...' : 'Delete',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else if (!isDownloading &&
                    m.status != BunjiModelStatus.disabled &&
                    m.status != BunjiModelStatus.retired)
                  InkWell(
                    onTap: () => controller.downloadAndInstallModel(m),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 14,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Download (${m.formattedSize})',
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. INFERENCE SETTINGS CARD ---
  Widget _buildInferenceSettingsCard(
    BuildContext context,
    ModelsViewController controller,
    ModelsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: cs.surfaceContainer,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(Icons.tune_rounded, size: 20, color: cs.primary),
              Text(
                'Inference & Response Tuning',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          Divider(
            height: 20,
            thickness: 0.5,
            color: cs.outline.withValues(alpha: 0.2),
          ),
          Text(
            'Response Style',
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildSegmentedSelector<String>(
            options: const ['Balanced', 'Concise', 'Detailed'],
            selected: state.responseStyle,
            labelBuilder: (s) => s,
            onSelected: controller.updateResponseStyle,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 14),
          _buildSwitchRow(
            title: 'Reasoning Mode',
            subtitle:
                'Enable visible step-by-step thinking for analytical questions',
            value: state.reasoningMode,
            onChanged: controller.toggleReasoningMode,
            cs: cs,
            tt: tt,
          ),
          _buildSwitchRow(
            title: 'Streaming Tokens',
            subtitle:
                'Show words immediately as the neural network generates them',
            value: state.streamingResponses,
            onChanged: controller.toggleStreamingResponses,
            cs: cs,
            tt: tt,
          ),
        ],
      ),
    );
  }

  // --- 5. CATALOG MANAGEMENT & DIAGNOSTICS ---
  Widget _buildCatalogDiagnosticsCard(
    BuildContext context,
    ModelsViewController controller,
    ModelsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: cs.surfaceContainer,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 20, color: cs.primary),
                  Text(
                    'Catalog Diagnostics',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.catalogSource,
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 20,
            thickness: 0.5,
            color: cs.outline.withValues(alpha: 0.2),
          ),
          _buildDiagRow('Version', state.catalogVersion, cs, tt),
          _buildDiagRow('Schema', 'v${state.catalogSchemaVersion}', cs, tt),
          _buildDiagRow(
            'Last refreshed',
            state.catalogLastRefresh != null
                ? '${state.catalogLastRefresh!.hour.toString().padLeft(2, '0')}:${state.catalogLastRefresh!.minute.toString().padLeft(2, '0')}'
                : 'Not refreshed yet',
            cs,
            tt,
          ),
          _buildDiagRow('Status', state.catalogStatus, cs, tt),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: state.isRefreshingCatalog
                    ? null
                    : controller.refreshCatalog,
                icon: state.isRefreshingCatalog
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh catalog'),
              ),
              OutlinedButton.icon(
                onPressed: controller.clearCatalogCache,
                icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                label: const Text('Clear cache'),
              ),
              OutlinedButton.icon(
                onPressed: controller.loadBundledCatalog,
                icon: const Icon(Icons.inventory_2_outlined, size: 16),
                label: const Text('Load bundled'),
              ),
              OutlinedButton.icon(
                onPressed: controller.validateCatalog,
                icon: const Icon(Icons.verified_outlined, size: 16),
                label: const Text('Validate'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagRow(
    String label,
    String value,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedSelector<T>({
    required List<T> options,
    required T selected,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelected,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final isSel = opt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSel ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  labelBuilder(opt),
                  style: tt.labelMedium?.copyWith(
                    color: isSel ? cs.onPrimary : cs.onSurface,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: cs.primary.withValues(alpha: 0.5),
            activeThumbColor: cs.primary,
          ),
        ],
      ),
    );
  }

  void _confirmDeleteModel(
    BuildContext context,
    ModelsViewController controller,
    BunjiModel model,
    ColorScheme cs,
    TextTheme tt,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete ${model.name}?',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will delete the model file and free up ${model.formattedSize} of storage.',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error.withValues(alpha: 0.15),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              controller.deleteModel(model.id);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
