import 'package:equatable/equatable.dart';

abstract class CreateEventState extends Equatable {
  final String? coverUrl;
  final String? localImagePath;

  const CreateEventState({this.coverUrl, this.localImagePath});

  @override
  List<Object?> get props => [coverUrl, localImagePath];
}

class CreateEventInitial extends CreateEventState {
  const CreateEventInitial({super.coverUrl, super.localImagePath});
}

class CreateEventUploadingImage extends CreateEventState {
  const CreateEventUploadingImage({super.coverUrl, super.localImagePath});
}

class CreateEventSavingData extends CreateEventState {
  const CreateEventSavingData({super.coverUrl, super.localImagePath});
}

class CreateEventSuccess extends CreateEventState {
  const CreateEventSuccess({super.coverUrl, super.localImagePath});
}

class CreateEventError extends CreateEventState {
  final String message;

  const CreateEventError({
    required this.message,
    super.coverUrl,
    super.localImagePath,
  });

  @override
  List<Object?> get props => [message, coverUrl, localImagePath];
}
