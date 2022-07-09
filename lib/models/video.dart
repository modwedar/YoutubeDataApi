class Video {
  ///Youtube video id
  String? videoId;

  ///Youtube video duration
  String? duration;

  ///Youtube video title
  String? title;

  ///Youtube video channel name
  String? channelName;

  ///Youtube video views
  String? views;

  String? thumbnail;

  Video(
      {this.videoId, this.duration, this.title, this.channelName, this.views, this.thumbnail});

  factory Video.fromMap(Map<String, dynamic>? map) {
    if(map?.containsKey("videoRenderer")?? false){
      ///Trending and search videos
      var lengthText = map?['videoRenderer']?['lengthText'];
      var simpleText =
      map?['videoRenderer']?['shortViewCountText']?['simpleText'];
      return Video(
          videoId: map?['videoRenderer']?['videoId'],
          duration: (lengthText == null) ? "Live" : lengthText?['simpleText'],
          title: map?['videoRenderer']?['title']?['runs']?[0]?['text'],
          channelName: map?['videoRenderer']['longBylineText']['runs'][0]['text'],
          views: (lengthText == null)
              ? "Views " +
              map!['videoRenderer']['viewCountText']['runs'][0]['text']
              : simpleText);
    } else if (map?.containsKey("compactVideoRenderer")?? false){
      ///Related videos
      return Video(
        videoId: map?['compactVideoRenderer']['videoId'],
        title: map?['compactVideoRenderer']
        ?['title']?['simpleText'],
        duration: map?['compactVideoRenderer']
        ?['lengthText']?['simpleText'],
        thumbnail: map?['compactVideoRenderer']
        ['thumbnail']['thumbnails'][1]
        ['url'],
        channelName: map?['compactVideoRenderer']
        ?['shortBylineText']?['runs']
        ?[0]?['text'],
        views: map?['compactVideoRenderer']
        ?['viewCountText']?['simpleText']
      );
    } else if(map?.containsKey("gridVideoRenderer")?? false) {
      String? simpleText = map?['gridVideoRenderer']
      ['shortViewCountText']?['simpleText'];
      return Video(
          videoId: map?['gridVideoRenderer']['videoId'],
          title: map?['gridVideoRenderer']['title']['runs'][0]
          ['text'],
          duration: map?['gridVideoRenderer']['thumbnailOverlays'][0]
          ['thumbnailOverlayTimeStatusRenderer']['text']['simpleText'],
          views: (simpleText != null) ? simpleText : "???"
      );
    }
    return Video();
  }

  Map<String, dynamic> toJson() {
    return {
      "videoId": videoId,
      "duration": duration,
      "title": title,
      "channelName": channelName,
      "views": views
    };
  }
}
