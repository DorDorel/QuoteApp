import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:QuoteApp/data/providers/tenant_provider.dart';
import 'package:QuoteApp/presentation/screens/bids/bids_archive_screen.dart';
import 'package:QuoteApp/presentation/screens/bids/open_bids_screen.dart';
import 'package:QuoteApp/presentation/screens/reminders/reminders_screen.dart';
import 'package:QuoteApp/data/providers/bids_provider.dart';
import 'package:QuoteApp/data/providers/user_info_provider.dart';
import 'package:QuoteApp/presentation/screens/admin/admin_screen.dart';

class MainDashboard extends StatefulWidget {
  static const routeName = '/main_dashboard';

  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  @override
  void initState() {
    super.initState();
    Provider.of<BidsProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: const HomeTitle(),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  tabs: const [
                    Tab(text: 'Quotes'),
                    Tab(text: 'Archive'),
                    Tab(text: 'Reminders'),
                  ],
                  labelColor: Colors.black,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: Colors.black,
                ),
                automaticallyImplyLeading: false,
              ),
            ];
          },
          body: TabBarView(
            children: [
              OpenBidScreen(),
              BidsArchiveScreen(),
              RemindersScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = context.watch<UserInfoProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (userData.userData == null)
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Live Dashboard",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userData.userData!.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        if (TenantProvider.checkAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_sharp),
            onPressed: () {
              Navigator.pushNamed(context, AdminScreen.routeName);
            },
          ),
      ],
    );
  }
}
