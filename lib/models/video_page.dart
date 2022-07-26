import 'package:youtube_data_api/helpers/description_helper.dart';

class VideoPage {
  ///Get video id from video page
  String? videoId;
  ///Get video title from video page
  String? title;
  ///Get video date from video page
  String? date;
  ///Get video description from video page
  String? description;
  ///Get video channel name from video page
  String? channelName;
  ///Get video views count as string from video page
  String? viewCount;
  ///Get video likes count as string from video page
  String? likeCount;
  ///Get video unlikes count as string from video page
  String? unlikeCount;
  ///Get video channel thumbnail from video page
  String? channelThumb;
  ///Get channel id from video page
  String? channelId;
  ///Get channel subscribes count as string from video page
  String? subscribeCount;

  VideoPage({this.videoId,
    this.title,
    this.channelName,
    this.viewCount,
    this.subscribeCount,
    this.likeCount,
    this.unlikeCount,
    this.date,
    this.description,
    this.channelThumb,
    this.channelId});


  factory VideoPage.fromMap(Map<String, dynamic>? map, String videoId) {
    return VideoPage(
        videoId: videoId,
        title: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['title']['runs'][0]['text'],
        channelName: map?['results']['results']['contents'][1]['videoSecondaryInfoRenderer']['owner']['videoOwnerRenderer']['title']['runs'][0]['text'],
        viewCount: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['viewCount']['videoViewCountRenderer']['shortViewCount']['simpleText'],
        subscribeCount: map?['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']?['owner']?['videoOwnerRenderer']?['subscriberCountText']?['simpleText'],
        likeCount: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['videoActions']['menuRenderer']['topLevelButtons'][0]['toggleButtonRenderer']['defaultText']['simpleText'],
        unlikeCount: '',
        description: collectDescriptionString(
            map?['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']?['description']?['runs']),
        date: map?['results']['results']['contents'][0]['videoPrimaryInfoRenderer']['dateText']['simpleText'],
        channelThumb: map?['results']['results']['contents'][1]['videoSecondaryInfoRenderer']['owner']['videoOwnerRenderer']['thumbnail']['thumbnails'][1]['url'],
        channelId: map?['results']['results']['contents'][1]['videoSecondaryInfoRenderer']['owner']['videoOwnerRenderer']['navigationEndpoint']['browseEndpoint']['browseId']
    );
  }
}