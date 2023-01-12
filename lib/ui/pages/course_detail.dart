import 'package:learncoding/models/course.dart';
import 'package:learncoding/models/lesson.dart';
import 'package:learncoding/services/api_controller.dart';
import 'package:learncoding/theme/box_icons_icons.dart';
import 'package:learncoding/ui/widgets/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:learncoding/theme/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final CourseElement courseData;
  const CourseDetailPage({
    Key? key,
    required this.courseData,
  }) : super(key: key);

  @override
  _CoursePagePageState createState() => _CoursePagePageState();
}

class _CoursePagePageState extends State<CourseDetailPage> {
  late YoutubePlayerController _controller;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  bool _muted = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    String url = widget.courseData.shortVideo;
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(url)!,
      flags: const YoutubePlayerFlags(
        controlsVisibleAtStart: true,
        autoPlay: false,
      ),
    )..addListener(listener);
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List sectionList(lessonData) {
    var seen = [];
    for (var lesson in lessonData) {
      seen.add(lesson.section);
    }
    final sectionList = seen.toSet().toList();
    return sectionList;
  }

  List lessonList(lessonData, section) {
    var seen = [];
    for (var lesson in lessonData) {
      if (lesson.section == section) {
        seen.add(lesson.title);
      }
    }
    return seen;
  }

  Widget buildVideoPlayer() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.4,
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controlsTimeOut: const Duration(seconds: 3),
            width: MediaQuery.of(context).size.width,
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            bottomActions: [
              IconButton(
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                color: _muted ? Colors.grey : Colors.blue,
                onPressed: _isPlayerReady
                    ? () {
                        _muted ? _controller.unMute() : _controller.mute();
                        setState(() {
                          _muted = !_muted;
                        });
                      }
                    : null,
              ),
              FullScreenButton(
                controller: _controller,
                color: Colors.blueAccent,
              ),
            ],
            onReady: () {
              _isPlayerReady = true;
              _controller.addListener(listener);
            },
            onEnded: (data) {},
          ),
          builder: (BuildContext, player) {
            return Scaffold(
                body: Container(
              child: player,
            ));
          },
        ));
  }

  Widget buildlesson() {
    return FutureBuilder<Lesson>(
        future: ApiProvider().retrieveLessons(widget.courseData.slug),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final lessonData = snapshot.data!.lessons;
            List sections = sectionList(lessonData);
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: const Text(
                    "Lessons",
                    style: TextStyle(
                        color: Color(0xFF343434),
                        fontFamily: 'Red Hat Display',
                        fontSize: 24),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.865,
                  margin: const EdgeInsets.only(bottom: 70),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 215, 214, 214),
                    ),
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            buildLessonList(lessonData, sections[index]),
                            index < sections.length
                                ? const Divider(
                                    color: Color.fromARGB(255, 215, 214, 214),
                                    thickness: 1,
                                    height: 1,
                                  )
                                : Container()
                          ],
                        );
                      }),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget buildLessonList(lessonData, section) {
    return Material(
      color: config.Colors().secondColor(1),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: const Color.fromARGB(0, 208, 57, 57),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 172, 172, 172),
            size: 35,
          ),
        ),
        child: ExpansionTile(
          title: Flexible(
            child: Text(
              section,
              style: const TextStyle(
                fontFamily: 'Red Hat Display',
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 121, 121, 123), //cahnge?
              ),
            ),
          ),
          tilePadding: const EdgeInsets.fromLTRB(15, 1, 10, 1),
          iconColor: const Color.fromARGB(255, 172, 172, 172),
          collapsedIconColor: const Color.fromARGB(255, 172, 172, 172), //c
          children: <Widget>[
            const Divider(
              color: Color.fromARGB(255, 215, 214, 214),
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 10),
            ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: null == lessonData
                    ? 0
                    : lessonList(lessonData, section).length,
                itemBuilder: (context, index) {
                  List a = lessonList(lessonData, section);
                  return Container(
                    padding: const EdgeInsets.fromLTRB(17, 0, 15, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_outlined,
                                size: 25,
                                color: index <= 2 ? Colors.blue : Colors.grey),
                            const SizedBox(
                              width: 17,
                            ),
                            Text(
                              a[index],
                              style: TextStyle(
                                color: index == 2 ? Colors.blue : Colors.grey,
                                fontFamily: 'Red Hat Display',
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        Container(
                            padding: const EdgeInsets.only(left: 12),
                            alignment: Alignment.topLeft,
                            child: index < a.length - 1
                                ? Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.grey,
                                  )
                                : Container())
                      ],
                    ),
                  );
                }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: config.Colors().secondColor(1),
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: "Back",
        backgroundColor: Colors.white,
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(BoxIcons.bx_share_alt),
          onPressed: () {},
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height + 60,
              child: SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        buildVideoPlayer(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 10, 8, 8.0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 4,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(500),
                                          color: const Color(0xFF343434)),
                                      child: const Text(""),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          widget.courseData.name,
                                          style: const TextStyle(
                                              color: Color(0xFF343434),
                                              fontFamily: 'Red Hat Display',
                                              fontSize: 24),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: const <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(BoxIcons.bx_bar_chart_alt_2,
                                          size: 20, color: Color(0xFFADADAD)),
                                    ),
                                    Text(
                                      "Beginner",
                                      style: TextStyle(
                                          color: Color(0xFFADADAD),
                                          fontFamily: 'Red Hat Display',
                                          fontSize: 14),
                                    ),
                                    Spacer(),
                                    Text(
                                      "12 mins",
                                      style: TextStyle(
                                          color: Color(0xFFADADAD),
                                          fontFamily: 'Red Hat Display',
                                          fontSize: 14),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(BoxIcons.bx_timer,
                                          size: 20, color: Color(0xFFADADAD)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.all(8),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Text(
                                    widget.courseData.description,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      color: Color(0xFF343434),
                                      fontFamily: 'Red Hat Display',
                                      fontSize: 16,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        buildlesson(),
                      ],
                    ),
                    Positioned(
                        right: 30,
                        top: MediaQuery.of(context).size.height * 0.365,
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFABDCFF),
                                  Color(0xFF0396FF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 25,
                                    color: const Color(0xFF03A9F4)
                                        .withOpacity(0.4),
                                    offset: const Offset(0, 4))
                              ],
                              borderRadius: BorderRadius.circular(500)),
                          child: FloatingActionButton(
                              heroTag: "video",
                              elevation: 0,
                              highlightElevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                  _controller.value.isPlaying
                                      ? BoxIcons.bx_pause
                                      : BoxIcons.bx_play,
                                  size: 40),
                              onPressed: () {
                                setState(() {
                                  // print(_isPlayerReady);
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              }),
                        )),
                  ],
                ),
              )),
          Positioned(
            bottom: 0,
            left: 0,
            child: CardWidget(
              button: true,
              gradient: true,
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    "Attempt Test",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Red Hat Display',
                        fontSize: 18),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(BoxIcons.bx_pencil, color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}