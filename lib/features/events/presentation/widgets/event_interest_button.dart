import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/extensions/context_extensions.dart';

class EventInterestButton extends StatefulWidget {
  final String eventId;
  final String creatorId;

  const EventInterestButton({
    super.key,
    required this.eventId,
    required this.creatorId,
  });

  @override
  State<EventInterestButton> createState() => _EventInterestButtonState();
}

class _EventInterestButtonState extends State<EventInterestButton> {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('saved_events')
          .select()
          .eq('user_id', user.id)
          .eq('event_id', widget.eventId)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _isSaved = response != null;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleSave() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      context.showSnackBar(
        'يرجى تسجيل الدخول أولاً للتفاعل مع الفعاليات',
        isError: true,
      );
      return;
    }

    if (widget.creatorId == user.id) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSaved) {
        await Supabase.instance.client
            .from('saved_events')
            .delete()
            .eq('user_id', user.id)
            .eq('event_id', widget.eventId);
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
        }
      } else {
        await Supabase.instance.client.from('saved_events').insert({
          'user_id': user.id,
          'event_id': widget.eventId,
        });
        if (mounted) {
          setState(() {
            _isSaved = true;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        context.showSnackBar(
          'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    // Don't show the interest button for the event creator
    if (user != null && widget.creatorId == user.id) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _toggleSave,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
                size: 20,
              ),
      ),
    );
  }
}
