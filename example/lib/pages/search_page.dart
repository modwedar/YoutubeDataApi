import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:youtube_data_api/models/channel.dart';
import 'package:youtube_data_api/models/playlist.dart';
import 'package:youtube_data_api/models/video.dart';
import 'package:youtube_data_api/youtube_data_api.dart';
import '/helpers/suggestion_history.dart';
import '/widgets/channel_widget.dart';
import '/widgets/playList_widget.dart';
import '/widgets/video_widget.dart';

class SearchPage extends StatefulWidget {
  String query;

  SearchPage(this.query);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  YoutubeDataApi youtubeDataApi = YoutubeDataApi();
  List? contentList;
  bool isLoading = false;
  bool firstLoad = true;
  String API_KEY = "";

  @override
  void initState() {
    contentList = [];
    _loadMore(widget.query);
    SuggestionHistory.init();
    SuggestionHistory.store(widget.query);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return SafeArea(
      child: Stack(
        children: [
          Visibility(
            visible: firstLoad,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          LazyLoadScrollView(
            isLoading: isLoading,
            onEndOfPage: () => _loadMore(widget.query),
            child: ListView.builder(
              itemCount: contentList!.length,
              itemBuilder: (context, index) {
                if (isLoading && index == contentList!.length - 1) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (contentList![index] is Video) {
                    return video(contentList![index]);
                  } else if (contentList![index] is Channel) {
                    return channel(contentList![index]);
                  } else if (contentList![index] is PlayList) {
                    return playList(contentList![index]);
                  }
                  return Container();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget video(Video video) {
    return VideoWidget(
      videoId: video.videoId!,
      duration: video.duration!,
      title: video.title!,
      channelName: video.channelName!,
      views: video.views!,
    );
  }

  Widget playList(PlayList playList) {
    return PlayListWidget(
      id: playList.playListId!,
      thumbnails: playList.thumbnails!,
      videoCount: playList.videoCount!,
      title: playList.title!,
      channelName: playList.channelName!,
    );
  }


  Widget channel(Channel channel) {
    return ChannelWidget(
      id: channel.channelId!,
      thumbnail: channel.thumbnail!,
      title: channel.title!,
      videoCount: channel.videoCount!,
    );
  }

  Future _loadMore(String query) async {
    setState(() {
      isLoading = true;
    });
    List newList = await youtubeDataApi.fetchSearchVideo(query, API_KEY);
    contentList!.addAll(newList);
    setState(() {
      isLoading = false;
      firstLoad = false;
    });
  }
}
