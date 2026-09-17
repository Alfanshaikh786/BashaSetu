import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Top Floating Pill Navigation Bar
/// Replicates the React Bhasha Setu floating pill navbar (rounded-20px, #D5E8D5 border)
class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onDownloadTap;
  final VoidCallback? onLoginTap;

  const AppNavbar({
    super.key,
    this.onDownloadTap,
    this.onLoginTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Left: Brand Emblem ──
              InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Center(
                        child: Text(
                          "ᱥᱟ",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              "भाषा ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "| SETU",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          "BRIDGING TRIBAL LANGUAGES",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Right: Action Buttons & Menu ──
              Row(
                children: [
                  // Download/Install Button
                  ElevatedButton(
                    onPressed: onDownloadTap ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Bhasha Setu APK is running in standalone native mode!"),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Install App",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Menu Button
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
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
