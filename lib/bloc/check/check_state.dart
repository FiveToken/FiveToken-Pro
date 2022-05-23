part of 'check_bloc.dart';

@immutable
class CheckState extends Equatable {
  final List<String> unSelectedList;
  final List<String> selectedList;
  CheckState({this.unSelectedList, this.selectedList});
  factory CheckState.idle() {
    return CheckState(unSelectedList: [], selectedList: []);
  }
  @override
  // TODO: implement props
  List<Object> get props => [unSelectedList, selectedList];

  CheckState copy(List<String> unSelectedList, List<String> selectedList) {
    return CheckState(
        unSelectedList: unSelectedList ?? this.unSelectedList,
        selectedList: selectedList ?? this.selectedList);
  }
}
