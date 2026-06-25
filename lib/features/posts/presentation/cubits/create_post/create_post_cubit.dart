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
      ));
    }
  }

  /// Removes the selected image path from the state.
  void removeImage() {
    emit(const CreatePostInitial(imagePath: null));
  }

  /// Submits the post.
  Future<void> submitPost({
    required String content,
    required String creatorId,
    required UserProfile creator,
  }) async {
    if (content.trim().isEmpty) {
      emit(CreatePostError(
        message: 'لا يمكن مشاركة منشور فارغ',
        imagePath: state.imagePath,
      ));
      return;
    }

    emit(CreatePostLoading(imagePath: state.imagePath));

    try {
      final postId = const Uuid().v4();

      final postEntity = PostEntity(
        id: postId,
        creatorId: creatorId,
        creator: creator,
        content: content.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdPost = await createPostUseCase(
        post: postEntity,
        localImagePath: state.imagePath,
      );

      emit(CreatePostSuccess(post: createdPost, imagePath: state.imagePath));
    } catch (e) {
      emit(CreatePostError(
        message: 'فشل نشر المنشور: ${e.toString()}',
        imagePath: state.imagePath,
      ));
    }
  }
}
