import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<PlatformFile> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;

  Future<void> _pickMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _playlist = result.files;
        _currentIndex = 0;
      });
      _playSong();
    }
  }

  void _playSong() async {
    if (_playlist.isEmpty) return;
    String path = _playlist[_currentIndex].path!;
    await _audioPlayer.play(DeviceFileSource(path));
    setState(() => _isPlaying = true);
  }

  void _pauseSong() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  void _nextSong() {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _playSong();
    }
  }

  void _prevSong() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _playSong();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reading Music')),
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickMusic,
            icon: Icon(Icons.folder_open),
            label: Text("Select Music Files"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _playlist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_playlist[index].name, maxLines: 1),
                  leading: Icon(Icons.music_note),
                  selected: index == _currentIndex,
                  onTap: () {
                    _currentIndex = index;
                    _playSong();
                  },
                );
              },
            ),
          ),
          if (_playlist.isNotEmpty)
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.brown[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: Icon(Icons.skip_previous, size: 35), onPressed: _prevSong),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 50),
                    onPressed: _isPlaying ? _pauseSong : _playSong,
                  ),
                  IconButton(icon: Icon(Icons.skip_next, size: 35), onPressed: _nextSong),
                ],
              ),
            )
        ],
      ),
    );
  }
}
