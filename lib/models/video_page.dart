import 'dart:developer';

class VideoPage {
  String? videoId,
      title,
      date,
      username,
      viewCount,
      likeCount,
      unlikeCount,
      channelThumb,
      channelId;
  String? subscribeCount;

  VideoPage(
      {this.videoId,
        this.title,
        this.username,
        this.viewCount,
        this.subscribeCount,
        this.likeCount,
        this.unlikeCount,
        this.date,
        this.channelThumb,
        this.channelId});

  factory VideoPage.fromMap(Map<String, dynamic>? map,String videoId) {
    log(map.toString());
    return VideoPage(
        videoId: videoId,
        title: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['title']['runs'][0]['text'],
        username: map?['results']['results']['contents'][1]['videoSecondaryInfoRenderer']['owner']['videoOwnerRenderer']['title']['runs'][0]['text'],
        viewCount: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['viewCount']['videoViewCountRenderer']['shortViewCount']['simpleText'],
        subscribeCount: map?['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']?['owner']?['videoOwnerRenderer']?['subscriberCountText']?['simpleText'],
        likeCount: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['videoActions']['menuRenderer']['topLevelButtons'][0]['toggleButtonRenderer']['defaultText']['simpleText'],
        unlikeCount: '',
        date: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['dateText']['simpleText'],
        channelThumb: map?['results']['results']['contents'][1]['videoSecondaryInfoRenderer']['owner']['videoOwnerRenderer']['thumbnail']['thumbnails'][1]['url'],
        channelId: map?['results']['results']['contents'][1]['videoSecondaryInfoRenderer']['owner']['videoOwnerRenderer']['navigationEndpoint']['browseEndpoint']['browseId']
    );
  }
}