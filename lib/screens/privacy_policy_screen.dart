import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _lastUpdated = 'April 19, 2025';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last updated: $_lastUpdated',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xB3FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your privacy matters to us. This policy explains how SpotIt collects, uses, '
                            'and protects your personal information when you use our app.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _PolicySection(
                    number: '1',
                    title: 'Information We Collect',
                    children: const [
                      _PolicyItem(
                        icon: Icons.person_outline_rounded,
                        heading: 'Account Information',
                        body: 'When you create an account, we collect your name, email address, '
                            'and profile photo (if provided via Google Sign-In).',
                      ),
                      _PolicyItem(
                        icon: Icons.location_on_outlined,
                        heading: 'Location Data',
                        body: 'We collect location information only when you submit a report. '
                            'We do not track your location in the background.',
                      ),
                      _PolicyItem(
                        icon: Icons.camera_alt_outlined,
                        heading: 'Photos & Media',
                        body: 'Photos you attach to reports are uploaded to our secure cloud storage '
                            '(Firebase Storage) and are used solely to support your report.',
                      ),
                      _PolicyItem(
                        icon: Icons.description_outlined,
                        heading: 'Report Content',
                        body: 'The category, description, and location details you enter when '
                            'submitting a civic issue report.',
                        last: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _PolicySection(
                    number: '2',
                    title: 'How We Use Your Information',
                    children: const [
                      _BulletItem('To create and manage your SpotIt account.'),
                      _BulletItem('To submit your civic reports to the relevant local authorities.'),
                      _BulletItem('To show you the status and history of your reports.'),
                      _BulletItem('To display your profile statistics (total, pending, resolved reports).'),
                      _BulletItem('To send you status updates when your report changes.'),
                      _BulletItem('To improve the SpotIt app and user experience.'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _PolicySection(
                    number: '3',
                    title: 'Data Sharing',
                    children: const [
                      _PolicyItem(
                        icon: Icons.account_balance_outlined,
                        heading: 'Local Authorities',
                        body: 'Report content (category, description, location, photo) is shared '
                            'with relevant municipal authorities to facilitate resolution. '
                            'Your personal contact details are not shared.',
                      ),
                      _PolicyItem(
                        icon: Icons.cloud_outlined,
                        heading: 'Service Providers',
                        body: 'We use Google Firebase (Auth, Firestore, Storage) to power the app. '
                            'Firebase is bound by Google\'s privacy and security commitments.',
                      ),
                      _PolicyItem(
                        icon: Icons.block_rounded,
                        heading: 'No Sale of Data',
                        body: 'We do not sell, rent, or trade your personal information '
                            'to any third party for commercial purposes.',
                        last: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _PolicySection(
                    number: '4',
                    title: 'Data Retention',
                    children: const [
                      _BulletItem('Your account data is retained as long as your account is active.'),
                      _BulletItem('Report data is retained for a minimum of 2 years for accountability and record-keeping purposes.'),
                      _BulletItem('When you delete your account, your personal data is removed within 30 days. Anonymised report data may be retained for public interest records.'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _PolicySection(
                    number: '5',
                    title: 'Data Security',
                    children: const [
                      _PolicyItem(
                        icon: Icons.lock_outline_rounded,
                        heading: 'Encryption',
                        body: 'All data is transmitted over HTTPS/TLS. Data at rest is '
                            'encrypted using Firebase\'s industry-standard AES-256 encryption.',
                      ),
                      _PolicyItem(
                        icon: Icons.admin_panel_settings_outlined,
                        heading: 'Access Control',
                        body: 'Firestore Security Rules ensure each user can only read and '
                            'write their own data. No user can access another user\'s reports.',
                      ),
                      _PolicyItem(
                        icon: Icons.verified_user_outlined,
                        heading: 'Authentication',
                        body: 'We use Firebase Authentication to verify user identities. '
                            'Passwords are never stored in plain text.',
                        last: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _PolicySection(
                    number: '6',
                    title: 'Your Rights',
                    children: const [
                      _BulletItem('Access — You can view all your reports and profile data within the app.'),
                      _BulletItem('Correction — You can update your name and photo at any time via Edit Profile.'),
                      _BulletItem('Deletion — You can request deletion of your account by contacting us at support@spotit.app.'),
                      _BulletItem('Portability — You may request a copy of your data by emailing us.'),
                      _BulletItem('Withdraw Consent — You can sign out and stop using the app at any time.'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _PolicySection(
                    number: '7',
                    title: 'Children\'s Privacy',
                    children: const [
                      _BulletItem('SpotIt is not intended for use by children under the age of 13.'),
                      _BulletItem('We do not knowingly collect personal information from children under 13.'),
                      _BulletItem('If you believe a child has provided us with personal data, please contact us and we will delete it promptly.'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _PolicySection(
                    number: '8',
                    title: 'Changes to This Policy',
                    children: const [
                      _BulletItem('We may update this Privacy Policy from time to time.'),
                      _BulletItem('We will notify you of significant changes via an in-app notice.'),
                      _BulletItem('Continued use of SpotIt after changes are posted constitutes your acceptance of the updated policy.'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Contact ────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(Icons.contact_support_rounded,
                                  color: AppColors.primary, size: 17),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '9. Contact Us',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'For any privacy-related questions or requests, reach us at:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ContactDetail(icon: Icons.email_outlined, text: 'support@spotit.app'),
                        const SizedBox(height: 8),
                        _ContactDetail(icon: Icons.public_rounded, text: 'www.spotit.app/privacy'),
                        const SizedBox(height: 8),
                        _ContactDetail(icon: Icons.location_on_outlined, text: 'Mohali, Punjab, India'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Footer ─────────────────────────────────────────────────
                  const Center(
                    child: Text(
                      '© 2025 SpotIt. All rights reserved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ────────────────────────────────────────────────────────────

class _PolicySection extends StatelessWidget {
  final String number;
  final String title;
  final List<Widget> children;

  const _PolicySection({
    required this.number,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ── Policy item (icon + heading + body) ───────────────────────────────────────

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String heading;
  final String body;
  final bool last;

  const _PolicyItem({
    required this.icon,
    required this.heading,
    required this.body,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              heading,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 23),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ),
        if (!last) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ── Bullet item ───────────────────────────────────────────────────────────────

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact detail row ────────────────────────────────────────────────────────

class _ContactDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
