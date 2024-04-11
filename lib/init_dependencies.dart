import 'package:clean_architecture/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:clean_architecture/core/secrets/app_secrets.dart';
import 'package:clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_architecture/features/auth/domain/usecases/current_user.dart';
import 'package:clean_architecture/features/auth/domain/usecases/user_login.dart';
import 'package:clean_architecture/features/auth/domain/usecases/user_sign_up.dart';
import 'package:clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {

  _initAuth();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
    debug: true,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
            () => AuthRemoteDataSourceImpl(serviceLocator()))
    ..registerFactory<AuthRepository>(
            () => AuthRepositoryImpl(serviceLocator()))
    ..registerFactory(
            () => UserSignUp(serviceLocator()))
    ..registerFactory(
            () => UserLogin(serviceLocator()))
    ..registerFactory(
          () => CurrentUser(serviceLocator()))
    ..registerLazySingleton(
            () => AuthBloc(
                userSignUp: serviceLocator(),
                userLogin: serviceLocator(),
                currentUser: serviceLocator(),
                appUserCubit: serviceLocator()));
}