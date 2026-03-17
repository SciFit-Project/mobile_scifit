import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/auth/data/auth_repository.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthRepository().signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ValueListenableBuilder<MockUserProfile>(
          valueListenable: mockProfileStore,
          builder: (context, profile, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _ProfileHeaderCard(profile: profile),
                  const SizedBox(height: 20),
                  _BodyStatsCard(profile: profile),
                  const SizedBox(height: 20),
                  _LifetimeStatsCard(profile: profile),
                  const SizedBox(height: 20),
                  _MenuSection(
                    onEditProfile: () => context.push('/profile/edit'),
                    onGoals: () => context.push('/profile/goals'),
                    onSettings: () => context.push('/settings'),
                    onLogout: () => _logout(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final MockUserProfile profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              _ProfileAvatar(
                name: profile.name,
                avatarUrl: profile.avatarUrl,
                backgroundColor: Color(profile.avatarColorValue),
                radius: 34,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D2433),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'MEMBER SINCE ${DateFormat('MMM yyyy').format(profile.memberSince).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/profile/edit'),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyStatsCard extends StatelessWidget {
  final MockUserProfile profile;

  const _BodyStatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Height', '${profile.heightCm.toStringAsFixed(0)} cm'),
      ('Weight', '${profile.weightKg.toStringAsFixed(1)} kg'),
      ('Age', '${profile.age}'),
      ('Gender', profile.gender.label),
      ('BMR', '${profile.bmr.round()} kcal'),
      ('TDEE', '${profile.tdee.round()} kcal'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Body Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  profile.goalType.label,
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 72,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final stat = stats[index];
              final isEmphasized = stat.$1 == 'BMR' || stat.$1 == 'TDEE';
              return _StatCell(
                label: stat.$1,
                value: stat.$2,
                emphasized: isEmphasized,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LifetimeStatsCard extends StatelessWidget {
  final MockUserProfile profile;

  const _LifetimeStatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifetime Stats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.65,
            children: [
              _SummaryTile(
                label: 'Workouts',
                value: '${profile.totalWorkouts}',
              ),
              _SummaryTile(
                label: 'Volume',
                value:
                    '${(profile.totalVolumeKg / 1000).toStringAsFixed(0)}k kg',
              ),
              _SummaryTile(
                label: 'Time',
                value: '${profile.totalHours.toStringAsFixed(1)} hrs',
              ),
              _SummaryTile(
                label: 'Streak',
                value: '${profile.streakDays} days',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final VoidCallback onGoals;
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _MenuSection({
    required this.onGoals,
    required this.onEditProfile,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.flag_outlined,
            title: 'Goals',
            subtitle: 'Adjust your target and activity level',
            onTap: onGoals,
          ),
          _MenuTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update name, body stats, avatar, and DOB',
            onTap: onEditProfile,
          ),
          _MenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Manage permissions and account controls',
            onTap: onSettings,
          ),
          _MenuTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from this device',
            onTap: onLogout,
            isDestructive: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final Color backgroundColor;
  final double radius;

  const _ProfileAvatar({
    required this.name,
    required this.avatarUrl,
    required this.backgroundColor,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            )
          : null,
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _StatCell({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: emphasized ? AppTheme.primaryLight : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade700 : const Color(0xFF1E293B);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withAlpha(14)
              : AppTheme.primaryLight.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      shape: isLast
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
                as ShapeBorder?,
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Color(0x10000000), blurRadius: 20, offset: Offset(0, 6)),
    ],
  );
}
