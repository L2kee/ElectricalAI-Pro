import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(

      borderRadius: BorderRadius.circular(18),

      onTap: onTap,

      child: Container(

        width: 92,
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: const [

            BoxShadow(

              blurRadius: 8,

              color: Colors.black12,

              offset: Offset(0,3),

            ),

          ],

        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              color: Colors.red,
              size: 34,
            ),

            const SizedBox(height:12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

          ],

        ),

      ),

    );

  }

}