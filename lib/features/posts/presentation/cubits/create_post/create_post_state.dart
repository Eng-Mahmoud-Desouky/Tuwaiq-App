import 'package:equatable/equatable.dart';
import '../../../domain/entities/post_entity.dart';

abstract class CreatePostState extends Equatable {
  final String? imagePath;

  const CreatePostState({this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class CreatePostInitial extends CreatePostState {
  const CreatePostInitial({super.imagePath});
}

class CreatePostLoading extends CreatePostState {
  const CreatePostLoading({super.imagePath});
}

class CreatePostSuccess extends CreatePostState {
  final PostEntity post;

  const CreatePostSuccess({required this.post, super.imagePath});

  @override
  List<Object?> get props => [post, imagePath];
}

class CreatePostError extends CreatePostState {
  final String message;

  const CreatePostError({required this.message, super.imagePath});

  @override
  List<Object?> get props => [message, imagePath];
}

class CreatePostImageSelected extends CreatePostState {
  const CreatePostImageSelected({required String super.imagePath});
}
