import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
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
                      await Supabase.instance.client.auth.signOut();
                      await SecureStorageService.deleteToken();
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
            ],
          ),
        ),
      ),
    );
  }
}