import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/providers/task_providers.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  final String taskId;

  const MatchingScreen({super.key, required this.taskId});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      final task = ref.read(taskDetailProvider(widget.taskId));
      if (task.value?.status?.toLowerCase().contains('assigned') != true) {
        ref.invalidate(taskDetailProvider(widget.taskId));
        ref.invalidate(taskAssignmentProvider(widget.taskId));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final assigmnentAsync = ref.watch(taskAssignmentProvider(widget.taskId));
    final theme = Theme.of(context);

    final bool isAccepted =
        taskAsync.hasValue &&
        (taskAsync.value?.status?.toLowerCase().contains('assigned') ??
            false) &&
        (taskAsync.value?.assignment != null || assigmnentAsync.value != null);
    final isPending = taskAsync.isLoading || !isAccepted;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: isAccepted
              ? const _AcceptedProviderCard()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const _Spinner(),
                    const SizedBox(height: 64),
                    _TimelineSection(isPending: isPending),
                    const Spacer(),
                    // A nice cancel button if they want to cancel searching
                    TextButton(
                      onPressed: () {
                        // In the future, cancel task matching here
                        context.pop();
                      },
                      child: Text(
                        'Go Back',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: SpinKitRipple(
            color: theme.colorScheme.primary,
            size: 160.0,
            borderWidth: 8.0,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.05, 1.05),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _TimelineSection extends StatelessWidget {
  final bool isPending;

  const _TimelineSection({required this.isPending});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
          children: [
            _buildTimelineStep(
              theme: theme,
              title: 'Finding your Tasker',
              subtitle: 'Scanning network for the nearest qualified Tasker.',
              isActive: !isPending,
              isCompleted: isPending,
              isLast: false,
            ),
            _buildTimelineStep(
              theme: theme,
              title: 'Awaiting confirmation',
              subtitle: 'A Tasker has been matched. Awaiting their response...',
              isActive: isPending,
              isCompleted: false,
              isLast: true,
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildTimelineStep({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
    required bool isLast,
  }) {
    final color = isCompleted
        ? theme.colorScheme.primary
        : isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? color : Colors.transparent,
                  border: Border.all(
                    color: color,
                    width: isActive || isCompleted ? 2 : 1.5,
                  ),
                ),
                child: isCompleted
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedTick01,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      )
                    : isActive
                    ? Center(child: SpinKitPulse(color: color, size: 12.0))
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.15),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isActive || isCompleted
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isActive || isCompleted
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptedProviderCard extends StatelessWidget {
  const _AcceptedProviderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Header with Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.3,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedTick02,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tasker Matched',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar and Info
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Text(
                                    'AJ',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedShield01,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alex Johnson',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedStar,
                                        size: 20,
                                        color: Colors.amber.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.9',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        ' (142 reviews)',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Compact Stats
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.04,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCompactStat(
                                theme,
                                HugeIcons.strokeRoundedLocation01,
                                '2.5 km',
                                'Away',
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: theme.colorScheme.outlineVariant
                                    .withOpacity(0.5),
                              ),
                              _buildCompactStat(
                                theme,
                                HugeIcons.strokeRoundedTime02,
                                '10 min',
                                'ETA',
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: theme.colorScheme.outlineVariant
                                    .withOpacity(0.5),
                              ),
                              _buildCompactStat(
                                theme,
                                HugeIcons.strokeRoundedShield01,
                                '98%',
                                'Trust',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedMessage02,
                                  color: theme.colorScheme.primary,
                                ),
                                label: const Text(
                                  'Message',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCall,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                label: const Text(
                                  'Call',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuart),
      ],
    );
  }

  Widget _buildCompactStat(
    ThemeData theme,
    dynamic icon,
    String value,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
