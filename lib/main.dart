import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CloverApp());
}

class CloverApp extends StatelessWidget {
  const CloverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clover',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00E676),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF1E1E1E),
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
        selectedItemColor: const Color(0xFF00E676),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1E1E1E),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Nearby'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF00E676),
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: const Text('Alex (Developer)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Pesan 1x lihat terkirim'),
            trailing: const Text('10:42 AM', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
      appBar: AppBar(title: Text(widget.userName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _savedMessages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _savedMessages[index],
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_1, color: Color(0xFF00E676)),
                  onPressed: () => _sendMessage(type: 'view_once'),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00E676)),
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
        child: Text('Fitur Lokasi / Nearby Aktif', style: TextStyle(color: Colors.grey)),
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
              backgroundColor: Color(0xFF00E676),
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            SizedBox(height: 12),
            Text('Sutan Arief Fauzy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('User Clover App', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
