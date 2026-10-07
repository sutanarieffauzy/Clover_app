import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
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

class ChatListTab extends StatefulWidget {
  const ChatListTab({super.key});

  @override
  State<ChatListTab> createState() => _ChatListTabState();
}

class _ChatListTabState extends State<ChatListTab> {
  List<String> _chatUsers = ['Alex (Developer)'];
  Map<String, String> _lastMessages = {};

  @override
  void initState() {
    super.initState();
    _loadChatList();
  }

  Future<void> _loadChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];
    
    Map<String, String> tempLastMsg = {};
    for (String user in savedUsers) {
      final msgs = prefs.getStringList('messages_$user') ?? [];
      if (msgs.isNotEmpty) {
        final last = msgs.last;
        if (last.startsWith('📷 [VIEW_ONCE_IMG]:')) {
          tempLastMsg[user] = '📷 Foto 1x Lihat';
        } else {
          tempLastMsg[user] = last;
        }
      } else {
        tempLastMsg[user] = 'Belum ada pesan';
      }
    }

    setState(() {
      _chatUsers = savedUsers;
      _lastMessages = tempLastMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clover Messages'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadChatList,
        child: ListView.builder(
          itemCount: _chatUsers.length,
          itemBuilder: (context, index) {
            final userName = _chatUsers[index];
            final lastMsg = _lastMessages[userName] ?? 'Ketuk untuk membuka obrolan';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(color: CloverApp.primaryMint, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(userName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              subtitle: Text(
                lastMsg,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatDetailScreen(userName: userName)),
                );
                _loadChatList();
              },
            );
          },
        ),
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
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _sendMessage({String? customText}) async {
    final text = customText ?? _msgController.text.trim();
    if (text.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Simpan ke riwayat pesan
    _savedMessages.add(text);
    await prefs.setStringList('messages_${widget.userName}', _savedMessages);

    // Tambahkan pengguna ke daftar chat utama jika belum ada
    List<String> activeUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];
    if (!activeUsers.contains(widget.userName)) {
      activeUsers.add(widget.userName);
      await prefs.setStringList('active_chat_users', activeUsers);
    }

    setState(() {
      if (customText == null) _msgController.clear();
    });
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _sendMessage(customText: '📷 [VIEW_ONCE_IMG]:${image.path}');
    }
  }

  Future<void> _deleteMessage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedMessages.removeAt(index);
    });
    await prefs.setStringList('messages_${widget.userName}', _savedMessages);
  }

  void _openViewOnceImage(String imagePath, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Foto 1x Lihat', style: TextStyle(color: CloverApp.amberSoft, fontWeight: FontWeight.bold)),
            ),
            Image.file(File(imagePath), fit: BoxFit.contain),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deleteMessage(index);
              },
              child: const Text('Tutup & Hapus', style: TextStyle(color: Colors.redAccent)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(widget.userName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: _savedMessages.length,
                itemBuilder: (context, index) {
                  final msgText = _savedMessages[index];
                  final isViewOnceImg = msgText.startsWith('📷 [VIEW_ONCE_IMG]:');
                  final imgPath = isViewOnceImg ? msgText.replaceFirst('📷 [VIEW_ONCE_IMG]:', '') : '';

                  return Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if (isViewOnceImg) {
                          _openViewOnceImage(imgPath, index);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isViewOnceImg ? CloverApp.amberSoft.withValues(alpha: 0.15) : CloverApp.myBubbleBg,
                          borderRadius: BorderRadius.circular(14),
                          border: isViewOnceImg ? Border.all(color: CloverApp.amberSoft) : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isViewOnceImg) ...[
                              const Icon(Icons.filter_1_rounded, size: 18, color: CloverApp.amberSoft),
                              const SizedBox(width: 6),
                              const Text(
                                'Foto 1x Lihat (Ketuk untuk buka)',
                                style: TextStyle(color: CloverApp.amberSoft, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ] else
                              Text(
                                msgText,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
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
                    onPressed: _pickAndSendImage,
                    tooltip: 'Kirim Foto Galeri 1x Lihat',
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
      ),
    );
  }
}

class NearbyTab extends StatelessWidget {
  const NearbyTab({super.key});

  final List<Map<String, String>> _nearbyUsers = const [
    {'name': 'Rian Utama', 'distance': '350 m dari kamu', 'status': 'Online', 'bio': 'Suka ngopi dan koding'},
    {'name': 'Dina Melati', 'distance': '800 m dari kamu', 'status': 'Aktif 5j lalu', 'bio': 'Kulineran & Traveling'},
    {'name': 'Budi Santoso', 'distance': '1.2 km dari kamu', 'status': 'Online', 'bio': 'Gamer & Mobile Legends'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teman Sekitar')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _nearbyUsers.length,
        itemBuilder: (context, index) {
          final user = _nearbyUsers[index];
          return Card(
            color: CloverApp.surfaceDark,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                child: Text(user['name']![0], style: const TextStyle(color: CloverApp.primaryMint, fontWeight: FontWeight.bold)),
              ),
              title: Text(user['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('${user['distance']} • ${user['bio']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CloverApp.myBubbleBg,
                  foregroundColor: CloverApp.primaryMint,
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  List<String> activeUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];
                  if (!activeUsers.contains(user['name'])) {
                    activeUsers.add(user['name']!);
                    await prefs.setStringList('active_chat_users', activeUsers);
                  }

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatDetailScreen(userName: user['name']!)),
                    );
                  }
                },
                child: const Text('Sapa'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'Sutan Arief Fauzy';
  String _bio = 'Driver BangKurir | Flutter Dev';
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Sutan Arief Fauzy';
      _bio = prefs.getString('user_bio') ?? 'Driver BangKurir | Flutter Dev';
      _profileImagePath = prefs.getString('user_profile_img');
    });
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_img', image.path);
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  Future<void> _editProfileDialog() async {
    final nameCtrl = TextEditingController(text: _name);
    final bioCtrl = TextEditingController(text: _bio);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CloverApp.surfaceDark,
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio / Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CloverApp.primaryMint, foregroundColor: CloverApp.bgDark),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', nameCtrl.text);
              await prefs.setString('user_bio', bioCtrl.text);
              setState(() {
                _name = nameCtrl.text;
                _bio = bioCtrl.text;
              });
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: CloverApp.primaryMint,
                    backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                    child: _profileImagePath == null
                        ? const Icon(Icons.person, size: 60, color: CloverApp.bgDark)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: CloverApp.primaryMint,
                      child: const Icon(Icons.camera_alt, size: 16, color: CloverApp.bgDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text(_bio, style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: CloverApp.surfaceDark,
                foregroundColor: CloverApp.primaryMint,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: _editProfileDialog,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Data Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
