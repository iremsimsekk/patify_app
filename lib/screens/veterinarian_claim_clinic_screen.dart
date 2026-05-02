import 'dart:async';

import 'package:flutter/material.dart';

import '../services/veterinarian_claim_service.dart';
import '../theme/patify_theme.dart';

class VeterinarianClaimClinicScreen extends StatefulWidget {
  const VeterinarianClaimClinicScreen({super.key});

  @override
  State<VeterinarianClaimClinicScreen> createState() =>
      _VeterinarianClaimClinicScreenState();
}

class _VeterinarianClaimClinicScreenState
    extends State<VeterinarianClaimClinicScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  String? _error;
  int? _submittingInstitutionId;
  List<VeterinarianInstitutionSearchItem> _institutions = const [];

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  Future<void> _loadInstitutions({String query = ''}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final institutions = await VeterinarianClaimService.searchInstitutions(
        query: query,
      );
      if (!mounted) return;
      setState(() => _institutions = institutions);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('AUTH_TOKEN_MISSING')) {
      return 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yap.';
    }
    if (message.contains('VETERINARIAN_ROLE_REQUIRED')) {
      return 'Bu işlem sadece veteriner hesapları için kullanılabilir.';
    }
    if (message.contains('Connection refused') ||
        message.contains('SocketException')) {
      return 'Sunucuya bağlanılamadı. Lütfen tekrar dene.';
    }
    return 'Klinikler yüklenemedi. Lütfen tekrar dene.';
  }

  Future<void> _submitClaim(VeterinarianInstitutionSearchItem institution) async {
    setState(() => _submittingInstitutionId = institution.id);
    try {
      await VeterinarianClaimService.submitClaimRequest(
        institutionId: institution.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sahiplenme isteğiniz gönderildi. Admin onayı bekleniyor.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_claimError(error)),
        ),
      );
    } finally {
      if (mounted) setState(() => _submittingInstitutionId = null);
    }
  }

  String _claimError(Object error) {
    final message = error.toString();
    if (message.contains('CLAIM_REQUEST_ALREADY_PENDING')) {
      return 'Bu klinik için zaten bekleyen bir sahiplenme talebiniz var.';
    }
    if (message.contains('INSTITUTION_NOT_VETERINARY')) {
      return 'Seçilen kayıt veteriner kliniği olarak uygun değil.';
    }
    return 'Sahiplenme isteği gönderilemedi. Lütfen tekrar dene.';
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _loadInstitutions(query: value.trim()),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kliniğimi Sahiplen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(PatifyTheme.space24),
        children: [
          Text(
            'Sahiplenmek istediğiniz kliniği arayın ve talep gönderin.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: PatifyTheme.space16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Klinik ara',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: PatifyTheme.space20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(PatifyTheme.space24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _InlineMessageCard(
              message: _error!,
              color: PatifyTheme.danger,
              onRetry: () => _loadInstitutions(query: _searchController.text),
            )
          else if (_institutions.isEmpty)
            const _InlineEmptyState(
              title: 'Klinik bulunamadı',
              subtitle: 'Farklı bir arama terimi deneyin.',
            )
          else
            ..._institutions.map(
              (institution) => Padding(
                padding: const EdgeInsets.only(bottom: PatifyTheme.space16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(PatifyTheme.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          institution.name,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: PatifyTheme.space8),
                        if (institution.address != null)
                          Text(
                            institution.address!,
                            style: textTheme.bodyMedium,
                          ),
                        if (institution.email != null) ...[
                          const SizedBox(height: PatifyTheme.space8),
                          Text(
                            institution.email!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: PatifyTheme.textPrimary,
                            ),
                          ),
                        ],
                        const SizedBox(height: PatifyTheme.space16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submittingInstitutionId == institution.id
                                ? null
                                : () => _submitClaim(institution),
                            child: _submittingInstitutionId == institution.id
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Sahiplenme İsteği Gönder'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineMessageCard extends StatelessWidget {
  const _InlineMessageCard({
    required this.message,
    required this.color,
    required this.onRetry,
  });

  final String message;
  final Color color;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PatifyTheme.radius16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PatifyTheme.space12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 34,
            color: PatifyTheme.textSecondary,
          ),
          const SizedBox(height: PatifyTheme.space12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
