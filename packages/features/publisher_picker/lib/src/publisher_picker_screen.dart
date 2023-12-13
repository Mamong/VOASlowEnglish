import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:publisher_picker/src/publisher_picker_cubit.dart';

class PublisherPickerScreen extends StatelessWidget {
  const PublisherPickerScreen({
    required this.feedRepository,
    this.onTapTag,
    Key? key,
  }) : super(key: key);

  final FeedRepository feedRepository;
  final Function(String publisher,String tag)? onTapTag;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublisherPickerCubit>(
      create: (_) => PublisherPickerCubit(
        feedRepository: feedRepository,
      ),
      child: PublisherPickerView(
        feedRepository: feedRepository,
        onTapTag: onTapTag,
      ),
    );
  }
}

class PublisherPickerView extends StatefulWidget {
  const PublisherPickerView({
    Key? key,
    required this.feedRepository,
    this.onTapTag,
  }) : super(key: key);

  final FeedRepository feedRepository;
  final Function(String publisher,String tag)? onTapTag;

  @override
  PublisherPickerViewState createState() => PublisherPickerViewState();
}

class PublisherPickerViewState extends State<PublisherPickerView> {
  PublisherPickerCubit get _cubit => context.read<PublisherPickerCubit>();

  bool _needRefresh = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cubit.onSelectPublishersChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return BlocBuilder<PublisherPickerCubit, PublisherPickerState>(
        builder: (context, state) {
          List<Widget> slivers = [];
          state.groups?.forEach((element) {
            slivers.add(SliverPersistentHeader(
              pinned: false,
              floating: false,
              delegate: SliverHeaderDelegate.fixedHeight(
                //固定高度
                height: 50,
                child: buildHeader(element.desc),
              ),
            ));
            slivers.addAll(element.publisherInfo.map((e) => publisherCard(e)));
          });
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  "选择喜欢的栏目",
                  style: TextStyle(fontSize: theme.navBarTitleFontSize),
                ),
              ),
              body: PopScope(
                  onPopInvoked: (bool didPop) {
                    //TODO: go router bug:https://github.com/flutter/flutter/issues/138737
                    if (_needRefresh) {
                      eventBus.fire(SelectedPublishersChanged());
                    }
                  },
                  child: SafeArea(
                    child: CustomScrollView(
                      slivers: slivers,
                    ),
                  )));
        });
  }

  // 构建 header
  Widget buildHeader(String title) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 1, color: theme.dividerColor))),
        child: Text(
          title,
          style: TextStyle(
              color: theme.publisherNameColor, fontSize: FontSize.mediumLarge),
        ),
      ),
    );
  }

  Widget publisherCard(Publisher publisher) {
    final theme = AppTheme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              publisher.icon,
              width: 44,
              height: 44,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      publisher.publisherName,
                      style: TextStyle(
                          fontSize: FontSize.medium,
                          fontWeight: FontWeight.bold,
                          color: theme.publisherNameColor),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    levelBadge(publisher.desc)
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  publisher.description,
                  style: TextStyle(
                      color: theme.publisherDescColor,
                      fontSize: FontSize.normal),
                ),
                const SizedBox(
                  height: 12,
                ),
                if (publisher.hasTag) tagsWall(publisher),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_right_sharp,
                      size: 18,
                      color: theme.publisherDescColor,
                    ),
                    Text(
                      publisher.subscribedCount.toShort(),
                      style: TextStyle(
                          fontSize: FontSize.small,
                          color: theme.publisherDescColor),
                    ),
                    const Spacer(),
                    removeOrAddButton(publisher)
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor,
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget levelBadge(String desc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
          color: desc == "中级" ? Colors.orangeAccent : Colors.black38,
          borderRadius: BorderRadius.circular(4)),
      child: Text(
        desc,
        style: const TextStyle(color: Colors.white, fontSize: FontSize.small),
      ),
    );
  }

  Widget tagsWall(Publisher publisher) {
    final tags = publisher.tags!;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tags
          .map((e) => ElevatedButton(
              onPressed: () {
                widget.onTapTag?.call(publisher.name,e.tagId);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(72, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.tagName,
                    style: const TextStyle(fontSize: FontSize.normal),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                  )
                ],
              )))
          .toList(),
    );
  }

  Widget removeOrAddButton(Publisher publisher) {
    final theme = AppTheme.of(context);
    return OutlinedButton(
      onPressed: () {
        _needRefresh = true;
        _cubit.onSelectPublisherChanged(publisher);
        //比较频繁
        eventBus.fire(SelectedPublishersChanged());
      },
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(1, 1),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          side: BorderSide(
            color: theme.publisherDescColor,
          )),
      child: Text(
        publisher.isBooked ? "退订" : "订阅",
        style: TextStyle(
            fontSize: FontSize.normal, color: theme.publisherNameColor),
      ),
    );
  }
}

extension NumberToShort on num {
  String toShort() {
    int precision = this % 10000 == 0 ? 0 : 2;
    String w = (this / 10000).toStringAsFixed(precision);
    return "$w万";
  }
}
