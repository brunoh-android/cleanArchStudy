import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/post.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getAllPosts();
  Future<Unit> addPost(Post post);
  Future<Unit> deletePost(int id);
  Future<Unit> updatePost(PostModel postModel);
}

// ignore: constant_identifier_names
const BASE_URL = 'https://jsonplaceholder.typicode.com';

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final http.Client client;

  PostRemoteDataSourceImpl({required this.client});
  @override
  Future<List<PostModel>> getAllPosts() async {
    final response =
        await client.get(Uri.parse('$BASE_URL/posts/'), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List decodeJson = jsonDecode(response.body) as List;
      final List<PostModel> postsModels =
          decodeJson.map<PostModel>((jsonPostModel) => PostModel.fromJson(jsonPostModel)).toList();

      return postsModels;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Unit> addPost(Post post) async {
    final body = {
      'title': post.title,
      'body': post.body,
    };

    final response = await client.post(Uri.parse('$BASE_URL/posts/'), body: body);

    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Unit> deletePost(int id) async {
    final response =
        await client.delete(Uri.parse('$BASE_URL/posts/$id'), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Unit> updatePost(PostModel postModel) async {
    final postId = postModel.id.toString();
    final body = {
      'title': postModel.title,
      'body': postModel.body,
    };

    final response = await client.patch(Uri.parse('$BASE_URL/posts/$postId'), body: body);

    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }
}
