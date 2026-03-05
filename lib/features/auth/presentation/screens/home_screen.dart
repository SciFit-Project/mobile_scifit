import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'Athlete';
    final avatar = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning 👋',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF888888),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        name.split(' ').first,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      // GoRouter refreshListenable handles redirect
                      await Supabase.instance.client.auth.signOut();
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF1E1E1E),
                      backgroundImage: avatar != null
                          ? NetworkImage(avatar)
                          : null,
                      child: avatar == null
                          ? const Icon(Icons.person, color: Colors.white54)
                          : null,
                    ),
                  ),
                ],
              ),

              const Gap(32),

              // Today's stats strip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FF47),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Workouts', value: '0', icon: Icons.bolt),
                    _StatItem(
                      label: 'Calories',
                      value: '0',
                      icon: Icons.local_fire_department,
                    ),
                    _StatItem(
                      label: 'Streak',
                      value: '0d',
                      icon: Icons.emoji_events,
                    ),
                  ],
                ),
              ),

              const Gap(32),

              Text(
                'Start a workout',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Gap(16),

              // Placeholder workout cards
              Expanded(
                child: ListView(
                  children: const [
                    _WorkoutCard(
                      title: 'Upper Body',
                      duration: '45 min',
                      level: 'Intermediate',
                    ),
                    Gap(12),
                    _WorkoutCard(
                      title: 'Lower Body',
                      duration: '40 min',
                      level: 'Beginner',
                    ),
                    Gap(12),
                    _WorkoutCard(
                      title: 'Full Body HIIT',
                      duration: '30 min',
                      level: 'Advanced',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0A0A0A), size: 22),
        const Gap(4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0A0A0A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: const Color(0xFF3A3A0A),
          ),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.title,
    required this.duration,
    required this.level,
  });

  final String title;
  final String duration;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                '$duration  •  $level',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFF666666),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Color(0xFFE8FF47),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
