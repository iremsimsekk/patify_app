import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
import '../services/veterinarian_claim_service.dart';
import '../theme/patify_theme.dart';

class VeterinarianProfileScreen extends StatefulWidget {
  const VeterinarianProfileScreen({
    super.key,
    required this.user,
    required this.claimStatus,
    required this.onClaimRequested,
  });

  final AppUser user;
  final VeterinarianClaimStatusResponse? claimStatus;
  final VoidCallback onClaimRequested;

  @override
  State<VeterinarianProfileScreen> createState() =>
      _VeterinarianProfileScreenState();
}

class _VeterinarianProfileScreenState extends State<VeterinarianProfileScreen> {
  Future<PlaceDetails>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void didUpdateWidget(covariant VeterinarianProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.claimStatus?.institution?.id !=
            widget.claimStatus?.institution?.id ||
        oldWidget.claimStatus?.status != widget.claimStatus?.status) {
      _loadDetails();
    }
  }

  void _loadDetails() {
    final institutionId = widget.claimStatus?.institution?.id;
    if (widget.claimStatus?.isApproved == true &&
        institutionId != null &&
        institutionId > 0) {
      _detailsFuture = InstitutionApiService.fetchInstitutionDetails(
        institutionId.toString(),
      );
    } else {
      _detailsFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final claim = widget.claimStatus;
    final institution = claim?.institution;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PatifyTheme.space20,
        PatifyTheme.space16,
        PatifyTheme.space20,
        PatifyTheme.space28,
      ),
      children: [
        Text('Profil', style: theme.textTheme.headlineSmall),
        const SizedBox(height: PatifyTheme.space8),
        Text(
          'Klinik görünürlüğünü ve temel profil bilgilerini buradan takip edebilirsin.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: PatifyTheme.space20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hekim bilgisi', style: theme.textTheme.titleMedium),
                const SizedBox(height: PatifyTheme.space16),
                _ProfileLine(
                  label: 'İsim',
                  value: widget.user.displayName,
                ),
                _ProfileLine(
                  label: 'E-posta',
                  value: widget.user.email,
                ),
                const _ProfileLine(
                  label: 'Rol',
                  value: 'Veteriner',
                ),
              ],
            ),
          ),
        ),
        if (claim?.isApproved != true) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PatifyTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Klinik onayı gerekiyor',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: PatifyTheme.space8),
                  Text(
                    institution?.name != null
                        ? 'Seçili klinik: ${institution!.name}. Profil düzenleme ve randevu yönetimi klinik onayından sonra açılacak.'
                        : 'Henüz onaylı klinik bulunmuyor. Önce klinik sahiplenme talebi gönderildiğinde bu alan aktif olacak.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: PatifyTheme.space16),
                  ElevatedButton(
                    onPressed: widget.onClaimRequested,
                    child: Text(
                      claim?.status == 'PENDING'
                          ? 'Talep durumunu görüntüle'
                          : 'Klinik sahiplen',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (_detailsFuture != null) ...[
          FutureBuilder<PlaceDetails>(
            future: _detailsFuture,
            builder: (context, snapshot) {
              final details = snapshot.data;
              final loading = snapshot.connectionState != ConnectionState.done;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(PatifyTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Klinik profili',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profil düzenleme yakında eklenecek.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Yakında'),
                          ),
                        ],
                      ),
                      if (loading) ...[
                        const SizedBox(height: PatifyTheme.space12),
                        const LinearProgressIndicator(),
                      ] else ...[
                        const SizedBox(height: PatifyTheme.space8),
                        _ProfileLine(
                          label: 'Klinik adı',
                          value: details?.name ?? institution?.name ?? '-',
                        ),
                        _ProfileLine(
                          label: 'Adres',
                          value: details?.formattedAddress ??
                              institution?.address ??
                              '-',
                        ),
                        _ProfileLine(
                          label: 'E-posta',
                          value: details?.email ?? institution?.email ?? '-',
                        ),
                        _ProfileLine(
                          label: 'Telefon',
                          value: details?.phone ?? institution?.phone ?? '-',
                        ),
                        _ProfileLine(
                          label: 'Web sitesi',
                          value:
                              details?.website ?? institution?.website ?? '-',
                        ),
                        _ProfileLine(
                          label: 'Çalışma saatleri',
                          value:
                              _openingHours(details, institution?.openingHours),
                        ),
                        _ProfileLine(
                          label: 'Konum',
                          value: _cityDistrict(details, institution),
                        ),
                        _ProfileLine(
                          label: 'Hakkında',
                          value: details?.description ??
                              institution?.description ??
                              'Açıklama henüz eklenmedi.',
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  String _openingHours(PlaceDetails? details, String? fallback) {
    final entries = details?.weekdayText ?? const <String>[];
    if (entries.isNotEmpty) {
      return entries.join(' | ');
    }
    final normalized = fallback?.trim();
    return normalized == null || normalized.isEmpty ? '-' : normalized;
  }

  String _cityDistrict(
    PlaceDetails? details,
    VeterinarianInstitutionSummary? institution,
  ) {
    final city = details?.city ?? institution?.city;
    final district = details?.district ?? institution?.district;
    final joined = [district, city]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' / ')
        .trim();
    return joined.isEmpty ? '-' : joined;
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PatifyTheme.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PatifyTheme.textSecondary,
                ),
          ),
          const SizedBox(height: PatifyTheme.space4),
          Text(
            value,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
