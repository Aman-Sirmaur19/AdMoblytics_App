import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_picker/currency_picker.dart';

import '../../services/admob_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/internet_connectivity_button.dart';
import '../dashboard_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // REMOVED: No longer need a local future
  // late Future<dynamic> _accountFuture;

  late AuthProvider authProvider;
  late AdMobService admobService;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    admobService = AdMobService(authProvider.accessToken!);

    // MODIFIED: Fetch data via the provider only if needed
    // Use context.read inside initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().fetchAccountIfNeeded(admobService);
    });
  }

  // MODIFIED: Refresh method now calls the provider's refresh function
  Future<void> _refreshAccount() async {
    await context.read<AccountProvider>().refreshAccount(admobService);
  }

  @override
  Widget build(BuildContext context) {
    // ADDED: Use a Consumer to listen to the AccountProvider's state
    final accountProvider = context.watch<AccountProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NavigationProvider>().increment();
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const DashboardScreen(),
                ),
              );
            },
            tooltip: 'Dashboard',
            icon: const Icon(CupertinoIcons.square_grid_2x2),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: RefreshIndicator(
        onRefresh: _refreshAccount,
        color: Colors.blue,
        backgroundColor: Colors.blue.shade50,
        // MODIFIED: Replaced FutureBuilder with a direct check on the provider's state
        child: _buildBody(accountProvider),
      ),
    );
  }

  // ADDED: A new helper method to build the body based on provider state
  Widget _buildBody(AccountProvider accountProvider) {
    if (accountProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (accountProvider.hasError) {
      return InternetConnectivityButton(onPressed: _refreshAccount);
    }

    if (accountProvider.accountDetails == null) {
      // This can happen if there's no data and it's not loading (e.g., initial state)
      return const Center(child: Text("No account details found."));
    }

    // Data is available, build the UI
    final data = accountProvider.accountDetails!;
    final account = data['account']?[0];
    final accountId = account['publisherId'] ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _customRow(
              icon: Icons.info_outline_rounded,
              label: 'User Information',
            ),
            const SizedBox(height: 10),
            ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  authProvider.user!.photoUrl!,
                  height: 60,
                  width: 60,
                )),
            const SizedBox(height: 10),
            _customContainer(
              icon: const Icon(
                Icons.edit_attributes_outlined,
                color: Colors.orange,
              ),
              label: 'Name',
              value: authProvider.user!.displayName!,
            ),
            const SizedBox(height: 10),
            _customContainer(
              icon: const Icon(
                Icons.public_rounded,
                color: Colors.blue,
              ),
              label: 'Publisher ID',
              value: accountId,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  showCurrencyName: true,
                  showCurrencyCode: true,
                  onSelect: (Currency currency) {
                    context
                        .read<CurrencyProvider>()
                        .setCurrency(currency.code, currency.symbol);
                  },
                );
              },
              child: _customContainer(
                icon: const Icon(
                  Icons.attach_money_rounded,
                  color: Colors.amber,
                ),
                label: 'Currency',
                value:
                    '${context.watch<CurrencyProvider>().currencyCode} (${context.watch<CurrencyProvider>().currencySymbol}) ▼',
              ),
            ),
            SizedBox(height: 10),
            _customContainer(
              icon: const Icon(
                Icons.access_time_rounded,
                color: Colors.green,
              ),
              label: 'Timezone',
              value: account['reportingTimeZone'],
            ),
            const SizedBox(height: 50),
            _customRow(
              icon: Icons.account_circle_outlined,
              label: 'Account',
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onTap: () async {
                await authProvider.logout();
              },
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _customContainer(
      {required Widget icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 20),
            ],
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
