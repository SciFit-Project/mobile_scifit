import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopNavbar extends StatelessWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'Athlete';
    final avatar = user?.userMetadata?['avatar_url'] as String?;

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
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? const Icon(Icons.person, color: Colors.white54)
                : null,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello ${name.split(' ').first} 👋🏽",
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
            // Text(
            //   "Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
            //   style: GoogleFonts.spaceGrotesk(
            //     color: const Color(0xFF888888),
            //     fontSize: 13,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}
