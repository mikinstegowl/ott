extension DurationExtension on int {
  String toMovieDuration() {
    final hours = this ~/ 60;
    final minutes = this % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }
}