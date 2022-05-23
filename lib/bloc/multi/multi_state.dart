part of 'multi_bloc.dart';

class MultiState extends Equatable {
  final String balance;
  final String mid;
  final int selectType;
  final List<CacheMultiMessage> messageList;
  final bool enablePullUp;
  MultiState(
      {this.balance,
      this.mid,
      this.selectType,
      this.messageList,
      this.enablePullUp});

  @override
  // TODO: implement props
  List<Object> get props => [
        this.balance,
        this.mid,
        this.selectType,
        this.messageList,
        this.enablePullUp
      ];

  factory MultiState.idle() {
    return MultiState(
      balance: '0',
      mid: '',
      selectType: MultiTabs.proposal,
      messageList: [],
      enablePullUp: true,
    );
  }

  MultiState copyWithMultiState({
    String balance,
    String mid,
    int selectType,
    List<CacheMultiMessage> messageList,
    bool enablePullUp,
  }) {
    print('er');
    return MultiState(
        balance: balance ?? this.balance,
        mid: mid ?? this.mid,
        selectType: selectType ?? this.selectType,
        messageList: messageList ?? this.messageList,
        enablePullUp: enablePullUp ?? this.enablePullUp);
  }
}
