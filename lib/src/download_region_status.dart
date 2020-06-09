part of mapbox_gl;

abstract class DownloadRegionStatus {}

class Success extends DownloadRegionStatus {}

class InProgress extends DownloadRegionStatus {
  final double progress;

  InProgress(this.progress);

  @override
  String toString() =>
      "Instance of 'DownloadRegionStatus.InProgress', progress = $progress";
}

class Error extends DownloadRegionStatus {
  final PlatformException cause;

  Error(this.cause);

  @override
  String toString() =>
      "Instance of 'DownloadRegionStatus.Error', cause = ${cause.toString()}";
}
