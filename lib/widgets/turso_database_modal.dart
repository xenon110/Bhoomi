import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../services/turso/turso_config.dart';
import '../services/turso/turso_service.dart';
import '../theme/app_theme.dart';

class TursoDatabaseModal extends StatefulWidget {
  const TursoDatabaseModal({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const TursoDatabaseModal(),
    );
  }

  @override
  State<TursoDatabaseModal> createState() => _TursoDatabaseModalState();
}

class _TursoDatabaseModalState extends State<TursoDatabaseModal> {
  final TursoService _turso = TursoService();
  final StorageService _storage = StorageService();

  late TextEditingController _tokenController;
  late TextEditingController _urlController;
  late TextEditingController _sqlController;

  bool _isTesting = false;
  bool _isSyncing = false;
  bool _isRunningQuery = false;
  String? _statusMessage;
  String? _queryError;
  int? _queryTimeMs;
  List<Map<String, dynamic>>? _queryResults;
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: _turso.authToken);
    _urlController = TextEditingController(text: _turso.pipelineUrl);
    _sqlController = TextEditingController(
      text: 'SELECT id, name, category, rate_per_day, village FROM bhoomi_equipment LIMIT 5;',
    );
    _turso.addListener(_onTursoChanged);
  }

  @override
  void dispose() {
    _turso.removeListener(_onTursoChanged);
    _tokenController.dispose();
    _urlController.dispose();
    _sqlController.dispose();
    super.dispose();
  }

  void _onTursoChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleTestAndSave() async {
    setState(() {
      _isTesting = true;
      _statusMessage = null;
    });

    final token = _tokenController.text.trim();
    final url = _urlController.text.trim();

    final success = await _turso.updateCredentials(
      token: token,
      pipelineUrl: url.isNotEmpty ? url : null,
    );

    if (mounted) {
      setState(() {
        _isTesting = false;
        if (success) {
          _statusMessage = 'Connected successfully to Turso Cloud (aws-ap-south-1 · ${_turso.latencyMs}ms)!';
        } else {
          _statusMessage = _turso.lastError ?? 'Connection failed. Please check your token.';
        }
      });
    }
  }

  Future<void> _handleSyncAll() async {
    if (!_turso.isConnected) {
      setState(() {
        _statusMessage = 'Please connect to Turso with a valid token first.';
      });
      return;
    }

    setState(() {
      _isSyncing = true;
      _statusMessage = null;
    });

    await _storage.syncAllToTurso();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _statusMessage = 'All farm listings, equipment, and ledger data synchronized to Turso 24/7 cloud!';
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _tokenController.text = data.text!.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token pasted from clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _runCustomSql() async {
    final sql = _sqlController.text.trim();
    if (sql.isEmpty) return;

    setState(() {
      _isRunningQuery = true;
      _queryResults = null;
      _queryError = null;
      _queryTimeMs = null;
    });

    final sw = Stopwatch()..start();
    try {
      if (sql.toLowerCase().startsWith('select')) {
        final rows = await _turso.queryRaw(sql);
        sw.stop();
        setState(() {
          _queryResults = rows;
          _queryTimeMs = sw.elapsedMilliseconds;
        });
      } else {
        final ok = await _turso.executeRaw(sql);
        sw.stop();
        setState(() {
          _queryTimeMs = sw.elapsedMilliseconds;
          if (ok) {
            _queryResults = [];
          } else {
            _queryError = 'Query execution failed. Check SQL syntax or permissions.';
          }
        });
      }
    } catch (e) {
      sw.stop();
      setState(() {
        _queryError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isRunningQuery = false);
      }
    }
  }

  void _loadPreset(String sql) {
    setState(() {
      _sqlController.text = sql;
      _queryResults = null;
      _queryError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isConnected = _turso.isConnected;

    Color badgeBg;
    Color badgeColor;
    String statusTitle;
    IconData statusIcon;

    switch (_turso.state) {
      case TursoConnectionState.connected:
        badgeBg = const Color(0xFFE2EFDF);
        badgeColor = const Color(0xFF1E4D2B);
        statusTitle = 'Connected (24/7 Cloud Edge)';
        statusIcon = Icons.cloud_done_rounded;
        break;
      case TursoConnectionState.connecting:
        badgeBg = const Color(0xFFFFF7E6);
        badgeColor = const Color(0xFFC98F1C);
        statusTitle = 'Testing connection...';
        statusIcon = Icons.cloud_sync_rounded;
        break;
      case TursoConnectionState.invalidToken:
        badgeBg = const Color(0xFFFFF3CD);
        badgeColor = const Color(0xFF856404);
        statusTitle = 'Auth Token Required / Incomplete';
        statusIcon = Icons.key_outlined;
        break;
      case TursoConnectionState.offline:
      case TursoConnectionState.error:
      case TursoConnectionState.uninitialized:
        badgeBg = const Color(0xFFFDE8E8);
        badgeColor = const Color(0xFFB03A2E);
        statusTitle = 'Offline (Using Local Storage)';
        statusIcon = Icons.cloud_off_rounded;
        break;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD6C4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Cloud Badge
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EFDF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.dns_rounded, color: Color(0xFF1E4D2B), size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Turso Cloud Database',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Serverless Edge SQLite · 24/7 Free Cloud',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Connection Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: badgeColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusTitle,
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                        Text(
                          isConnected
                              ? 'Region: AWS Mumbai (ap-south-1) · ${_turso.latencyMs}ms'
                              : 'Local-first fallback active. Zero data loss.',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: badgeColor.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'ONLINE',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Database URL
            const Text(
              'Database Endpoint (HTTP Pipeline):',
              style: TextStyle(
                fontFamily: 'Mukta',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFE4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDDD6C4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      TursoConfig.defaultPipelineUrl,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        const ClipboardData(text: TursoConfig.defaultPipelineUrl),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Endpoint copied')),
                      );
                    },
                    child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Auth Token Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Turso Auth Token (JWT):',
                  style: TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: _pasteFromClipboard,
                  child: Row(
                    children: const [
                      Icon(Icons.content_paste_rounded, size: 14, color: AppColors.primaryGreen),
                      SizedBox(width: 4),
                      Text(
                        'Paste Full Token',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _tokenController,
              obscureText: _obscureToken,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Paste eyJhbGciOiJFZERTQ... token here',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF9F7F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureToken ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _obscureToken = !_obscureToken),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Copy the full token from your Turso dashboard popup and paste here.',
              style: TextStyle(
                fontFamily: 'Mukta',
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFFE2EFDF) : const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isConnected ? const Color(0xFF1E4D2B) : const Color(0xFF856404),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle_outline : Icons.info_outline,
                      size: 16,
                      color: isConnected ? const Color(0xFF1E4D2B) : const Color(0xFF856404),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isConnected ? const Color(0xFF1E4D2B) : const Color(0xFF856404),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Action Buttons (Test & Sync)
            Row(
              children: [
                // Save & Test Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _handleTestAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.bolt_rounded, size: 18),
                    label: Text(
                      _isTesting ? 'Testing...' : 'Save & Test Connection',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Sync Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing ? null : _handleSyncAll,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                            ),
                          )
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: Text(
                      _isSyncing ? 'Syncing...' : 'Sync Cloud',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- LIVE SQL QUERY CONSOLE ---
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E0D2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E4D2B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.terminal_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Live SQL Query Console',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Execute raw queries directly against your Turso 24/7 cloud database:',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Preset Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip(
                          label: 'Equipment',
                          sql: 'SELECT id, name, category, rate_per_day, village FROM bhoomi_equipment LIMIT 5;',
                        ),
                        const SizedBox(width: 6),
                        _buildPresetChip(
                          label: 'Farmland',
                          sql: 'SELECT id, title, total_acres, price_per_acre_lakhs, village FROM bhoomi_farmland LIMIT 5;',
                        ),
                        const SizedBox(width: 6),
                        _buildPresetChip(
                          label: 'Ledger',
                          sql: 'SELECT id, title, amount, is_income, date FROM bhoomi_ledger ORDER BY date DESC LIMIT 5;',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // SQL Input Box
                  TextField(
                    controller: _sqlController,
                    maxLines: 3,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E4D2B),
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Run Query Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isRunningQuery ? null : _runCustomSql,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4D2B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isRunningQuery
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 16),
                      label: Text(
                        _isRunningQuery ? 'Running...' : 'Run Query',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Error Display
                  if (_queryError != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFB03A2E)),
                      ),
                      child: Text(
                        _queryError!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFB03A2E),
                        ),
                      ),
                    ),
                  ],

                  // Query Results Display
                  if (_queryResults != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Results (${_queryResults!.length} rows)',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (_queryTimeMs != null)
                          Text(
                            '${_queryTimeMs}ms',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2A21),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _queryResults!.isEmpty
                              ? 'Query executed successfully with 0 rows returned.'
                              : const JsonEncoder.withIndent('  ').convert(_queryResults),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF68D391),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip({required String label, required String sql}) {
    return InkWell(
      onTap: () => _loadPreset(sql),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDD6C4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Mukta',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E4D2B),
          ),
        ),
      ),
    );
  }
}
