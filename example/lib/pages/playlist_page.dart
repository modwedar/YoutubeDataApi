import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:line_icons/line_icons.dart';
import 'package:youtube_data_api/models/video.dart';
import 'package:youtube_data_api/youtube_data_api.dart';
import '/widgets/video_widget.dart';

class PlayListPage extends StatefulWidget {
  final title, id;
  const PlayListPage({Key? key, required this.title, required this.id}) : super(key: key);

  @override
  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {

  YoutubeDataApi youtubeDataApi = YoutubeDataApi();
  List<Video> videoList = [];
  bool isLoading = false;
  bool firstLoad = true;
  int loaded = 0;
  String API_KEY = "";

  @override
  void initState() {
    _loadMore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: (){},
            icon: const Icon(LineIcons.rss, color: Colors.white),
          ),
          IconButton(
            onPressed: (){},
            icon: const Icon(LineIcons.share, color: Colors.white),
          )
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    return SafeArea(
      child: Stack(
        children: [
          Visibility(
            visible: firstLoad,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          LazyLoadScrollView(
            isLoading: true,
            onEndOfPage: () => _loadMore(),
            child: SafeArea(
              child: ListView.builder(
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  return video(videoList[index]);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget video(Video video) {
    return VideoWidget(
      video: video,
    );
  }

  Future _loadMore() async {

    setState(() {
      isLoading = true;
    });
    if(loaded >= 1){
      List<Video> newList = await youtubeDataApi.loadMoreInPlayList(API_KEY);
      if(newList.isNotEmpty){
        videoList.addAll(newList);
      }
    } else {
      List<Video> newList = await youtubeDataApi.fetchPlayListVideos(widget.id, loaded);
      videoList.addAll(newList);
    }
    loaded++;
    setState(() {
      isLoading = false;
      firstLoad = false;
    });
  }

}
