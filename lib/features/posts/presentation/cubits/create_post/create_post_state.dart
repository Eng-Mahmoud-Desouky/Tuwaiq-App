import 'package:equatable/equatable.dart';
import '../../../domain/entities/post_entity.dart';

abstract class CreatePostState extends Equatable {
  final String? imagePath;
  final String? videoPath;

  const CreatePostState({this.imagePath, this.videoPath});

  @override
  List<Object?> get props => [imagePath, videoPath];
}

class CreatePostInitial extends CreatePostState {
  const CreatePostInitial({super.imagePath, super.videoPath});
}

class CreatePostLoading extends CreatePostState {
  const CreatePostLoading({super.imagePath, super.videoPath});
}

class CreatePostSuccess extends CreatePostState {
  final PostEntity post;

  const CreatePostSuccess({required this.post, super.imagePath, super.videoPath});

  @override
  List<Object?> get props => [post, imagePath, videoPath];
}

class CreatePostError extends CreatePostState {
  final String message;

  const CreatePostError({required this.message, super.imagePath, super.videoPath});

  @override
  List<Object?> get props => [message, imagePath, videoPath];
}

class CreatePostImageSelected extends CreatePostState {
  const CreatePostImageSelected({required String super.imagePath}) : super(videoPath: null);
}

class CreatePostVideoSelected extends CreatePostState {
  const CreatePostVideoSelected({required String super.videoPath}) : super(imagePath: null);
}
