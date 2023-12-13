import 'package:flutter/material.dart';
import 'package:domain_models/domain_models.dart';
import 'package:component_library/component_library.dart';
import 'package:common_utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BigFeedView extends StatelessWidget {
  const BigFeedView({super.key, required this.feed});

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: feed.image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                //placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
          ),
          Container(
            height: 12,
          ),
          Text(feed.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.bold,
                  color: theme.feedTitleColor)),
          Container(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                feed.updatedAt.toShortString(),
                style: TextStyle(
                    fontSize: FontSize.small, color: theme.feedTitleColor),
              ),
              Text(
                "${feed.pageviews}阅读",
                style: TextStyle(
                    fontSize: FontSize.small, color: theme.feedDescColor),
              )
            ],
          ),
          Container(
            height: 12,
          ),
          const Divider(
            color: Colors.black12,
          )
        ],
      ),
    );
  }
}

class SmallFeedView extends StatelessWidget {
  const SmallFeedView({super.key, required this.feed});

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feed.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: FontSize.mediumLarge,
                              fontWeight: FontWeight.bold,
                              color: theme.feedTitleColor)),
                      Row(
                        children: [
                          Text(feed.updatedAt.toShortString(),
                              style: TextStyle(
                                  fontSize: FontSize.small,
                                  color: theme.feedDescColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("|",
                                style: TextStyle(
                                    fontSize: FontSize.small,
                                    color: theme.feedDescColor)),
                          ),
                          Text("${feed.pageviews}阅读",
                              style: TextStyle(
                                  fontSize: FontSize.small,
                                  color: theme.feedDescColor))
                        ],
                      )
                    ],
                  )),
              Container(
                width: 12,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:feed.image,
                    width: 120,
                    height: 70,
                    fit: BoxFit.cover,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ))
            ],
          ),
        ));
  }
}

class MovieFeedView extends StatelessWidget {
  const MovieFeedView({super.key, required this.feed});

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feed.updatedAt.toShortString(),
            style:
            TextStyle(fontSize: FontSize.small, color: theme.feedDescColor),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(feed.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.bold,
                  color: theme.feedTitleColor)),
          const SizedBox(
            height: 12,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl:feed.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              //placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(feed.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: FontSize.large,
                          fontWeight: FontWeight.bold,
                          color: theme.feedTitleColor))),
              Text(
                "${feed.pageviews}收看",
                style: TextStyle(fontSize: 12, color: theme.feedDescColor),
              )
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}

class WordFeedView extends StatelessWidget {
  const WordFeedView({super.key, required this.feed});

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl:feed.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              //placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Container(
            height: 12,
          ),
          Row(
            children: [
              Text(feed.title,
                  style: TextStyle(
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.bold,
                      color: theme.feedTitleColor)),
              const SizedBox(width: 12,),
              Expanded(child: Text(
                feed.addition!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: FontSize.small, color: theme.feedTitleColor),
              )),
            ],
          ),
          Container(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                feed.updatedAt.toShortString(),
                style: TextStyle(
                    fontSize: FontSize.small, color: theme.feedDescColor),
              ),
              Text(
                "${feed.pageviews}配音",
                style: TextStyle(
                    fontSize: FontSize.small, color: theme.feedDescColor),
              )
            ],
          ),
          Container(
            height: 12,
          ),
          const Divider(
            color: Colors.black12,
          )
        ],
      ),
    );
  }
}


extension DataTimetoShow on DateTime {
  String toShortString() {
    //今天，1天前，2天前
    if (DateUtil.isToday(toLocal().millisecondsSinceEpoch)) {
      return "今天";
    }
    if (DateUtil.isYesterday(toLocal(), DateTime.now())) {
      return "1天前";
    }
    return DateUtil.formatDate(toLocal(), format: DateFormats.y_mo_d);
  }
}