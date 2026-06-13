class JitsiMeetState {
  final bool isLoading;
  final String? roomId;
  final String? error;

  const JitsiMeetState({this.isLoading = false, this.roomId, this.error});

  JitsiMeetState copyWith({bool? isLoading, String? roomId, String? error}) {
    return JitsiMeetState(
      isLoading: isLoading ?? this.isLoading,
      roomId: roomId ?? this.roomId,
      error: error,
    );
  }
}
