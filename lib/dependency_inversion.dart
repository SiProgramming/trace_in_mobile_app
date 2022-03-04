import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:trace_in_mobile_app/core/utils/api_urls.dart';
import 'package:trace_in_mobile_app/features/ping/data/repositories/ping_info_repository_impl.dart';
import 'package:trace_in_mobile_app/features/ping/domain/repositories/ping_info_repository_interface.dart';
import 'package:trace_in_mobile_app/features/ping/domain/usescases/get_ping_info_usescase.dart';

import 'features/ping/data/datasources/remote_data_sources/remote_ping_info_datasource_impl.dart';
import 'features/ping/data/datasources/remote_data_sources/remote_ping_info_datasource_interface.dart';
import 'features/theme/data/local_data_source/local_user_theme_datasource.dart';
import 'features/theme/data/local_data_source/local_user_theme_datasource_interface.dart';
import 'features/theme/domain/entities/user_theme.dart';
import 'features/theme/domain/usescases/change_user_theme_usescases.dart';
import 'features/theme/domain/usescases/get_user_theme_usescases.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  /// Register Hive Adapters
  Hive.registerAdapter<ThemeType>(ThemeTypeAdapter());
  Hive.registerAdapter<UserTheme>(UserThemeAdapter());

  /// Local user theme Dependency
  final _userThemeBox = await Hive.openBox<UserTheme>('user_theme_box');

  getIt.registerLazySingleton<ILocalUserThemeDatasource>(
      () => LocalUserThemeDatasourceImpl(_userThemeBox));

  getIt.registerLazySingleton<GetUserThemeUsecases>(
      () => GetUserThemeUsecases(getIt()));

  getIt.registerLazySingleton<ChangeUserThemeUsecases>(
      () => ChangeUserThemeUsecases(getIt()));

  /// Ping dependency
  getIt.registerLazySingleton<Client>(() => Client());
  getIt.registerLazySingleton<IApiUrls>(() => ApiUrlImpl());
  getIt.registerLazySingleton<IRemotePingInfoDatasource>(
      () => RemotePingInfoDatasourceImpl(getIt(), getIt()));
  getIt.registerLazySingleton<IPingInfoRepository>(
      () => PingInfoRepositoryImpl(remotePingInfoRepository: getIt()));

  /// Usecases
  getIt.registerLazySingleton<GetPingInfoUsescase>(
      () => GetPingInfoUsescase(getIt()));
}
