import 'package:flutter/material.dart';
import 'dart:async';
import '../data/models/room.dart';
import '../data/services/room_service.dart';
import 'room_quiz_screen.dart';
import '../theme.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomId;
  final bool isHost;
  const WaitingRoomScreen({super.key, required this.roomId, required this.isHost});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  Room? _room;
  bool _isLoading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchRoom();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchRoom());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoom() async {
    try {
      final room = await RoomService().getRoom(widget.roomId);
      if (mounted) {
        setState(() { _room = room; _isLoading = false; });
        if (room.started) {
          _timer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RoomQuizScreen(roomId: widget.roomId)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phòng chờ Quiz')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: \\${_error!}', style: const TextStyle(color: Colors.red)))
              : _room == null
                  ? const Center(child: Text('Không tìm thấy phòng!'))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Mã phòng: \\${_room!.code}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text('Thành viên trong phòng:'),
                        ..._room!.memberIds.map((id) => ListTile(title: Text('User: \\${id}'))),
                        const SizedBox(height: 32),
                        if (widget.isHost)
                          ElevatedButton(
                            onPressed: () async {
                              // TODO: Gọi API bắt đầu quiz cho phòng
                              // Tạm thời mô phỏng bằng cách chuyển trạng thái started trên backend
                              // Sau khi backend xử lý, polling sẽ tự động chuyển sang RoomQuizScreen
                            },
                            child: const Text('Bắt đầu Quiz'),
                          ),
                        if (!widget.isHost)
                          const Text('Chờ chủ phòng bắt đầu quiz...'),
                      ],
                    ),
    );
  }
} 