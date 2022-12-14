import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feasibility/bloc/global_bloc.dart';
import 'package:flutter_feasibility/bloc/members_bloc.dart';
import 'package:flutter_feasibility/bloc/webrtc_service.dart';
import 'package:flutter_feasibility/io/socket_connection.dart';
import 'package:flutter_feasibility/ui/screens/room.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'example.dart';
import 'ui/screens/home.dart';
import 'ui/screens/login.dart';

const url = 'ws://localhost:3000';

void main() {
  Bloc.observer = MemberObserver();

  runExample();

  runApp(App());
}

class App extends StatelessWidget {
  final SocketConnection socketConnection = SocketConnectionImpl(url);
  late final GlobalBloc globalBloc;

  App({super.key}) {
    globalBloc = GlobalBloc(socketConnection);
  }

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<SocketConnection>.value(
          value: socketConnection,
          child: MultiBlocProvider(
              providers: [
                BlocProvider<GlobalBloc>.value(value: globalBloc),
                BlocProvider<MembersBloc>(
                  create: (_) => MembersBloc(socketConnection),
                ),
              ],
              child: MaterialApp.router(
                routeInformationProvider: _router.routeInformationProvider,
                routeInformationParser: _router.routeInformationParser,
                routerDelegate: _router.routerDelegate,
                title: 'doozoo WebRTC Demo',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
              )));

  late final GoRouter _router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) => HomeScreen(
            repository: socketConnection,
          ),
        ),
        GoRoute(
          path: '/room',
          builder: (BuildContext context, GoRouterState state) =>
              RoomScreen(repository: socketConnection),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) => LoginScreen(
            repository: socketConnection,
          ),
        ),
      ],

      // redirect to the login page if the user is not logged in
      redirect: (GoRouterState state) {
        // if the user is not logged in, they need to login
        final bool loggedIn =
            globalBloc.state.status == ConnectionStatus.connected;
        final bool loggingIn = state.subloc == '/login';

        if (!loggedIn) {
          return loggingIn ? null : '/login';
        }

        // is the user inside a room?
        if (globalBloc.state.roomId.isNotEmpty) {
          if (state.subloc != '/room') {
            return '/room';
          }
        } else {
          if (state.subloc == '/room') {
            return '/';
          }
        }

        // if the user is logged in but still on the login page, send them to
        // the home page
        if (loggingIn) {
          return '/';
        }

        // no need to redirect at all
        return null;
      },

      // changes on the listenable will cause the router to refresh it's route
      refreshListenable: GoRouterRefreshStream(
          globalBloc.stream //GoRouterRefreshStream(bloc.stream)
          ));
}
