class Channel {
  ///Youtube channel id
  String? channelId;
  ///Youtube channel title
  String? title;
  ///Youtube channel thumbnail
  String? thumbnail;
  ///Youtube channel number of videos
  String? videoCount;

  Channel({this.channelId, this.title, this.thumbnail, this.videoCount});

  factory Channel.fromMap(Map<String, dynamic>? map) {
    return Channel(
        channelId: map?['channelRenderer']['channelId'],
        thumbnail: map?['channelRenderer']['thumbnail']
        ['thumbnails'][0]['url'],
        title: map?['channelRenderer']['title']['simpleText'],
      videoCount: map?['channelRenderer']['videoCountText']
      ['runs'][0]['text']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "channelId": channelId,
      "title": title,
      "thumbnail": thumbnail,
      "videoCount": videoCount,
    };
  }
}