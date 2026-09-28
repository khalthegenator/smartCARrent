import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<LoadNearbyCarsEvent>(_onLoadNearbyCars);
    on<LoadAllCarsEvent>(_onLoadAllCars);
    on<LoadUserCarsEvent>(_onLoadUserCars);
    on<PostCarEvent>(_onPostCar);
    on<UpdateCarEvent>(_onUpdateCar);
    on<DeleteCarEvent>(_onDeleteCar);
    on<SearchCarsEvent>(_onSearchCars);
    on<FilterCarsEvent>(_onFilterCars);
    on<RefreshDataEvent>(_onRefreshData);
  }

  Future<void> _onLoadHomeData(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for demonstration
      final mockCars = [
        {
          'id': '1',
          'name': 'Toyota Corolla',
          'type': 'Sedan',
          'price': 50000,
          'image': 'assets/images/car1.jpg',
          'location': 'Dar es Salaam',
          'rating': 4.5,
          'seats': 5,
          'fuel': 'Petrol',
          'transmission': 'Automatic',
          'available': true,
        },
        {
          'id': '2',
          'name': 'Toyota Land Cruiser',
          'type': 'SUV',
          'price': 120000,
          'image': 'assets/images/car2.jpg',
          'location': 'Arusha',
          'rating': 4.8,
          'seats': 7,
          'fuel': 'Diesel',
          'transmission': 'Manual',
          'available': true,
        },
      ];
      
      emit(HomeLoaded(
        featuredCars: mockCars,
        currentLocation: 'Dar es Salaam',
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadNearbyCars(LoadNearbyCarsEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final nearbyCars = [
        {
          'id': '3',
          'name': 'Honda Civic',
          'type': 'Sedan',
          'price': 45000,
          'image': 'assets/images/car3.jpg',
          'location': 'Dar es Salaam',
          'rating': 4.3,
          'seats': 5,
          'fuel': 'Petrol',
          'transmission': 'Automatic',
          'available': true,
        },
      ];
      
      emit(NearbyCarsLoaded(
        nearbyCars: nearbyCars,
        currentLocation: 'Dar es Salaam',
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadAllCars(LoadAllCarsEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final cars = await AuthService.getAllCars(
        type: event.type,
        transmission: event.transmission,
        location: event.location,
        search: event.search,
        page: event.page,
        limit: event.limit,
      );
      
      emit(CarsLoaded(cars: cars));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserCars(LoadUserCarsEvent event, Emitter<HomeState> emit) async {
    print('HomeBloc: Loading user cars...');
    emit(const HomeLoading());
    try {
      final cars = await AuthService.getUserCars();
      print('HomeBloc: Got ${cars.length} cars, emitting UserCarsLoaded');
      emit(UserCarsLoaded(cars: cars));
    } catch (e) {
      print('HomeBloc: Error loading user cars: $e');
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onPostCar(PostCarEvent event, Emitter<HomeState> emit) async {
    print('🎯 HOMEBLOC DEBUG: Received PostCarEvent');
    print('🎯 HOMEBLOC DEBUG: Event data: ${event.toString()}');
    print('🎯 HOMEBLOC DEBUG: Title: ${event.title}');
    print('🎯 HOMEBLOC DEBUG: Price: ${event.price}');
    print('🎯 HOMEBLOC DEBUG: Listing Type: ${event.listingType}');
    print('🎯 HOMEBLOC DEBUG: Rental Duration: ${event.rentalDuration}');
    
    emit(const CarPosting());
    print('🎯 HOMEBLOC DEBUG: Emitted CarPosting state');
    
    try {
      print('🚀 HOMEBLOC DEBUG: About to call AuthService.postCar');
      final result = await AuthService.postCar(
        title: event.title,
        model: event.model,
        year: event.year,
        price: event.price,
        description: event.description,
        type: event.type,
        transmission: event.transmission,
        fuel: event.fuel,
        condition: event.condition,
        location: event.location,
        color: event.color,
        mileage: event.mileage,
        images: event.images,
        listingType: event.listingType,
        rentalDuration: event.rentalDuration, // Add rental duration
      );
      
      print('🎯 HOMEBLOC DEBUG: AuthService.postCar completed');
      print('🎯 HOMEBLOC DEBUG: Result: $result');
      
      // After successfully posting a car, load user's cars to refresh the list
      print('🎯 HOMEBLOC DEBUG: Loading user cars...');
      final userCars = await AuthService.getUserCars();
      print('🎯 HOMEBLOC DEBUG: User cars loaded: ${userCars.length}');
      emit(UserCarsLoaded(cars: userCars));
      print('🎯 HOMEBLOC DEBUG: Emitted UserCarsLoaded state');
      
      emit(CarPosted(car: result['car']));
      print('🎯 HOMEBLOC DEBUG: Emitted CarPosted state');
    } catch (e) {
      print('❌ HOMEBLOC DEBUG: Error occurred: $e');
      emit(HomeError(message: e.toString()));
      print('❌ HOMEBLOC DEBUG: Emitted HomeError state');
    }
  }

  Future<void> _onUpdateCar(UpdateCarEvent event, Emitter<HomeState> emit) async {
    print('HomeBloc: Updating car: ${event.carId}');
    emit(const CarUpdating());
    try {
      final result = await AuthService.updateCar(
        carId: event.carId,
        carData: event.carData,
      );
      
      print('HomeBloc: Car updated, reloading user cars...');
      
      // Reload user's cars after update
      final cars = await AuthService.getUserCars();
      emit(UserCarsLoaded(cars: cars));
      
      emit(CarUpdated(car: result['car']));
      print('HomeBloc: Update completed and cars reloaded');
    } catch (e) {
      print('HomeBloc: Update failed: $e');
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCar(DeleteCarEvent event, Emitter<HomeState> emit) async {
    print('HomeBloc: ===== DELETE START =====');
    print('HomeBloc: Deleting car: ${event.carId}');
    print('HomeBloc: DeleteEvent object: ${event.toString()}');
    emit(const CarDeleting());
    try {
      print('HomeBloc: About to call AuthService.deleteCar with ID: ${event.carId}');
      await AuthService.deleteCar(event.carId);
      print('HomeBloc: Car deleted, reloading user cars...');
      
      // Reload user's cars after deletion
      print('HomeBloc: About to reload user cars...');
      final cars = await AuthService.getUserCars();
      print('HomeBloc: Got ${cars.length} cars after deletion');
      
      emit(UserCarsLoaded(cars: cars));
      print('HomeBloc: Emitted UserCarsLoaded with ${cars.length} cars');
      
      emit(const CarDeleted());
      print('HomeBloc: ===== DELETE COMPLETED =====');
    } catch (e) {
      print('HomeBloc: Delete failed: $e');
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onSearchCars(SearchCarsEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final searchResults = [
        {
          'id': '4',
          'name': 'Nissan Sentra',
          'type': 'Sedan',
          'price': 40000,
          'image': 'assets/images/car4.jpg',
          'location': 'Dar es Salaam',
          'rating': 4.2,
          'seats': 5,
          'fuel': 'Petrol',
          'transmission': 'Automatic',
          'available': true,
        },
      ];
      
      emit(CarsSearched(searchResults: searchResults, searchQuery: event.query));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onFilterCars(FilterCarsEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final filteredCars = [
        {
          'id': '5',
          'name': 'Mitsubishi Lancer',
          'type': 'Sedan',
          'price': 55000,
          'image': 'assets/images/car5.jpg',
          'location': event.city ?? 'Dar es Salaam',
          'rating': 4.4,
          'seats': 5,
          'fuel': 'Petrol',
          'transmission': 'Manual',
          'available': true,
        },
      ];
      
      emit(CarsFiltered(filteredCars: filteredCars, filters: event));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshData(RefreshDataEvent event, Emitter<HomeState> emit) async {
    // Refresh current data based on current state
    if (state is CarsLoaded) {
      add(const LoadAllCarsEvent());
    } else if (state is UserCarsLoaded) {
      add(const LoadUserCarsEvent());
    } else {
      add(const LoadHomeDataEvent());
    }
  }
}
