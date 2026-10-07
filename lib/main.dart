import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CloverApp());
}

class CloverApp extends StatelessWidget {
  const CloverApp({super.key});

  static const Color bgDark = Color(0xFF14191D);
  static const Color surfaceDark = Color(0xFF1E252B);
  static const Color primaryMint = Color(0xFF38EF7D);
  static const Color myBubbleBg = Color(0xFF1B4D3E);
  static const Color amberSoft = Color(0xFFE6A23C);

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
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur pencarian pesan dibuka')),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white70),
            tooltip: 'Cari Chat',
          ),
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
            subtitle: const Text('Tekan lama pesan untuk menghapus', style: TextStyle(color: Colors.white38, fontSize: 13)),
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

  Future<void> _deleteMessage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedMessages.removeAt(index);
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
                  child: GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: CloverApp.surfaceDark,
                          title: const Text('Hapus Pesan?'),
                          content: const Text('Pesan ini akan dihapus dari obrolan.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _deleteMessage(index);
                              },
                              child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isViewOnce ? CloverApp.amberSoft.withValues(alpha: 0.15) : CloverApp.myBubbleBg,
                        borderRadius: BorderRadius.circular(14),
                        border: isViewOnce ? Border.all(color: CloverApp.amberSoft.withValues(alpha: 0.5)) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
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
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                '10:42',
                                style: TextStyle(color: Colors.white38, fontSize: 10),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.done_all_rounded, size: 14, color: CloverApp.primaryMint),
                            ],
                          ),
                        ],
                      ),
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

  final List<Map<String, String>> _nearbyUsers = const [
    {'name': 'Rian Utama', 'distance': '350 m dari kamu', 'status': 'Online', 'bio': 'Suka ngopi dan koding'},
    {'name': 'Dina Melati', 'distance': '800 m dari kamu', 'status': 'Aktif 5j lalu', 'bio': 'Driver BangKurir / Kulineran'},
    {'name': 'Budi Santoso', 'distance': '1.2 km dari kamu', 'status': 'Online', 'bio': 'Gamer & Mobile Legends'},
    {'name': 'Siti Rahma', 'distance': '2.5 km dari kamu', 'status': 'Aktif 12j lalu', 'bio': 'Desain grafis & Fotografi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teman Sekitar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter jarak diterapkan')),
              );
            },
            tooltip: 'Filter Jarak',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: CloverApp.surfaceDark.withValues(alpha: 0.5),
            child: Row(
              children: const [
                Icon(Icons.location_on, color: CloverApp.primaryMint, size: 20),
                SizedBox(width: 8),
                Text(
                  'Menampilkan pengguna di radius 5 km',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _nearbyUsers.length,
              itemBuilder: (context, index) {
                final user = _nearbyUsers[index];
                final isOnline = user['status'] == 'Online';

                return Card(
                  color: CloverApp.surfaceDark,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                          child: Text(
                            user['name']![0],
                            style: const TextStyle(color: CloverApp.primaryMint, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: CloverApp.primaryMint,
                                shape: BoxShape.circle,
                                border: Border.all(color: CloverApp.surfaceDark, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      user['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          '${user['distance']} • ${user['status']}',
                          style: TextStyle(
                            color: isOnline ? CloverApp.primaryMint : Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['bio']!,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CloverApp.myBubbleBg,
                        foregroundColor: CloverApp.primaryMint,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(userName: user['name']!),
                          ),
                        );
                      },
                      child: const Text('Sapa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
