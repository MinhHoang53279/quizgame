import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/services/room_service.dart';
import '../data/models/room.dart';
import '../data/providers/user_provider.dart';
import '../theme.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  bool _isLoading = false;
  Room? _room;
  String? _error;

  Future<void> _createRoom() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final hostId = userProvider.currentUser?.id;
      if (hostId == null) {
        setState(() {
          _error = 'Bạn cần đăng nhập để tạo phòng!';
          _isLoading = false;
        });
        return;
      }
      final room = await RoomService().createRoom(hostId);
      setState(() {
        _room = room;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo phòng Quiz')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _room != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Phòng đã được tạo!'),
                      Text('Mã phòng: \\${_room!.code}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Chia sẻ mã này cho bạn bè để cùng tham gia.'),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Chuyển sang màn hình chờ phòng
                        },
                        child: const Text('Vào phòng'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_error != null) ...[
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton(
                        onPressed: _createRoom,
                        child: const Text('Tạo phòng mới'),
                      ),
                    ],
                  ),
      ),
    );
  }
} 