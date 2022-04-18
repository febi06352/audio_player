import 'dart:convert';

import 'package:audio_manager/audio_manager.dart';
import 'package:audio_player/Api/ApiItunes.dart';
import 'package:flutter/cupertino.dart';

class LaguController extends ChangeNotifier {
  List dataLagu = List();
  bool isPlaying = false;
  Duration _duration;
  Duration position;
  double slider;
  double sliderVolume;
  String error;
  num curIndex = 0;
  int index_play = 0;
  PlayMode playMode = AudioManager.instance.playMode;
  TextEditingController c_lagu = TextEditingController();
  void init() {
    dataLagu = List();
    c_lagu.text = '';
  }

  Future<void> ambilLagu() async {
    try {
      String hasil = await ApiItunes().AmbilLagu(c_lagu.value.text);
      dataLagu = jsonDecode(hasil)['results'];
      await setupAudio(dataLagu);
    } catch (e) {
      dataLagu = List();
    }
    notifyListeners();
  }

  void setupAudio(List list) {
    List<AudioInfo> _list = [];
    list.forEach((item) => _list.add(AudioInfo(item["previewUrl"],
        title: item["trackName"] ?? 'Unknown',
        desc: item["trackName"] ?? 'Unknown',
        coverUrl: item["artworkUrl100"] ?? '')));

    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print(
              "start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          index_play = AudioManager.instance.curIndex;
          position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          slider = 0;
          notifyListeners();
          AudioManager.instance.updateLrc("audio resource loading....");
          break;
        case AudioManagerEvents.ready:
          print("ready to play gaes");
          error = null;
          sliderVolume = AudioManager.instance.volume;
          position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          notifyListeners();
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          position = AudioManager.instance.position;
          slider = position.inMilliseconds / _duration.inMilliseconds;
          notifyListeners();
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          notifyListeners();
          break;
        case AudioManagerEvents.timeupdate:
          position = AudioManager.instance.position;
          slider = position.inMilliseconds / _duration.inMilliseconds;
          notifyListeners();
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          error = args;
          notifyListeners();
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          sliderVolume = AudioManager.instance.volume;
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  String parseToMinutesSeconds(int ms) {
    String data;
    Duration duration = Duration(milliseconds: ms);

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds) - (minutes * 60);

    data = minutes.toString() + ":";
    if (seconds <= 9) data += "0";

    data += seconds.toString();
    return data;
  }
}
