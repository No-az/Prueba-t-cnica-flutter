import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.server({required int statusCode, required String message}) = ServerFailure;
  const factory Failure.notFound({required String message}) = NotFoundFailure;
  const factory Failure.timeout({required String message}) = TimeoutFailure;
  const factory Failure.cache({required String message}) = CacheFailure;
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
