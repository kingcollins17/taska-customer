import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeker_app/core/utils/debug_log.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color palette for the debug console (dark theme)
// ─────────────────────────────────────────────────────────────────────────────

class _ConsoleColors {
  _ConsoleColors._();

  // Backgrounds
  static const Color scaffold = Color(0xFF111118);
  static const Color surfaceVariant = Color(0xFF22222E);
  static const Color cardBg = Color(0xFF1E1E2A);
  static const Color codeBg = Color(0xFF161620);

  // Text
  static const Color textPrimary = Color(0xFFE0E0E8);
  static const Color textSecondary = Color(0xFF8888A0);
  static const Color textMuted = Color(0xFF5C5C72);

  // JSON syntax highlighting
  static const Color jsonKey = Color(0xFFC792EA); // purple for keys
  static const Color jsonString = Color(0xFFC3E88D); // green for strings
  static const Color jsonNumber = Color(0xFF82AAFF); // blue for numbers
  static const Color jsonBool = Color(0xFFFFCB6B); // amber for bools
  static const Color jsonNull = Color(0xFF6A6A80); // grey for null
  static const Color jsonBracket = Color(0xFF89DDFF); // cyan for brackets
  static const Color jsonColon = Color(0xFF89DDFF);

  // Log type colors
  static const Color info = Color(0xFF00BFA5);
  static const Color warn = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);

  // Accents
  static const Color chipSelected = Color(0xFF00BFA5);
  static const Color chipDefault = Color(0xFF2A2A38);
  static const Color divider = Color(0xFF2A2A38);
  static const Color searchBg = Color(0xFF22222E);
  static const Color expandCollapseBtn = Color(0xFF5C5C72);
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Console View
// ─────────────────────────────────────────────────────────────────────────────

class DebugConsoleView extends StatefulWidget {
  const DebugConsoleView({super.key});

  static void show(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DebugConsoleView()));
  }

  @override
  State<DebugConsoleView> createState() => _DebugConsoleViewState();
}

class _DebugConsoleViewState extends State<DebugConsoleView> {
  final TextEditingController _searchController = TextEditingController();
  LogType? _selectedFilter;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _typeColor(LogType type) {
    switch (type) {
      case LogType.info:
        return _ConsoleColors.info;
      case LogType.warn:
        return _ConsoleColors.warn;
      case LogType.error:
        return _ConsoleColors.error;
    }
  }

  String _typeLabel(LogType type) {
    switch (type) {
      case LogType.info:
        return 'INFO';
      case LogType.warn:
        return 'WARN';
      case LogType.error:
        return 'ERROR';
    }
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _ConsoleColors.scaffold,
        appBarTheme: const AppBarTheme(
          backgroundColor: _ConsoleColors.scaffold,
          foregroundColor: _ConsoleColors.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Debug Console',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
              tooltip: 'Clear all logs',
              onPressed: () {
                LogCache.instance.clearLogs();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: _ConsoleColors.searchBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _ConsoleColors.divider,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: _ConsoleColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search logs...',
                    hintStyle: TextStyle(
                      color: _ConsoleColors.textMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: _ConsoleColors.textMuted,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
            ),

            // ── Filter chips ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All Logs',
                    selected: _selectedFilter == null,
                    onTap: () => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Info',
                    selected: _selectedFilter == LogType.info,
                    onTap: () => setState(() => _selectedFilter = LogType.info),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Warnings',
                    selected: _selectedFilter == LogType.warn,
                    onTap: () => setState(() => _selectedFilter = LogType.warn),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Errors',
                    selected: _selectedFilter == LogType.error,
                    onTap: () =>
                        setState(() => _selectedFilter = LogType.error),
                  ),
                ],
              ),
            ),

            // ── Log list ────────────────────────────────────────────────
            Expanded(
              child: AnimatedBuilder(
                animation: LogCache.instance,
                builder: (context, _) {
                  final logs = LogCache.instance.logs.reversed.where((log) {
                    if (_selectedFilter != null &&
                        log.type != _selectedFilter) {
                      return false;
                    }
                    if (_searchQuery.isNotEmpty) {
                      final dataStr = log.data.toString().toLowerCase();
                      if (!dataStr.contains(_searchQuery)) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();

                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.terminal_rounded,
                            size: 48,
                            color: _ConsoleColors.textMuted.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No logs found',
                            style: TextStyle(
                              color: _ConsoleColors.textMuted.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _LogEntryCard(
                        log: log,
                        typeColor: _typeColor(log.type),
                        typeLabel: _typeLabel(log.type),
                        timestamp: _formatTimestamp(log.timestamp),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _ConsoleColors.chipSelected
              : _ConsoleColors.chipDefault,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _ConsoleColors.chipSelected
                : _ConsoleColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color:
                    selected ? Colors.white : _ConsoleColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Log Entry Card
// ─────────────────────────────────────────────────────────────────────────────

class _LogEntryCard extends StatelessWidget {
  final LogData log;
  final Color typeColor;
  final String typeLabel;
  final String timestamp;

  const _LogEntryCard({
    required this.log,
    required this.typeColor,
    required this.typeLabel,
    required this.timestamp,
  });

  void _copyToClipboard(BuildContext context) {
    final text = log.isJson
        ? const JsonEncoder.withIndent('  ').convert(log.rawData)
        : log.data.toString();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: _ConsoleColors.surfaceVariant,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _ConsoleColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ConsoleColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: type badge + timestamp + copy ───────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Timestamp
                Text(
                  timestamp,
                  style: const TextStyle(
                    color: _ConsoleColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                // Copy button
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _copyToClipboard(context),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: _ConsoleColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content area ───────────────────────────────────────────
          if (log.isJson)
            _JsonViewer(data: log.rawData)
          else
            _LogViewer(text: log.data.toString()),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plain Text Log Viewer
// ─────────────────────────────────────────────────────────────────────────────

class _LogViewer extends StatelessWidget {
  final String text;

  const _LogViewer({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ConsoleColors.codeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.5,
          color: _ConsoleColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON Viewer — Browser DevTools style
// ─────────────────────────────────────────────────────────────────────────────

class _JsonViewer extends StatefulWidget {
  final dynamic data;

  const _JsonViewer({required this.data});

  @override
  State<_JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<_JsonViewer> {
  bool _allExpanded = false;

  /// A unique key that forces rebuild when expand/collapse all is toggled.
  int _rebuildKey = 0;

  String _summaryLabel() {
    final data = widget.data;
    if (data is List) {
      return '[ ${data.length} item${data.length == 1 ? '' : 's'} ]';
    }
    if (data is Map) {
      return '{ ${data.length} key${data.length == 1 ? '' : 's'} }';
    }
    return '';
  }

  void _toggleAll(bool expand) {
    setState(() {
      _allExpanded = expand;
      _rebuildKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── JSON header bar ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
          child: Row(
            children: [
              // JSON badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _ConsoleColors.jsonBracket.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'JSON',
                  style: TextStyle(
                    color: _ConsoleColors.jsonBracket,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Summary label
              Text(
                _summaryLabel(),
                style: const TextStyle(
                  color: _ConsoleColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              // Expand All
              _HeaderAction(
                icon: Icons.unfold_more_rounded,
                label: 'Expand All',
                onTap: () => _toggleAll(true),
              ),
              const SizedBox(width: 6),
              // Collapse All
              _HeaderAction(
                icon: Icons.unfold_less_rounded,
                label: 'Collapse All',
                onTap: () => _toggleAll(false),
              ),
            ],
          ),
        ),

        // ── JSON tree ────────────────────────────────────────────
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _ConsoleColors.codeBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _JsonNode(
              key: ValueKey(_rebuildKey),
              data: widget.data,
              indent: 0,
              initiallyExpanded: _allExpanded,
              isRoot: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _ConsoleColors.expandCollapseBtn),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                color: _ConsoleColors.expandCollapseBtn,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recursive JSON Node
// ─────────────────────────────────────────────────────────────────────────────

class _JsonNode extends StatefulWidget {
  final dynamic data;
  final int indent;
  final bool initiallyExpanded;
  final String? keyName;
  final bool isRoot;
  final bool isLast;

  const _JsonNode({
    super.key,
    required this.data,
    required this.indent,
    this.initiallyExpanded = false,
    this.keyName,
    this.isRoot = false,
    this.isLast = true,
  });

  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _arrowController;
  late Animation<double> _arrowRotation;

  bool get _isExpandable => widget.data is Map || widget.data is List;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isRoot || widget.initiallyExpanded;
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _arrowRotation = Tween<double>(begin: 0, end: 0.25).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
    if (_expanded) _arrowController.value = 1.0;
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _arrowController.forward();
      } else {
        _arrowController.reverse();
      }
    });
  }

  /// Builds a collapsed summary like `{ id, name, ... }` or `[ 3 items ]`.
  String _collapsedSummary() {
    final data = widget.data;
    if (data is Map) {
      final keys = data.keys.toList();
      if (keys.length <= 4) {
        return '{ ${keys.join(', ')} }';
      }
      return '{ ${keys.take(4).join(', ')}, … }';
    }
    if (data is List) {
      return '[ ${data.length} item${data.length == 1 ? '' : 's'} ]';
    }
    return '';
  }

  /// Opening bracket for the expandable node.
  String _openBracket() => widget.data is Map ? '{' : '[';

  /// Closing bracket for the expandable node.
  String _closeBracket() {
    final bracket = widget.data is Map ? '}' : ']';
    return widget.isLast ? bracket : '$bracket,';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpandable) {
      return _buildPrimitiveRow();
    }
    return _buildExpandableNode();
  }

  Widget _buildPrimitiveRow() {
    return Padding(
      padding: EdgeInsets.only(left: widget.indent * 18.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indent spacer for arrow alignment
          const SizedBox(width: 18),
          if (widget.keyName != null) ...[
            Text(
              '"${widget.keyName}"',
              style: const TextStyle(
                color: _ConsoleColors.jsonKey,
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
            const Text(
              ': ',
              style: TextStyle(
                color: _ConsoleColors.jsonColon,
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
          ],
          _buildValueText(widget.data, trailing: widget.isLast ? '' : ','),
        ],
      ),
    );
  }

  Widget _buildExpandableNode() {
    final data = widget.data;
    final entries = data is Map
        ? data.entries.toList()
        : (data as List).asMap().entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header row (arrow + key + bracket/summary) ───────────
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(left: widget.indent * 18.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated arrow
                RotationTransition(
                  turns: _arrowRotation,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 16,
                    color: _ConsoleColors.textMuted,
                  ),
                ),
                const SizedBox(width: 2),
                if (widget.keyName != null) ...[
                  Text(
                    '"${widget.keyName}"',
                    style: const TextStyle(
                      color: _ConsoleColors.jsonKey,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
                  const Text(
                    ': ',
                    style: TextStyle(
                      color: _ConsoleColors.jsonColon,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
                ],
                if (_expanded)
                  Text(
                    _openBracket(),
                    style: const TextStyle(
                      color: _ConsoleColors.jsonBracket,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  )
                else ...[
                  Text(
                    _collapsedSummary(),
                    style: const TextStyle(
                      color: _ConsoleColors.textMuted,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Children (when expanded) ─────────────────────────────
        if (_expanded) ...[
          for (var i = 0; i < entries.length; i++)
            _buildChild(entries[i], i == entries.length - 1),

          // Closing bracket
          Padding(
            padding: EdgeInsets.only(left: widget.indent * 18.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 18),
                Text(
                  _closeBracket(),
                  style: const TextStyle(
                    color: _ConsoleColors.jsonBracket,
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChild(dynamic entry, bool isLast) {
    final String? childKey;
    final dynamic childValue;

    if (entry is MapEntry) {
      childKey = entry.key.toString();
      childValue = entry.value;
    } else if (entry is MapEntry<int, dynamic>) {
      // List index entry
      childKey = null;
      childValue = entry.value;
    } else {
      childKey = null;
      childValue = entry;
    }

    return _JsonNode(
      data: childValue,
      indent: widget.indent + 1,
      initiallyExpanded: widget.initiallyExpanded,
      keyName: childKey,
      isLast: isLast,
    );
  }

  static Widget _buildValueText(dynamic value, {String trailing = ''}) {
    String text;
    Color color;

    if (value == null) {
      text = 'null';
      color = _ConsoleColors.jsonNull;
    } else if (value is String) {
      text = '"$value"';
      color = _ConsoleColors.jsonString;
    } else if (value is num) {
      text = '$value';
      color = _ConsoleColors.jsonNumber;
    } else if (value is bool) {
      text = '$value';
      color = _ConsoleColors.jsonBool;
    } else {
      text = '$value';
      color = _ConsoleColors.textPrimary;
    }

    return Text(
      '$text$trailing',
      style: TextStyle(
        color: color,
        fontFamily: 'monospace',
        fontSize: 12.5,
        height: 1.6,
      ),
    );
  }
}
