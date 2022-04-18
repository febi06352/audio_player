import 'package:audio_player/Controller/LaguController.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeAudio extends StatefulWidget {
  @override
  _HomeAudioState createState() => _HomeAudioState();
}

class _HomeAudioState extends State<HomeAudio> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<LaguController>(context, listen: false).init();
    super.initState();
  }

  void dispose() {
    AudioManager.instance.release();
    super.dispose();
  }

  Widget bottomPanel(LaguController l_controller) {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context, l_controller),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: getPlayModeIcon(l_controller.playMode),
                onPressed: () {
                  l_controller.playMode = AudioManager.instance.nextMode();
                  l_controller.notifyListeners();
                }),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.previous()),
            IconButton(
              onPressed: () async {
                bool playing = await AudioManager.instance.playOrPause();
                print("await -- $playing");
              },
              padding: const EdgeInsets.all(0.0),
              icon: Icon(
                l_controller.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: Colors.black,
              ),
            ),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.next()),
            IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.stop()),
          ],
        ),
      ),
    ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.black,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.black,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.black,
        );
    }
    return Container();
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget songProgress(BuildContext context, LaguController l_controller) {
    var style = TextStyle(color: Colors.black);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(AudioManager.instance.position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: l_controller.slider ?? 0,
                  onChanged: (value) {
                    setState(() {
                      l_controller.slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (AudioManager.instance.duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                              (AudioManager.instance.duration.inMilliseconds *
                                      value)
                                  .round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(AudioManager.instance.duration),
          style: style,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LaguController>(
      builder: (context, l_controller, child) {
        return Scaffold(
          body: SafeArea(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: l_controller.c_lagu,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Cari disini',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide(color: Colors.grey[100]),
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 5, right: 15),
                          ),
                          readOnly: false,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          BotToast.showLoading();
                          await l_controller.ambilLagu();
                          BotToast.closeAllLoading();
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          margin:
                              EdgeInsets.only(left: 16, right: 16, bottom: 20),
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue)),
                          child: Center(
                            child: Text(
                              'Search',
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: l_controller.dataLagu.length,
                            itemBuilder: (context, songIndex) {
                              return Card(
                                elevation: 5,
                                color: l_controller.index_play == songIndex
                                    ? Colors.blue[100]
                                    : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ClipRRect(
                                          child: CachedNetworkImage(
                                              imageUrl: l_controller
                                                      .dataLagu[songIndex]
                                                  ["artworkUrl100"],
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) {
                                                return Image.asset(
                                                  url,
                                                  fit: BoxFit.cover,
                                                );
                                              }),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        flex: 2,
                                      ),
                                      Expanded(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      child: Text(
                                                          l_controller.dataLagu[
                                                                      songIndex]
                                                                  [
                                                                  'trackName'] ??
                                                              '',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                    ),
                                                    Text(
                                                        "Release Year: ${l_controller.dataLagu[songIndex]['releaseDate']}",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    Text(
                                                        "Artist: ${l_controller.dataLagu[songIndex]['artistName']}",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    Text(
                                                        l_controller.dataLagu[
                                                                        songIndex]
                                                                    [
                                                                    'trackTimeMillis'] ==
                                                                null
                                                            ? 'Unknown'
                                                            : "Duration: ${l_controller.parseToMinutesSeconds(int.parse(l_controller.dataLagu[songIndex]['trackTimeMillis'].toString()))} min",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                ),
                                                flex: 10,
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    AudioManager.instance.stop();
                                                    AudioManager.instance.play(index: songIndex,auto: true);
                                                  },
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.play_circle_outline,
                                                      color: Colors.red,
                                                      size: 25,
                                                    ),
                                                    tooltip: "Play",
                                                  ),
                                                ),
                                                flex: 2,
                                              )
                                            ],
                                          ),
                                        ),
                                        flex: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                )),
          ),
          bottomNavigationBar: Container(
            height: 120,
            width: MediaQuery.of(context).size.width,
            child: bottomPanel(l_controller),
          ),
        );
      },
    );
  }
}
