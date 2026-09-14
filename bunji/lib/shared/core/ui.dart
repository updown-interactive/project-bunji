

import 'package:bunji/app/routes.dart';
import 'package:equatable/equatable.dart';

abstract class UiAction extends Equatable {
  const UiAction();

  @override
  List<Object?> get props => [];
}

class ShowError extends UiAction {
  final String message;
  const ShowError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShowSuccess extends UiAction {
  final String message;
  const ShowSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NavigateTo extends UiAction {
  final Routes route;
  final Object? args;
  final bool replace;

  const NavigateTo(this.route, {this.args, this.replace = true});

  @override
  List<Object?> get props => [route, args, replace];
}

class PopPage extends UiAction {
  final bool? value;
  const PopPage({this.value});
}

class UI extends Equatable {
  final bool isLoading;
  final UiAction? action;

  const UI({this.isLoading = false, this.action});

  UI copyWith({bool? isLoading, UiAction? action}) {
    return UI(isLoading: isLoading ?? this.isLoading, action: action);
  }

  @override
  List<Object?> get props => [isLoading, action];
}

extension UIHelpers on UI {
  /// -----------------------------
  /// Loading
  /// -----------------------------

  UI startLoading() {
    return copyWith(isLoading: true);
  }

  UI stopLoading() {
    return copyWith(isLoading: false);
  }

  /// -----------------------------
  /// Messages
  /// -----------------------------

  UI showError(String message) {
    return copyWith(isLoading: false, action: ShowError(message));
  }

  UI showSuccess(String message) {
    return copyWith(action: ShowSuccess(message));
  }

  /// -----------------------------
  /// Navigation
  /// -----------------------------

  UI navigateTo(Routes route, {Object? args, bool replace = true}) {
    return copyWith(
      action: NavigateTo(route, args: args, replace: replace),
    );
  }

  UI navigateReplacementTo(Routes route, {Object? args}) {
    return copyWith(action: NavigateTo(route, args: args, replace: true));
  }

  UI pop() {
    return copyWith(action: const PopPage());
  }

  UI popWithValue(bool value) {
    return copyWith(action: PopPage(value: value));
  }

  /// -----------------------------
  /// Housekeeping
  /// -----------------------------

  UI clearAction() {
    return copyWith();
  }

  bool get hasAction => action != null;
}
