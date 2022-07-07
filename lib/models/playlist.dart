import 'package:youtube_data_api/models/thumbnail.dart';

class PlayList {
  ///Youtube playlist id
  String? playListId;

  ///Youtube playlist thumbnails
  List<Thumbnail>? thumbnails;

  ///Youtube playlist title
  String? title;

  ///Youtube playlist channel name
  String? channelName;

  ///Youtube playlist number of videos
  String? videoCount;

  PlayList(
      {this.playListId,
      this.thumbnails,
      this.title,
      this.channelName,
      this.videoCount});

  factory PlayList.fromMap(Map<String, dynamic>? map) {
    List<Thumbnail> thumbnails = [];
    map?['playlistRenderer']['thumbnails'][0]['thumbnails']
        .forEach((thumbnail) {
      thumbnails.add(Thumbnail(url: thumbnail['url']));
    });
    return PlayList(
        playListId: map?['playlistRenderer']['playlistId'],
        thumbnails: thumbnails,
        title: map?['playlistRenderer']['title']['simpleText'],
        videoCount: map?['playlistRenderer']['videoCount'],
        channelName: map?['playlistRenderer']['shortBylineText']['runs'][0]
            ['text']);
  }

  Map<String, dynamic> toJson() {
    return {
      "playListId": playListId,
      "thumbnails": thumbnails,
      "title": title,
      "videoCount": videoCount,
    };
  }
}
