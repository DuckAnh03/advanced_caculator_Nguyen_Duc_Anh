import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_settings.dart';
import '../models/calculator_mode.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final history = context.watch<HistoryProvider>();
    final settings = calc.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          // ── Appearance ──────────────────────────────────────────────────
          _SectionHeader(label: 'Appearance', color: subColor),

          _SettingsCard(
            color: surfaceColor,
            children: [
              _SegmentRow(
                label: 'Theme',
                icon: Icons.palette_outlined,
                textColor: textColor,
                subColor: subColor,
                options: AppTheme.values.map((t) => t.label).toList(),
                selected: settings.theme.label,
                onChanged: (val) {
                  final t = AppTheme.values.firstWhere((e) => e.label == val);
                  themeProvider.setTheme(t);
                  calc.updateSettings(settings.copyWith(theme: t));
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Calculator ──────────────────────────────────────────────────
          _SectionHeader(label: 'Calculator', color: subColor),

          _SettingsCard(
            color: surfaceColor,
            children: [
              _SliderRow(
                label: 'Decimal precision',
                icon: Icons.numbers_outlined,
                textColor: textColor,
                subColor: subColor,
                value: settings.decimalPrecision.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                onChanged: (v) => calc.updateSettings(
                  settings.copyWith(decimalPrecision: v.toInt()),
                ),
              ),
              _Divider(color: subColor),
              _SegmentRow(
                label: 'Angle mode',
                icon: Icons.rotate_right_outlined,
                textColor: textColor,
                subColor: subColor,
                options: AngleMode.values.map((a) => a.label).toList(),
                selected: settings.angleMode.label,
                onChanged: (val) {
                  final mode = AngleMode.values.firstWhere(
                    (e) => e.label == val,
                  );
                  calc.updateSettings(settings.copyWith(angleMode: mode));
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Feedback ────────────────────────────────────────────────────
          _SectionHeader(label: 'Feedback', color: subColor),

          _SettingsCard(
            color: surfaceColor,
            children: [
              _SwitchRow(
                label: 'Haptic feedback',
                icon: Icons.vibration_outlined,
                textColor: textColor,
                subColor: subColor,
                value: settings.hapticFeedback,
                onChanged: (v) =>
                    calc.updateSettings(settings.copyWith(hapticFeedback: v)),
              ),
              _Divider(color: subColor),
              _SwitchRow(
                label: 'Sound effects',
                icon: Icons.volume_up_outlined,
                textColor: textColor,
                subColor: subColor,
                value: settings.soundEffects,
                onChanged: (v) =>
                    calc.updateSettings(settings.copyWith(soundEffects: v)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── History ─────────────────────────────────────────────────────
          _SectionHeader(label: 'History', color: subColor),

          _SettingsCard(
            color: surfaceColor,
            children: [
              _SegmentRow(
                label: 'Max history size',
                icon: Icons.history_rounded,
                textColor: textColor,
                subColor: subColor,
                options: ['25', '50', '100'],
                selected: settings.historySize.toString(),
                onChanged: (val) {
                  final size = int.parse(val);
                  history.updateMaxSize(size);
                  calc.updateSettings(settings.copyWith(historySize: size));
                },
              ),
              _Divider(color: subColor),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
                title: Text(
                  'Clear all history',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                subtitle: Text(
                  '${history.count} entries',
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
                onTap: history.isEmpty
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear history?'),
                            content: const Text(
                              'All calculation history will be deleted permanently.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(color: Colors.red.shade400),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          context.read<HistoryProvider>().clearAll();
                        }
                      },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color,
      ),
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  final Color color;
  final List<Widget> children;
  const _SettingsCard({required this.color, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});
  @override
  Widget build(BuildContext context) => Divider(
    color: color.withOpacity(0.15),
    height: 1,
    indent: 16,
    endIndent: 16,
  );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor, subColor;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.subColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.tertiary;
    return ListTile(
      leading: Icon(icon, color: subColor, size: 22),
      title: Text(label, style: TextStyle(color: textColor, fontSize: 15)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: accent),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor, subColor;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentRow({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.subColor,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.tertiary;
    return ListTile(
      leading: Icon(icon, color: subColor, size: 22),
      title: Text(label, style: TextStyle(color: textColor, fontSize: 15)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: SegmentedButton<String>(
          segments: options
              .map((o) => ButtonSegment(value: o, label: Text(o)))
              .toList(),
          selected: {selected},
          onSelectionChanged: (s) => onChanged(s.first),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? Colors.white
                  : subColor,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? accent
                  : Colors.transparent,
            ),
          ),
        ),
      ),
      isThreeLine: true,
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor, subColor;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.subColor,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.tertiary;
    return ListTile(
      leading: Icon(icon, color: subColor, size: 22),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor, fontSize: 15)),
          Text(
            value.toInt().toString(),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: accent,
        onChanged: onChanged,
      ),
      isThreeLine: true,
    );
  }
}
