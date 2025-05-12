import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_banner_ad.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _launchInBrowser(BuildContext context, Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Dialogs.showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        centerTitle: true,
        title: Text(
          'Dashboard',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                ListTile(
                  tileColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Coming soon...',
                                style: TextStyle(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                )),
                            Spacer(),
                            Text('🔔'),
                          ],
                        ),
                        // backgroundColor: Colors.black87,
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  leading:
                      const Icon(Icons.star_rate_rounded, color: Colors.amber),
                  title: RichText(
                    text: TextSpan(
                      text: 'AdMob',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                      children: [
                        TextSpan(
                          text: 'lytics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          children: const [
                            TextSpan(
                              text: ' Pro',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_forward,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _customListTile(
                      onTap: () async {
                        const url =
                            'https://play.google.com/store/apps/developer?id=SIRMAUR';
                        _launchInBrowser(context, Uri.parse(url));
                      },
                      icon: CupertinoIcons.app_badge,
                      title: 'More Apps',
                      context: context,
                      isFirst: true,
                    ),
                    _customListTile(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.blue.shade200,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                      'assets/images/avatar.png',
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Aman Sirmaur',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'MECHANICAL ENGINEERING',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'NIT AGARTALA',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    child: Image.asset(
                                        'assets/images/youtube.png',
                                        width: 30),
                                    onTap: () async {
                                      const url =
                                          'https://www.youtube.com/@AmanSirmaur';
                                      _launchInBrowser(context, Uri.parse(url));
                                    },
                                  ),
                                  InkWell(
                                    child: Image.asset(
                                        'assets/images/twitter.png',
                                        width: 30),
                                    onTap: () async {
                                      const url =
                                          'https://x.com/AmanSirmaur?t=2QWiqzkaEgpBFNmLI38sbA&s=09';
                                      _launchInBrowser(context, Uri.parse(url));
                                    },
                                  ),
                                  InkWell(
                                    child: Image.asset(
                                        'assets/images/instagram.png',
                                        width: 30),
                                    onTap: () async {
                                      const url =
                                          'https://www.instagram.com/aman_sirmaur19/';
                                      _launchInBrowser(context, Uri.parse(url));
                                    },
                                  ),
                                  InkWell(
                                    child: Image.asset(
                                        'assets/images/github.png',
                                        width: 30),
                                    onTap: () async {
                                      const url =
                                          'https://github.com/Aman-Sirmaur19';
                                      _launchInBrowser(context, Uri.parse(url));
                                    },
                                  ),
                                  InkWell(
                                    child: Image.asset(
                                        'assets/images/linkedin.png',
                                        width: 30),
                                    onTap: () async {
                                      const url =
                                          'https://www.linkedin.com/in/aman-kumar-257613257/';
                                      _launchInBrowser(context, Uri.parse(url));
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                      icon: Icons.copyright_rounded,
                      title: 'Copyright',
                      context: context,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  tileColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onTap: () async {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    await authProvider
                        .logout()
                        .then((value) => Navigator.pop(context));
                  },
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                  ),
                  title: const Text('Logout'),
                  trailing: const Icon(
                    CupertinoIcons.chevron_forward,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'MADE WITH ❤️ IN 🇮🇳',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 1.5,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customListTile({
    required void Function() onTap,
    required IconData icon,
    required String title,
    required BuildContext context,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: isFirst ? const Radius.circular(20) : Radius.zero,
        topRight: isFirst ? const Radius.circular(20) : Radius.zero,
        bottomLeft: isLast ? const Radius.circular(20) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(20) : Radius.zero,
      )),
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(
        CupertinoIcons.chevron_forward,
        color: Colors.grey,
      ),
    );
  }
}
