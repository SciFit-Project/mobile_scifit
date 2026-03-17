import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopNavbar extends StatelessWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MockUserProfile>(
      valueListenable: mockProfileStore,
      builder: (context, profile, _) {
        return Row(
          spacing: 16,
          children: [
            GestureDetector(
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                await SecureStorageService.deleteToken();
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Color(profile.avatarColorValue),
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Text(
                        profile.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${profile.name.split(' ').first} 👋🏽',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('EEEE,  MMMM d').format(DateTime.now()),
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
