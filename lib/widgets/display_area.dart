import 'package:advanced_caculator/models/calculator_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../utils/constants.dart';

class DisplayArea extends StatefulWidget {
  const DisplayArea({super.key});

  @override
  State<DisplayArea> createState() => _DisplayAreaState();
}

class _DisplayAreaState extends State<DisplayArea>
    with TickerProviderStateMixin {
  // Shake animation for errors
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  // Fade-in for result
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  String _prevError = '';
  String _prevResult = '';

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: AppDimens.shakeErrorDuration,
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: AppDimens.fadeInDuration,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  void _triggerFade() {
    _fadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final history = context.watch<HistoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger animations on state changes
    if (calc.error.isNotEmpty && calc.error != _prevError) {
      _triggerShake();
    }
    if (calc.result.isNotEmpty && calc.result != _prevResult) {
      _triggerFade();
    }
    _prevError = calc.error;
    _prevResult = calc.result;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe right → delete last char
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          context.read<CalculatorProvider>().clearLastChar();
        }
      },
      onVerticalDragEnd: (details) {
        // Swipe up → open history
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -200) {
          _showHistoryPanel(context);
        }
      },
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            _shakeController.isAnimating
                ? _shakeAnim.value *
                      ((_shakeController.value * 10).toInt().isEven ? 1 : -1)
                : 0,
            0,
          ),
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimens.displayRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Mode + Angle indicator ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ModeChip(
                    label: calc.mode.label,
                    color: isDark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent,
                  ),
                  Row(
                    children: [
                      if (calc.memoryHasValue)
                        _ModeChip(label: 'M', color: Colors.green),
                      const SizedBox(width: 6),
                      _ModeChip(
                        label: calc.angleMode.label,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.lightSubtext,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── History preview (last 3) ──
              if (history.recentPreview.isNotEmpty && calc.expression.isEmpty)
                _HistoryPreview(entries: history.recentPreview),

              const Spacer(),

              // ── Expression ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  calc.expression.isEmpty ? '0' : calc.expression,
                  style: AppFonts.displayExpression.copyWith(
                    color: calc.expression.isEmpty ? subColor : textColor,
                  ),
                  maxLines: 1,
                ),
              ),

              const SizedBox(height: 6),

              // ── Result / Error ──
              if (calc.hasError)
                Text(
                  calc.error,
                  style: AppFonts.displayResult.copyWith(
                    color: Colors.red.shade400,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.end,
                )
              else if (calc.result.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    '= ${calc.result}',
                    style: AppFonts.displayResult.copyWith(
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightAccent,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HistoryBottomSheet(),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ModeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HistoryPreview extends StatelessWidget {
  final List entries;

  const _HistoryPreview({required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: entries.map<Widget>((e) {
        return GestureDetector(
          onTap: () {
            context.read<CalculatorProvider>().restoreFromHistory(
              e.expression,
              e.result,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${e.expression} = ${e.result}',
              style: AppFonts.historyItem.copyWith(color: subColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HistoryBottomSheet extends StatelessWidget {
  const _HistoryBottomSheet();

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: subColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (!history.isEmpty)
                      TextButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear history?'),
                              content: const Text(
                                'All calculations will be deleted.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            context.read<HistoryProvider>().clearAll();
                          }
                        },
                        child: Text(
                          'Clear all',
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(),

              // List
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          'No history yet',
                          style: TextStyle(color: subColor),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: history.count,
                        itemBuilder: (ctx, i) {
                          final entry = history.history[i];
                          return ListTile(
                            title: Text(
                              entry.expression,
                              style: AppFonts.historyItem.copyWith(
                                color: subColor,
                              ),
                            ),
                            subtitle: Text(
                              '= ${entry.result}',
                              style: AppFonts.displayExpression.copyWith(
                                color: textColor,
                                fontSize: 20,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 16,
                                color: subColor,
                              ),
                              onPressed: () => context
                                  .read<HistoryProvider>()
                                  .removeEntry(entry.id),
                            ),
                            onTap: () {
                              context
                                  .read<CalculatorProvider>()
                                  .restoreFromHistory(
                                    entry.expression,
                                    entry.result,
                                  );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
