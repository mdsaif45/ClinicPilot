/// Subscription tier representing the doctor's entitlement level in ClinicPilot.
enum SubscriptionTier {
  /// Standard offline-first tier.
  /// 100% Free Forever for unlimited patients, visits, remedies, and manual backups.
  free,

  /// Active 30-day Pro beta trial. All Pro capabilities are unlocked.
  proTrial,

  /// Active paid or redeemed Pro subscription.
  proActive,

  /// Trial or subscription period ended. Gracefully drops to Free tier
  /// with zero clinical data locks.
  proExpired;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free Plan';
      case SubscriptionTier.proTrial:
        return 'Pro Beta Trial';
      case SubscriptionTier.proActive:
        return 'ClinicPilot Pro';
      case SubscriptionTier.proExpired:
        return 'Trial Completed';
    }
  }
}

/// Advanced features that can be gated or badged as Pro.
enum AppFeature {
  /// Automated background sync schedule to Google Drive / WebDAV.
  cloudAutoSync,

  /// Custom prescription letterhead branding (clinic logo, doctor digital signature, colors).
  customLetterheadBranding,

  /// Advanced tax reports and yearly P&L summaries.
  taxAnalytics,

  /// Multi-clinic comparative analytics and retention benchmarking.
  multiClinicComparison,

  /// Multi-clinic practice management (managing 2 or more clinic locations).
  multiClinicManagement,

  /// Bulk Excel / XLSX export of practice records (CSV and PDF remain free).
  bulkExportXlsx;

  String get displayName {
    switch (this) {
      case AppFeature.cloudAutoSync:
        return 'Automated Cloud Sync';
      case AppFeature.customLetterheadBranding:
        return 'Branded Prescription Letterhead';
      case AppFeature.taxAnalytics:
        return 'Practice Tax & P&L Analytics';
      case AppFeature.multiClinicComparison:
        return 'Multi-Clinic Benchmarking';
      case AppFeature.multiClinicManagement:
        return 'Multi-Clinic Management';
      case AppFeature.bulkExportXlsx:
        return 'Bulk Excel (XLSX) Export';
    }
  }

  String get description {
    switch (this) {
      case AppFeature.cloudAutoSync:
        return 'Automatic daily backup to your personal Google Drive or private cloud.';
      case AppFeature.customLetterheadBranding:
        return 'Include your clinic logo, digital signature, and credentials on printed Rx & receipts.';
      case AppFeature.taxAnalytics:
        return 'Detailed yearly tax breakdowns, expense categories, and net profit intelligence.';
      case AppFeature.multiClinicComparison:
        return 'Compare revenue, footfall, and patient retention across all your practice branches.';
      case AppFeature.multiClinicManagement:
        return 'Add and manage 2 or more clinics with independent rosters and accounting.';
      case AppFeature.bulkExportXlsx:
        return 'Export comprehensive audit-ready spreadsheets for tax and practice analysis.';
    }
  }
}

/// Immutable state capturing current subscription and entitlement status.
class EntitlementState {
  static const int defaultTrialDurationDays = 30;

  final SubscriptionTier tier;
  final DateTime? trialStartDate;
  final DateTime? subscriptionExpiryDate;
  final String? planName;
  final String? redeemedCode;

  const EntitlementState({
    this.tier = SubscriptionTier.free,
    this.trialStartDate,
    this.subscriptionExpiryDate,
    this.planName,
    this.redeemedCode,
  });

  /// Whether the doctor currently has Pro access (active subscription or active trial).
  bool get isPro {
    if (tier == SubscriptionTier.proActive) {
      if (subscriptionExpiryDate != null) {
        return DateTime.now().isBefore(subscriptionExpiryDate!);
      }
      return true; // Lifetime or open subscription
    }
    if (tier == SubscriptionTier.proTrial) {
      return !isTrialExpired;
    }
    return false;
  }

  /// Whether the doctor is in the trial tier.
  bool get isTrial => tier == SubscriptionTier.proTrial;

  /// Whether the 30-day trial period has elapsed.
  bool get isTrialExpired {
    if (tier == SubscriptionTier.proExpired) return true;
    if (tier != SubscriptionTier.proTrial) return false;
    if (trialStartDate == null) return false;

    final expiry = trialStartDate!.add(
      const Duration(days: defaultTrialDurationDays),
    );
    return DateTime.now().isAfter(expiry);
  }

  /// Number of whole days remaining in the 30-day trial.
  int get daysRemainingInTrial {
    if (trialStartDate == null) return defaultTrialDurationDays;
    final expiry = trialStartDate!.add(
      const Duration(days: defaultTrialDurationDays),
    );
    final diff = expiry.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : (diff + 1); // +1 so the last day shows 1 day left
  }

  /// Progress fraction (from 0.0 to 1.0) of trial remaining for visual progress bars.
  double get trialRemainingFraction {
    final remaining = daysRemainingInTrial;
    return (remaining / defaultTrialDurationDays).clamp(0.0, 1.0);
  }

  /// Badge label for UI chips.
  String get badgeLabel {
    if (tier == SubscriptionTier.proActive) return 'PRO';
    if (isTrial && !isTrialExpired) return 'PRO TRIAL';
    return 'FREE';
  }

  /// Human-readable title for the active or current plan.
  String get formattedPlanName {
    if (tier == SubscriptionTier.free) return 'Free Plan';
    if (isTrial) return 'Pro Beta Trial';
    switch (planName) {
      case 'annual_pro':
        return 'Annual Pro Plan';
      case 'monthly_pro':
        return 'Monthly Pro Plan';
      case 'annual_promo':
        return 'Annual Partner License';
      case 'lifetime':
        return 'Enterprise Lifetime License';
      case 'annual_voucher':
        return 'Annual Prepaid Voucher';
      case 'ayush_scholarship':
        return 'AYUSH Professional Grant';
      case 'qa_testing':
        return 'Professional QA License';
      default:
        return 'ClinicPilot Pro';
    }
  }

  /// Human-readable billing frequency or pricing descriptor.
  String get formattedBillingCycle {
    if (tier == SubscriptionTier.free) return 'Free Forever';
    if (isTrial) return '30-Day Evaluation';
    if (planName == 'monthly_pro') return '₹199 / month';
    if (planName == 'annual_pro') return '₹1,999 / year';
    if (planName == 'lifetime') return 'One-Time License';
    if (redeemedCode != null) return 'Partner Voucher';
    return '₹1,999 / year';
  }

  /// Human-readable expiry or renewal description.
  String get formattedExpiryDescription {
    if (planName == 'lifetime') return 'Indefinite (Lifetime License)';
    if (subscriptionExpiryDate == null) {
      if (tier == SubscriptionTier.free) return 'No expiration (Free Forever)';
      return 'Active';
    }
    final date = subscriptionExpiryDate!;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final formatted = '${date.day} ${months[date.month - 1]} ${date.year}';
    final diff = date.difference(DateTime.now()).inDays;
    if (diff > 0) {
      return '$formatted ($diff days remaining)';
    } else if (diff == 0) {
      return '$formatted (Renews today)';
    } else {
      return '$formatted (Expired)';
    }
  }

  /// Check whether a specific feature is unlocked for this entitlement state.
  bool isFeatureUnlocked(AppFeature feature) {
    // Pro users get everything unlocked.
    if (isPro) return true;

    // Free users have core clinical features (unlimited patients/visits/cases),
    // but Pro convenience features require Pro.
    return false;
  }

  EntitlementState copyWith({
    SubscriptionTier? tier,
    DateTime? trialStartDate,
    DateTime? subscriptionExpiryDate,
    String? planName,
    String? redeemedCode,
  }) {
    return EntitlementState(
      tier: tier ?? this.tier,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      subscriptionExpiryDate:
          subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      planName: planName ?? this.planName,
      redeemedCode: redeemedCode ?? this.redeemedCode,
    );
  }
}
