import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CloverApp());
}

class CloverApp extends StatelessWidget {
  const CloverApp({super.key});

  // Skema Warna Soft & Comforting
  static const Color bgDark = Color(0xFF14191D);       // Dark Slate Lembut
  static const Color surfaceDark = Color(0xFF1E252B);  // Abu-abu Kebiruan Redup
  static const Color primaryMint = Color(0xFF38EF7D);  // Hijau Mint Teduh
  static const Color myBubbleBg = Color(0xFF1B4D3E);   // Hijau Sage Gelap
  static const Color amberSoft = Color(0xFFE6A23C);    // Amber Soft untuk 1x lihat

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clover',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        primaryColor: primaryMint,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceDark,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
        colorScheme: const ColorScheme.dark(
          primary: primaryMint,
          surface: surfaceDark,
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ChatListTab(),
    NearbyTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: CloverApp.primaryMint,
        unselectedItemColor: Colors.white38,
        backgroundColor: CloverApp.surfaceDark,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Nearby'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class ChatListTab extends StatelessWidget {
  const ChatListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clover Messages'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white70)),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: CloverApp.primaryMint,
              child: Icon(Icons.person, color: CloverApp.bgDark),
            ),
            title: const Text('Alex (Developer)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: const Text('Klik untuk buka percakapan', style: TextStyle(color: Colors.white38, fontSize: 13)),
            trailing: const Text('10:42 AM', style: TextStyle(color: Colors.white38, fontSize: 11)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatDetailScreen(userName: 'Alex')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  const ChatDetailScreen({super.key, required this.userName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  List<String> _savedMessages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedMessages = prefs.getStringList('messages_${widget.userName}') ?? [
        'Halo, selamat datang di Clover!'
      ];
    });
  }

  Future<void> _sendMessage({String type = 'text'}) async {
    if (_msgController.text.trim().isEmpty && type == 'text') return;
    final prefs = await SharedPreferences.getInstance();
    final newMsg = type == 'view_once' ? '📷 Foto (1x Lihat)' : _msgController.text;
    
    setState(() {
      _savedMessages.add(newMsg);
      _msgController.clear();
    });
    
    await prefs.setStringList('messages_${widget.userName}', _savedMessages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: CloverApp.primaryMint,
              child: Icon(Icons.person, size: 18, color: CloverApp.bgDark),
            ),
            const SizedBox(width: 10),
            Text(widget.userName, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: _savedMessages.length,
              itemBuilder: (context, index) {
                final msgText = _savedMessages[index];
                final isViewOnce = msgText.contains('1x Lihat');

                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isViewOnce ? CloverApp.amberSoft.withValues(alpha: 0.15) : CloverApp.myBubbleBg,
                      borderRadius: BorderRadius.circular(14),
                      border: isViewOnce ? Border.all(color: CloverApp.amberSoft.withValues(alpha: 0.5)) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isViewOnce) ...[
                          const Icon(Icons.filter_1_rounded, size: 16, color: CloverApp.amberSoft),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          msgText,
                          style: TextStyle(
                            color: isViewOnce ? CloverApp.amberSoft : Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: CloverApp.surfaceDark,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_1_rounded, color: CloverApp.amberSoft),
                  onPressed: () => _sendMessage(type: 'view_once'),
                  tooltip: 'Pesan 1x Lihat',
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: CloverApp.bgDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: CloverApp.primaryMint),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NearbyTab extends StatelessWidget {
  const NearbyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teman Sekitar')),
      body: const Center(
        child: Text('Fitur Lokasi / Nearby Aktif', style: TextStyle(color: Colors.white38)),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundColor: CloverApp.primaryMint,
              child: Icon(Icons.person, size: 50, color: CloverApp.bgDark),
            ),
            SizedBox(height: 12),
            Text('Sutan Arief Fauzy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 4),
            Text('User Clover App', style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}
