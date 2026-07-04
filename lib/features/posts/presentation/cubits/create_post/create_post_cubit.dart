import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../profile/domain/entities/user_profile.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/create_post_usecase.dart';
import 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  final CreatePostUseCase createPostUseCase;
  final ImagePicker _picker = ImagePicker();

  CreatePostCubit({required this.createPostUseCase})
      : super(const CreatePostInitial());

  /// Selects an image from the gallery.
  /// Enforces client-side image compression directly during retrieval (quality: 50, width: 1080).
  Future<void> selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (image != null) {
        emit(CreatePostImageSelected(imagePath: image.path));
      }
    } catch (e) {
      emit(CreatePostError(
        message: 'حدث خطأ أثناء اختيار الصورة: ${e.toString()}',
        imagePath: state.imagePath,
        videoPath: state.videoPath,
      ));
    }
  }

  /// Selects a video from the gallery.
  /// Enforces client-side size validation (< 30MB).
  Future<void> selectVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        final file = File(video.path);
        final sizeBytes = await file.length();
        const maxSizeBytes = 30 * 1024 * 1024; // 30MB

        if (sizeBytes > maxSizeBytes) {
          emit(CreatePostError(
            message: 'حجم الفيديو يتجاوز الحد الأقصى المسموح به (30 ميجابايت)',
            imagePath: state.imagePath,
            videoPath: state.videoPath,
          ));
          return;
        }

        emit(CreatePostVideoSelected(videoPath: video.path));
      }
    } catch (e) {
      emit(CreatePostError(
        message: 'حدث خطأ أثناء اختيار الفيديو: ${e.toString()}',
        imagePath: state.imagePath,
        videoPath: state.videoPath,
      ));
    }
  }

  /// Removes the selected image path from the state.
  void removeImage() {
    emit(const CreatePostInitial(imagePath: null, videoPath: null));
  }

  /// Removes the selected video path from the state.
  void removeVideo() {
    emit(const CreatePostInitial(imagePath: null, videoPath: null));
  }

  /// Submits the post.
  Future<void> submitPost({
    required String content,
    required String creatorId,
    required UserProfile creator,
  }) async {
    final trimmedContent = content.trim();
    final hasImage = state.imagePath != null && state.imagePath!.isNotEmpty;
    final hasVideo = state.videoPath != null && state.videoPath!.isNotEmpty;

    if (trimmedContent.isEmpty && !hasImage && !hasVideo) {
      emit(CreatePostError(
        message: 'الرجاء كتابة نص أو إرفاق صورة/فيديو لنشر المنشور',
        imagePath: state.imagePath,
        videoPath: state.videoPath,
      ));
      return;
    }

    emit(CreatePostLoading(imagePath: state.imagePath, videoPath: state.videoPath));

    try {
      final postId = const Uuid().v4();

      final postEntity = PostEntity(
        id: postId,
        creatorId: creatorId,
        creator: creator,
        content: trimmedContent.isEmpty ? null : trimmedContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdPost = await createPostUseCase(
        post: postEntity,
        localImagePath: state.imagePath,
        localVideoPath: state.videoPath,
      );

      emit(CreatePostSuccess(
        post: createdPost,
        imagePath: state.imagePath,
        videoPath: state.videoPath,
      ));
    } catch (e) {
      emit(CreatePostError(
        message: 'فشل نشر المنشور: ${e.toString()}',
        imagePath: state.imagePath,
        videoPath: state.videoPath,
      ));
    }
  }
}
