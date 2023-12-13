import 'package:feed_detail/feed_detail.dart';
import 'package:feed_list/feed_list.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/tab_container_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:publisher_picker/publisher_picker.dart';
import 'package:user_profile/user_profile.dart';
import 'package:user_repository/user_repository.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter router(FeedRepository feedRepository, UserRepository userRepository) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/audios',
    debugLogDiagnostics: true,
    onException: (_, GoRouterState state, GoRouter router) {
      //router.go('/a', extra: state.uri.toString());
    },
    routes: <RouteBase>[
      /// Application shell
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          // Return the widget that implements the custom shell (in this case
          // using a BottomNavigationBar). The StatefulNavigationShell is passed
          // to be able access the state of the shell and to navigate to other
          // branches in a stateful way.
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/audios',
                  builder: (BuildContext context, GoRouterState state) {
                    return FeedListScreen(
                      feedRepository: feedRepository,
                      onFeedSelected: (String feedId) {
                        context.go(Uri(
                            path: '/audios/details',
                            queryParameters: {
                              'id': feedId
                            }).toString());
                      },
                      onPickerTapped: () {
                        context.go("/audios/publishers");
                      },
                    );
                  },
                  routes: <RouteBase>[
                    // The details screen to display stacked on the inner Navigator.
                    // This will cover screen A but not the application shell.
                    GoRoute(
                      path: 'details',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (BuildContext context, GoRouterState state) {
                        String feedId = state.uri.queryParameters["id"]!;
                        return FeedDetailsScreen(
                          feedId: feedId,
                          feedRepository: feedRepository,
                        );
                      },
                    ),
                    GoRoute(
                        path: 'publishers',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (BuildContext context, GoRouterState state) {
                          return PublisherPickerScreen(
                            feedRepository: feedRepository,
                            onTapTag: (publisher, tag) {
                              context.go(Uri(
                                  path: '/audios/publishers/publisher',
                                  queryParameters: {
                                    'publisher': publisher,
                                    'tag': tag
                                  }).toString());
                            },
                          );
                        },
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'publisher',
                            parentNavigatorKey: _rootNavigatorKey,
                            builder:
                                (BuildContext context, GoRouterState state) {
                              String publisher =
                                  state.uri.queryParameters["publisher"]!;
                              String? tag = state.uri.queryParameters["tag"];

                              return PublisherFeedListScreen(
                                isRoute: true,
                                publisher: publisher,
                                tag: tag,
                                feedRepository: feedRepository,
                                onFeedSelected: (String feedId) {
                                  context.push(Uri(
                                      path: '/audios/details',
                                      queryParameters: {
                                        'id': feedId
                                      }).toString());
                                },
                              );
                            },
                          )
                        ]),
                  ],
                ),
              ]),
          StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/videos',
                  builder: (BuildContext context, GoRouterState state) {
                    return FeedListScreen(
                      isVideoFeed: true,
                      feedRepository: feedRepository,
                      onFeedSelected: (String feedId) {
                        context.go(Uri(
                            path: '/videos/details',
                            queryParameters: {
                              'id': feedId
                            }).toString());
                      },
                    );
                  },
                  routes: <RouteBase>[
                    /// Same as "/a/details", but displayed on the root Navigator by
                    /// specifying [parentNavigatorKey]. This will cover both screen B
                    /// and the application shell.
                    GoRoute(
                      path: 'details',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (BuildContext context, GoRouterState state) {
                        String feedId = state.uri.queryParameters["id"]!;
                        return FeedDetailsScreen(
                          feedId: feedId,
                          feedRepository: feedRepository,
                        );
                      },
                    ),
                  ],
                ),
              ]),
          StatefulShellBranch(
              //navigatorKey: _shellNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                  path: '/mine',
                  builder: (BuildContext context, GoRouterState state) {
                    return ProfileMenuScreen(
                      userRepository: userRepository,
                    );
                  },
                ),
              ]),
        ],
      ),
    ],
  );
  return router;
}
