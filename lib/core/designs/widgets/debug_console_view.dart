import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeker_app/core/utils/debug_log.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              LogCache.instance.clearLogs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search logs...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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
                const SizedBox(width: 8),
                DropdownButton<LogType?>(
                  value: _selectedFilter,
                  hint: const Text('All Types'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...LogType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedFilter = val;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: LogCache.instance,
              builder: (context, _) {
                final logs = LogCache.instance.logs.reversed.where((log) {
                  if (_selectedFilter != null && log.type != _selectedFilter) {
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
                  return const Center(child: Text('No logs found.'));
                }

                return ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    Color typeColor;
                    switch (log.type) {
                      case LogType.info:
                        typeColor = Colors.blue;
                        break;
                      case LogType.warn:
                        typeColor = Colors.orange;
                        break;
                      case LogType.error:
                        typeColor = Colors.red;
                        break;
                    }

                    return ExpansionTile(
                      title: Text(
                        log.type.name.toUpperCase(),
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${log.timestamp.toIso8601String().split('T').last}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: Colors.grey.withOpacity(0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy'),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: log.data.toString()),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Copied to clipboard'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SelectableText(
                                log.data.toString(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
