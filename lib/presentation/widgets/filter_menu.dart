import 'package:QuoteApp/data/providers/bids_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FilterMenu extends StatelessWidget {
  const FilterMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final bidsData = Provider.of<BidsProvider>(context);
    final theme = Theme.of(context);

    final TextStyle activeTabStyle = GoogleFonts.poppins(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    final TextStyle inactiveTabStyle = GoogleFonts.poppins(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );

    return PreferredSize(
      preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      child: Container(
        height: 56, // Increased for better tap targets
        padding: const EdgeInsets.symmetric(
          horizontal: 8, // Reduced horizontal padding for more space
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.7),
          labelStyle: activeTabStyle,
          unselectedLabelStyle: inactiveTabStyle,
          indicatorWeight: 0, // Remove default indicator
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero, // Remove padding between tabs
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: theme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withAlpha((255 * 0.4).round()),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: -1,
              ),
            ],
          ),
          tabs: [
            _buildTab(
              title: "Activities",
              count: bidsData.openBidsCounter,
              icon: Icons.assignment_outlined,
            ),
            _buildTab(
              title: "Archive",
              icon: Icons.archive_outlined,
            ),
            _buildTab(
              title: "Reminders",
              icon: Icons.notifications_none_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    int? count,
    required IconData icon,
  }) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 8), // Reduced horizontal padding
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16), // Slightly smaller icon
            const SizedBox(width: 4), // Reduced spacing
            Text(title),
            if (count != null) ...[
              const SizedBox(width: 3), // Reduced spacing
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1), // Smaller padding
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 11, // Smaller font
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
