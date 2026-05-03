import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/lost_report_service.dart';
import '../theme/patify_theme.dart';

class LostReportDetailScreen extends StatefulWidget {
  const LostReportDetailScreen({
    super.key,
    required this.reportId,
    required this.currentUser,
  });

  final int reportId;
  final AppUser currentUser;

  @override
  State<LostReportDetailScreen> createState() => _LostReportDetailScreenState();
}

class _LostReportDetailScreenState extends State<LostReportDetailScreen> {
  late Future<LostReport> _future;
  bool _markingFound = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<LostReport> _load() {
    return LostReportService.detail(
      id: widget.reportId,
      email: widget.currentUser.email,
    );
  }

  Future<void> _markFound() async {
    setState(() => _markingFound = true);
    try {
      final report = await LostReportService.markFound(
        id: widget.reportId,
        email: widget.currentUser.email,
      );
      if (!mounted) return;
      setState(() => _future = Future.value(report));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlan güncellendi.')),
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlan güncellenemedi.')),
      );
    } finally {
      if (mounted) setState(() => _markingFound = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıp İlan Detayı')),
      body: FutureBuilder<LostReport>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('İlan detayı alınamadı.'));
          }

          final report = snapshot.data!;
          final found = report.status == 'FOUND';

          return ListView(
            padding: const EdgeInsets.all(PatifyTheme.space20),
            children: [
              Container(
                padding: const EdgeInsets.all(PatifyTheme.space20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(PatifyTheme.radius24),
                  border: Border.all(color: PatifyTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.14),
                          child: Icon(
                            Icons.pets_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: PatifyTheme.space12),
                        Expanded(
                          child: Text(
                            report.petType,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        Chip(
                          label: Text(found ? 'Bulundu' : 'Aktif'),
                          backgroundColor: found
                              ? PatifyTheme.success.withValues(alpha: 0.16)
                              : PatifyTheme.accent.withValues(alpha: 0.16),
                        ),
                      ],
                    ),
                    if ((report.imageUrl ?? '').isNotEmpty) ...[
                      const SizedBox(height: PatifyTheme.space16),
                      _ReportImage(imageUrl: report.imageUrl!),
                    ],
                    const SizedBox(height: PatifyTheme.space16),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      text: report.address ?? report.district ?? 'Ankara',
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    _DetailRow(
                      icon: Icons.description_outlined,
                      text: report.description,
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      text: report.contactInfo,
                    ),
                  ],
                ),
              ),
              if (report.canMarkFound && !found) ...[
                const SizedBox(height: PatifyTheme.space20),
                FilledButton.icon(
                  onPressed: _markingFound ? null : _markFound,
                  icon: _markingFound
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: const Text('Bulundu olarak işaretle'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ReportImage extends StatelessWidget {
  const _ReportImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imageUrl.startsWith('data:image')) {
      final base64Part = imageUrl.substring(imageUrl.indexOf(',') + 1);
      image = Image.memory(
        base64Decode(base64Part),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      image = Image.network(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            alignment: Alignment.center,
            color: PatifyTheme.divider,
            child: const Text('Fotoğraf yüklenemedi.'),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(PatifyTheme.radius16),
      child: image,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: PatifyTheme.textSecondary),
        const SizedBox(width: PatifyTheme.space8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
