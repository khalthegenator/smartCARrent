import 'package:equatable/equatable.dart';
import 'home_event.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Map<String, dynamic>> featuredCars;
  final String currentLocation;

  const HomeLoaded({
    required this.featuredCars,
    required this.currentLocation,
  });

  @override
  List<Object?> get props => [featuredCars, currentLocation];
}

class NearbyCarsLoaded extends HomeState {
  final List<Map<String, dynamic>> nearbyCars;
  final String currentLocation;

  const NearbyCarsLoaded({
    required this.nearbyCars,
    required this.currentLocation,
  });

  @override
  List<Object?> get props => [nearbyCars, currentLocation];
}

class CarsLoaded extends HomeState {
  final List<Map<String, dynamic>> cars;

  const CarsLoaded({required this.cars});

  @override
  List<Object?> get props => [cars];
}

class UserCarsLoaded extends HomeState {
  final List<Map<String, dynamic>> cars;

  const UserCarsLoaded({required this.cars});

  @override
  List<Object?> get props => [cars];
}

class CarPosting extends HomeState {
  const CarPosting();
}

class CarPosted extends HomeState {
  final Map<String, dynamic> car;

  const CarPosted({required this.car});

  @override
  List<Object?> get props => [car];
}

class CarUpdating extends HomeState {
  const CarUpdating();
}

class CarUpdated extends HomeState {
  final Map<String, dynamic> car;

  const CarUpdated({required this.car});

  @override
  List<Object?> get props => [car];
}

class CarDeleting extends HomeState {
  const CarDeleting();
}

class CarDeleted extends HomeState {
  const CarDeleted();
}

class CarsSearched extends HomeState {
  final List<Map<String, dynamic>> searchResults;
  final String searchQuery;

  const CarsSearched({
    required this.searchResults,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [searchResults, searchQuery];
}

class CarsFiltered extends HomeState {
  final List<Map<String, dynamic>> filteredCars;
  final FilterCarsEvent filters;

  const CarsFiltered({
    required this.filteredCars,
    required this.filters,
  });

  @override
  List<Object?> get props => [filteredCars, filters];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
