import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class LoadNearbyCarsEvent extends HomeEvent {
  const LoadNearbyCarsEvent();
}

class LoadAllCarsEvent extends HomeEvent {
  final String? type;
  final String? transmission;
  final String? location;
  final String? search;
  final int page;
  final int limit;

  const LoadAllCarsEvent({
    this.type,
    this.transmission,
    this.location,
    this.search,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [type, transmission, location, search, page, limit];
}

class LoadUserCarsEvent extends HomeEvent {
  const LoadUserCarsEvent();
}

class PostCarEvent extends HomeEvent {
  final String title;
  final String model;
  final String year;
  final String price;
  final String description;
  final String type;
  final String transmission;
  final String fuel;
  final String condition;
  final String location;
  final String color;
  final String mileage;
  final List<String> images;
  final String listingType; // New: Rental or Sell
  final String rentalDuration; // New: Daily, Weekly, Monthly, Custom

  const PostCarEvent({
    required this.title,
    required this.model,
    required this.year,
    required this.price,
    required this.description,
    required this.type,
    required this.transmission,
    required this.fuel,
    required this.condition,
    required this.location,
    required this.color,
    required this.mileage,
    required this.images,
    required this.listingType,
    required this.rentalDuration,
  });

  @override
  List<Object?> get props => [title, model, year, price, description, type, transmission, fuel, condition, location, color, mileage, images, listingType, rentalDuration];
}

class UpdateCarEvent extends HomeEvent {
  final String carId;
  final Map<String, dynamic> carData;

  const UpdateCarEvent({
    required this.carId,
    required this.carData,
  });

  @override
  List<Object?> get props => [carId, carData];
}

class DeleteCarEvent extends HomeEvent {
  final String carId;

  const DeleteCarEvent(this.carId);

  @override
  List<Object?> get props => [carId];
}

class SearchCarsEvent extends HomeEvent {
  final String query;

  const SearchCarsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterCarsEvent extends HomeEvent {
  final String? city;
  final String? carType;
  final int? minPrice;
  final int? maxPrice;

  const FilterCarsEvent({
    this.city,
    this.carType,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [city, carType, minPrice, maxPrice];
}

class RefreshDataEvent extends HomeEvent {
  const RefreshDataEvent();
}
