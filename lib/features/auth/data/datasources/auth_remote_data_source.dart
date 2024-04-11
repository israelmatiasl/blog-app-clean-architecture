import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentSession;

  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password
  });

  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password
  });

  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
          email: email,
          password: password
      );
      if (response.user == null) {
        throw ServerException('User is null!');
      }
      return UserModel.fromJson(response.user!.toJson());
    }
    catch(e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
          email: email,
          password: password,
          data: {
            'name': name,
          }
      );
      if (response.user == null) {
        throw ServerException('User is null!');
      }
      return UserModel.fromJson(response.user!.toJson());
    }
    catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try{
      if(currentSession == null) {
        return null;
      }
      final userData = await supabaseClient.from('profiles')
          .select().eq('id', currentSession!.user.id);
      return UserModel.fromJson(userData.first).copyWith(
        email: currentSession!.user.email
      );
    }
    catch (e) {
      throw ServerException(e.toString());
    }
  }
}