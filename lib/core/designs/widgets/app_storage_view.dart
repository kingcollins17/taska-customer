import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color Palette (matching Debug Console Theme)
// ─────────────────────────────────────────────────────────────────────────────

class _StorageColors {
  _StorageColors._();

  static const Color scaffold = Color(0xFF111118);
  static const Color cardBg = Color(0xFF1E1E2A);
  static const Color codeBg = Color(0xFF161620);

  static const Color textPrimary = Color(0xFFE0E0E8);
  static const Color textSecondary = Color(0xFF8888A0);
  static const Color textMuted = Color(0xFF5C5C72);

  static const Color jsonKey = Color(0xFFC792EA);
  static const Color jsonString = Color(0xFFC3E88D);
  static const Color jsonNumber = Color(0xFF82AAFF);
  static const Color jsonBool = Color(0xFFFFCB6B);
  static const Color jsonNull = Color(0xFF6A6A80);
  static const Color jsonBracket = Color(0xFF89DDFF);

  static const Color accent = Color(0xFF00BFA5);
  static const Color divider = Color(0xFF2A2A38);
  static const Color searchBg = Color(0xFF22222E);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppStorageViewScreen
// ─────────────────────────────────────────────────────────────────────────────

class AppStorageViewScreen extends StatefulWidget {
  const AppStorageViewScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AppStorageViewScreen()),
    );
  }

  @override
  State<AppStorageViewScreen> createState() => _AppStorageViewScreenState();
}

class _AppStorageViewScreenState extends State<AppStorageViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _storageEntries = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStorageData() async {
    setState(() => _isLoading = true);
    final entries = <String, dynamic>{};

    try {
      // Load known StorageKeys
      for (final key in StorageKey.values) {
        final val = await appStorage.get(key);
        if (val != null) {
          entries[key.name] = _tryParseJson(val);
        }
      }

      // Load additional dynamic keys in Hive
      final allKeys = await appStorage.getKeys();
      for (final key in allKeys) {
        final keyStr = key.toString();
        if (!entries.containsKey(keyStr)) {
          final val = await appStorage.get(keyStr);
          if (val != null) {
            entries[keyStr] = _tryParseJson(val);
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _storageEntries = entries;
        _isLoading = false;
      });
    }
  }

  dynamic _tryParseJson(dynamic val) {
    if (val is String && val.trim().isNotEmpty) {
      final str = val.trim();
      if ((str.startsWith('{') && str.endsWith('}')) ||
          (str.startsWith('[') && str.endsWith(']'))) {
        try {
          return jsonDecode(str);
        } catch (_) {}
      }
    }
    return val;
  }

  Future<void> _deleteKey(String key) async {
    await appStorage.delete(key);
    await _loadStorageData();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _StorageColors.cardBg,
        title: const Text('Clear All Storage?', style: TextStyle(color: _StorageColors.textPrimary)),
        content: const Text('This will delete all saved app storage data.', style: TextStyle(color: _StorageColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await appStorage.clear();
      await _loadStorageData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _storageEntries.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      final keyMatch = entry.key.toLowerCase().contains(_searchQuery);
      final valMatch = entry.value.toString().toLowerCase().contains(_searchQuery);
      return keyMatch || valMatch;
    }).toList();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _StorageColors.scaffold,
        appBarTheme: const AppBarTheme(
          backgroundColor: _StorageColors.scaffold,
          foregroundColor: _StorageColors.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'AppStorage Inspector',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              tooltip: 'Refresh',
              onPressed: _loadStorageData,
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, size: 22, color: Colors.redAccent),
              tooltip: 'Clear All Storage',
              onPressed: _clearAll,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _StorageColors.accent))
            : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _StorageColors.searchBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _StorageColors.divider, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: _StorageColors.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search storage keys & values...',
                          hintStyle: TextStyle(color: _StorageColors.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: _StorageColors.textMuted, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    ),
                  ),

                  // Header Status Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL KEYS: ${_storageEntries.length}',
                          style: const TextStyle(
                            color: _StorageColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'FILTERED: ${filteredEntries.length}',
                          style: const TextStyle(
                            color: _StorageColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Entries List
                  Expanded(
                    child: filteredEntries.isEmpty
                        ? const Center(
                            child: Text(
                              'No storage entries found.',
                              style: TextStyle(color: _StorageColors.textMuted),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filteredEntries.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = filteredEntries[index];
                              return _StorageItemCard(
                                keyName: entry.key,
                                value: entry.value,
                                onDelete: () => _deleteKey(entry.key),
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
// Storage Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _StorageItemCard extends StatefulWidget {
  final String keyName;
  final dynamic value;
  final VoidCallback onDelete;

  const _StorageItemCard({
    required this.keyName,
    required this.value,
    required this.onDelete,
  });

  @override
  State<_StorageItemCard> createState() => _StorageItemCardState();
}

class _StorageItemCardState extends State<_StorageItemCard> {
  bool _isExpanded = true;

  bool get _isJson => widget.value is Map || widget.value is List;

  String get _typeLabel {
    if (widget.value is Map) return 'MAP';
    if (widget.value is List) return 'LIST';
    if (widget.value is String) return 'STRING';
    if (widget.value is bool) return 'BOOL';
    if (widget.value is num) return 'NUMBER';
    return 'UNKNOWN';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _StorageColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _StorageColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _StorageColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _StorageColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _typeLabel,
                    style: const TextStyle(
                      color: _StorageColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Key Name
                Expanded(
                  child: Text(
                    widget.keyName,
                    style: const TextStyle(
                      color: _StorageColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),

                // Copy Action
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18, color: _StorageColors.textMuted),
                  tooltip: 'Copy JSON string',
                  onPressed: () {
                    final str = _isJson ? jsonEncode(widget.value) : widget.value.toString();
                    Clipboard.setData(ClipboardData(text: str));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                // Delete Key Action
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  tooltip: 'Delete key',
                  onPressed: widget.onDelete,
                ),

                // Expand/Collapse Toggle
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: _StorageColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
          ),

          // Content Viewer
          if (_isExpanded) ...[
            const Divider(color: _StorageColors.divider, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _isJson
                  ? _StorageJsonTreeViewer(data: widget.value)
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _StorageColors.codeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        widget.value.toString(),
                        style: const TextStyle(
                          color: _StorageColors.textPrimary,
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive JSON Tree Viewer Widget
// ─────────────────────────────────────────────────────────────────────────────

class _StorageJsonTreeViewer extends StatelessWidget {
  final dynamic data;

  const _StorageJsonTreeViewer({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _StorageColors.codeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _StorageJsonNode(data: data, isRoot: true),
      ),
    );
  }
}

class _StorageJsonNode extends StatefulWidget {
  final dynamic data;
  final String? nodeKey;
  final bool isLast;
  final bool isRoot;

  const _StorageJsonNode({
    required this.data,
    this.nodeKey,
    this.isLast = true,
    this.isRoot = false,
  });

  @override
  State<_StorageJsonNode> createState() => _StorageJsonNodeState();
}

class _StorageJsonNodeState extends State<_StorageJsonNode> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    if (data is Map) {
      final keys = data.keys.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Icon(
                  _isExpanded ? Icons.arrow_drop_down_rounded : Icons.arrow_right_rounded,
                  color: _StorageColors.textMuted,
                  size: 18,
                ),
              ),
              if (widget.nodeKey != null) ...[
                Text(
                  '"${widget.nodeKey}": ',
                  style: const TextStyle(color: _StorageColors.jsonKey, fontFamily: 'monospace', fontSize: 12),
                ),
              ],
              Text('{', style: const TextStyle(color: _StorageColors.jsonBracket, fontFamily: 'monospace', fontSize: 12)),
              if (!_isExpanded)
                Text(
                  ' ${data.length} keys... }${widget.isLast ? '' : ','}',
                  style: const TextStyle(color: _StorageColors.textMuted, fontFamily: 'monospace', fontSize: 12),
                ),
            ],
          ),
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(keys.length, (index) {
                  final key = keys[index];
                  return _StorageJsonNode(
                    nodeKey: key.toString(),
                    data: data[key],
                    isLast: index == keys.length - 1,
                  );
                }),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 18),
                Text('}${widget.isLast ? '' : ','}', style: const TextStyle(color: _StorageColors.jsonBracket, fontFamily: 'monospace', fontSize: 12)),
              ],
            ),
          ],
        ],
      );
    }

    if (data is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Icon(
                  _isExpanded ? Icons.arrow_drop_down_rounded : Icons.arrow_right_rounded,
                  color: _StorageColors.textMuted,
                  size: 18,
                ),
              ),
              if (widget.nodeKey != null) ...[
                Text(
                  '"${widget.nodeKey}": ',
                  style: const TextStyle(color: _StorageColors.jsonKey, fontFamily: 'monospace', fontSize: 12),
                ),
              ],
              Text('[', style: const TextStyle(color: _StorageColors.jsonBracket, fontFamily: 'monospace', fontSize: 12)),
              if (!_isExpanded)
                Text(
                  ' ${data.length} items... ]${widget.isLast ? '' : ','}',
                  style: const TextStyle(color: _StorageColors.textMuted, fontFamily: 'monospace', fontSize: 12),
                ),
            ],
          ),
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(data.length, (index) {
                  return _StorageJsonNode(
                    data: data[index],
                    isLast: index == data.length - 1,
                  );
                }),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 18),
                Text(']${widget.isLast ? '' : ','}', style: const TextStyle(color: _StorageColors.jsonBracket, fontFamily: 'monospace', fontSize: 12)),
              ],
            ),
          ],
        ],
      );
    }

    // Scalar Values
    return Row(
      children: [
        const SizedBox(width: 18),
        if (widget.nodeKey != null) ...[
          Text(
            '"${widget.nodeKey}": ',
            style: const TextStyle(color: _StorageColors.jsonKey, fontFamily: 'monospace', fontSize: 12),
          ),
        ],
        _buildScalarText(data),
        if (!widget.isLast)
          const Text(',', style: TextStyle(color: _StorageColors.textMuted, fontFamily: 'monospace', fontSize: 12)),
      ],
    );
  }

  Widget _buildScalarText(dynamic val) {
    if (val == null) {
      return const Text('null', style: TextStyle(color: _StorageColors.jsonNull, fontFamily: 'monospace', fontSize: 12));
    }
    if (val is bool) {
      return Text('$val', style: const TextStyle(color: _StorageColors.jsonBool, fontFamily: 'monospace', fontSize: 12));
    }
    if (val is num) {
      return Text('$val', style: const TextStyle(color: _StorageColors.jsonNumber, fontFamily: 'monospace', fontSize: 12));
    }
    return SelectableText(
      '"$val"',
      style: const TextStyle(color: _StorageColors.jsonString, fontFamily: 'monospace', fontSize: 12),
    );
  }
}
