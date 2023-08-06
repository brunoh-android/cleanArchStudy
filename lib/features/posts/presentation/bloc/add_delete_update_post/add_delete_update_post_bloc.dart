// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:clean_arch_full_course/core/strings/messages.dart';
import 'package:clean_arch_full_course/features/posts/domain/entities/post.dart';
import 'package:clean_arch_full_course/features/posts/domain/usecases/add_post.dart';
import 'package:clean_arch_full_course/features/posts/domain/usecases/delete_post.dart';
import 'package:clean_arch_full_course/features/posts/domain/usecases/update_post.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/strings/failures.dart';

part 'add_delete_update_post_event.dart';
part 'add_delete_update_post_state.dart';

class AddDeleteUpdatePostBloc extends Bloc<AddDeleteUpdatePostEvent, AddDeleteUpdatePostState> {
  final AddPostUsecase addPost;
  final DeletePostUsecase deletePost;
  final UpdatePostUsecase updatePost;

  AddDeleteUpdatePostBloc({
    required this.addPost,
    required this.deletePost,
    required this.updatePost,
  }) : super(AddDeleteUpdatePostInitial()) {
    on<AddDeleteUpdatePostEvent>(
      (event, emit) async {
        if (event is AddPostEvent) {
          emit(LoadingAddDeleteUpdatePostState());
          final failureOrDoneMessage = await addPost(event.post);

          emit(_eitherDoneMessageOrErrorState(failureOrDoneMessage, UPDATE_SUCCESS_MESSAGE));
        } else if (event is UpdatePostEvent) {
          emit(LoadingAddDeleteUpdatePostState());
          final failureOrDoneMessage = await updatePost(event.post);

          emit(_eitherDoneMessageOrErrorState(failureOrDoneMessage, UPDATE_SUCCESS_MESSAGE));
        } else if (event is DeletePostEvent) {
          emit(LoadingAddDeleteUpdatePostState());
          final failureOrDoneMessage = await deletePost(event.postId);

          emit(_eitherDoneMessageOrErrorState(failureOrDoneMessage, DELETE_SUCCESS_MESSAGE));
        }
      },
    );
  }

  AddDeleteUpdatePostState _eitherDoneMessageOrErrorState(Either<Failure, Unit> either, String message) {
    return either.fold(
      (failure) => ErrorAddDeleteUpdatePostState(
        message: _mapFailureToMessage(failure),
      ),
      (_) => MessageAddDeleteUpdatePostState(message: message),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case OffLineFailure:
        return OFFLINE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error, please try again later.';
    }
  }
}
