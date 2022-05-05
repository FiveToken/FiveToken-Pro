part of 'create_bloc.dart';

@immutable
class CreateState extends Equatable {
  final List<TextEditingController> signers;
  CreateState({this.signers});
  factory CreateState.idle() {
    return CreateState(
      signers: [],
    );
  }
  @override
  // TODO: implement props
  List<Object> get props => [signers];

  CreateState copy(
    List<TextEditingController> signers,
  ) {
    return CreateState(
      signers: signers ?? this.signers,
    );
  }
}
