import 'package:go_router/go_router.dart';

import 'package:fraseapp/ui/ui.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    StatefulShellRoute.indexedStack(

        builder: (context, state, navigationShell) {
          return HomeScreen(childView: navigationShell);
        },

        branches: [

          StatefulShellBranch(
            routes: <RouteBase>[

              GoRoute(
                path: '/',
                builder: (context, state) {
                  return const ExploreScreen();
                },
              )

            ]
          ),

          StatefulShellBranch(
            routes: <RouteBase>[

              GoRoute(
                path: '/favorites',
                builder: (context, state) {
                  return const FavoriteScreen();
                },
              )

            ]
          )

        ]
    )

  ]
);