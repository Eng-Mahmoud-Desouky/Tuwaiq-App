import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubits/post_comments/post_comments_cubit.dart';
import '../cubits/post_comments/post_comments_state.dart';
import '../cubits/post_feed/post_feed_cubit.dart';
import '../widgets/comment_card.dart';
import '../widgets/post_card.dart';

class PostDetailsScreen extends StatefulWidget {
  final String eventId; // Using dynamic ID from path matching
  final PostEntity? initialPost;

  const PostDetailsScreen({
    super.key,
    required this.eventId,
    this.initialPost,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    // Load comments on open
    context.read<PostCommentsCubit>().loadComments(widget.eventId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    if (content.length > _maxChars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التعليق يتجاوز الحد الأقصى للحروف (500)')),
      );
      return;
    }

    context.read<PostCommentsCubit>().addComment(
          postId: widget.eventId,
          content: content,
        );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showDeleteCommentDialog(CommentEntity comment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التعليق', textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا التعليق؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<PostCommentsCubit>().deleteComment(comment.id);
              context.read<PostFeedCubit>().onCommentDeleted(widget.eventId);
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(CommentEntity comment) {
    final editController = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل التعليق', textAlign: TextAlign.right),
        content: TextField(
          controller: editController,
          maxLength: _maxChars,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'اكتب تعديلك...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty) {
                context.read<PostCommentsCubit>().updateComment(
                      commentId: comment.id,
                      content: newContent,
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';

    // If initialPost is not passed via GoRouter extra, we can show a loader or simple back navigation
    final post = widget.initialPost;
    if (post == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنشور', style: AppTextStyles.titleSm),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: const Center(child: Text('المنشور غير موجود')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_without_name.png',
          height: 42,
          fit: BoxFit.contain,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Feed Body (Post details card + comments list)
          Expanded(
            child: BlocListener<PostCommentsCubit, PostCommentsState>(
              listener: (context, state) {
                if (state is PostCommentSubmitSuccess) {
                  // Clear input controller
                  _commentController.clear();
                  
                  // Increment comment count in parent feed cubit
                  context.read<PostFeedCubit>().onCommentAdded(widget.eventId);
                  
                  // Scroll to bottom to show new comment
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                } else if (state is PostCommentsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: BlocBuilder<PostCommentsCubit, PostCommentsState>(
                builder: (context, state) {
                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Full Post Card
                      PostCard(post: post),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'التعليقات',
                          style: AppTextStyles.titleSm,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      
                      const Divider(height: 1, color: AppColors.secondaryContainer),
                      const SizedBox(height: 8),

                      // Comments List Loader State
                      if (state is PostCommentsLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (state is PostCommentsError &&
                          (state is! PostCommentsLoaded))
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'حدث خطأ أثناء تحميل التعليقات',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.error),
                            ),
                          ),
                        )
                      else ...[
                        // Resolve the comments list based on states
                        Builder(
                          builder: (context) {
                            List<dynamic> comments = [];
                            if (state is PostCommentsLoaded) {
                              comments = state.comments;
                            } else if (state is PostCommentSubmitting) {
                              comments = state.comments;
                            } else if (state is PostCommentSubmitSuccess) {
                              comments = state.comments;
                            }

                            if (comments.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    'لا توجد تعليقات بعد. كن أول من يعلق!',
                                    style: AppTextStyles.labelLg.copyWith(color: AppColors.secondary),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentCard(
                                  comment: comment,
                                  currentUserId: currentUserId,
                                  onDelete: () => _showDeleteCommentDialog(comment),
                                  onEdit: () => _showEditCommentDialog(comment),
                                );
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ),
          
          // Comment Text Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.outline,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Submit Button
                BlocBuilder<PostCommentsCubit, PostCommentsState>(
                  builder: (context, state) {
                    final isSubmitting = state is PostCommentSubmitting;
                    return isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: AppColors.primary),
                            onPressed: _handleSubmit,
                          );
                  },
                ),
                // Text Field Input (RTL aligned, max 500 characters)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _commentController,
                      maxLength: _maxChars,
                      style: AppTextStyles.bodyMd.copyWith(fontSize: 14),
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      decoration: const InputDecoration(
                        hintText: 'اكتب تعليقاً...',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
