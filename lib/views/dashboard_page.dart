import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_home_view.dart';
import 'adaptive_assessment_view.dart';
import 'assessments_view.dart';
import 'profile_view.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;

  final List<Widget> _pages = const [
    DashboardHomeView(),
    AdaptiveAssessmentView(),
    AssessmentsView(),
    ProfileView(),
    EditProfilePage(),
    ChangePasswordPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1000;

          return Row(
            children: [
              if (isWide) _buildSideMenu(),
              Expanded(
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _pages[_index],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 1000
          ? NavigationBar(
              height: 70,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  label: 'Career Guide',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  label: 'Assessments',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: const [
          Icon(Icons.school_outlined, color: Color(0xFF4F46E5)),
          SizedBox(width: 10),
          Text(
            "Intelligent Career Counsellor",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: "Notifications",
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
        ),
        IconButton(
          tooltip: "Sign Out",
          onPressed: () {
            AuthService.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          },
          icon: const Icon(Icons.logout, color: Colors.black87),
        ),
      ],
    );
  }

  bool _profileExpanded = false;

  Widget _buildSideMenu() {
    final name = AuthService.instance.name;
    final initials = (name != null && name.isNotEmpty)
        ? name
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : _initials(AuthService.instance.email);
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEEF2FF),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sideMenuButton(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            selected: _index == 0,
            onTap: () => setState(() => _index = 0),
          ),
          _sideMenuButton(
            icon: Icons.lightbulb_outline,
            label: 'Career Guide',
            selected: _index == 1,
            onTap: () => setState(() => _index = 1),
          ),
          _sideMenuButton(
            icon: Icons.analytics_outlined,
            label: 'Assessments',
            selected: _index == 2,
            onTap: () => setState(() => _index = 2),
          ),
          // Profile dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () =>
                        setState(() => _profileExpanded = !_profileExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: _index >= 3
                                ? const Color(0xFF4F46E5)
                                : Colors.black54,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Profile',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Icon(
                            _profileExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_profileExpanded) ...[
                    _sideMenuSubButton(
                      icon: Icons.account_circle_outlined,
                      label: 'View Profile',
                      selected: _index == 3,
                      onTap: () => setState(() => _index = 3),
                    ),
                    _sideMenuSubButton(
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      selected: _index == 4,
                      onTap: () => setState(() => _index = 4),
                    ),
                    _sideMenuSubButton(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      selected: _index == 5,
                      onTap: () => setState(() => _index = 5),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Spacer(),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 16.0),
          //   child: OutlinedButton.icon(
          //     onPressed: () {
          //       AuthService.instance.signOut();
          //       Navigator.pushNamedAndRemoveUntil(
          //         context,
          //         '/login',
          //         (_) => false,
          //       );
          //     },
          //     icon: const Icon(Icons.logout),
          //     label: const Text('Log Out'),
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: Colors.red,
          //       side: const BorderSide(color: Colors.red),
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 12,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _sideMenuButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Material(
        color: selected ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? const Color(0xFF4F46E5) : Colors.black54,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? const Color(0xFF4F46E5) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideMenuSubButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 2, bottom: 2, right: 8),
      child: Material(
        color: selected ? const Color(0xFFD1D5FA) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? const Color(0xFF4F46E5) : Colors.black54,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: selected ? const Color(0xFF4F46E5) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String? email) {
    if (email == null || email.isEmpty) return "?";
    final part = email.split('@').first;
    return part.isEmpty ? "?" : part.substring(0, 1).toUpperCase();
  }
}
