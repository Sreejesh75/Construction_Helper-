import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../auth/data/auth_api_service.dart';
import '../data/home_api_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  final HomeApiService api;
  final AuthApiService authApi;

  HomeBloc(this.api, this.authApi) : super(const HomeState()) {
    on<LoadProjects>(_loadProjects);
    on<CreateProject>(_createProject);
    on<UpdateProject>(_updateProject);
    on<DeleteProject>(_deleteProject);
    on<LoadProjectSummary>(_loadProjectSummary);
    on<UpdateUserName>(_updateUserName);
    on<LoadMaterials>(_loadMaterials);
    on<AddMaterial>(_addMaterial);
    on<UpdateMaterial>(_updateMaterial);
    on<DeleteMaterial>(_deleteMaterial);
    on<LogoutEvent>(_logout);
  }

  //Logout
  Future<void> _logout(LogoutEvent event, Emitter<HomeState> emit) async {
    try {
      await authApi.logout();
      emit(const HomeState(isLoggedOut: true));
    } catch (e) {
      emit(const HomeState(isLoggedOut: true));
    }
  }

  // existing methods

  // Load materials for a project
  Future<void> _loadMaterials(
    LoadMaterials event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingMaterials: true, error: null));

    try {
      final materials = await api.getMaterials(event.projectId);
      emit(state.copyWith(isLoadingMaterials: false, materials: materials));
    } catch (e) {
      emit(state.copyWith(isLoadingMaterials: false, error: e.toString()));
    }
  }

  /// Add material
  Future<void> _addMaterial(AddMaterial event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoadingMaterials: true, error: null));

    try {
      await api.addMaterial({
        "projectId": event.projectId,
        "name": event.name,
        "category": event.category,
        "quantity": event.quantity,
        "unit": event.unit,
        "price": event.price,
        "supplier": event.supplier,
        "date": event.date,
      });

      // Reload materials and summary
      add(LoadMaterials(event.projectId));
      add(LoadProjectSummary(event.projectId));
    } catch (e) {
      emit(state.copyWith(isLoadingMaterials: false, error: e.toString()));
    }
  }

  /// Update material
  Future<void> _updateMaterial(
    UpdateMaterial event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingMaterials: true, error: null));

    try {
      final remark = await api.updateMaterial(event.materialId, {
        "projectId": event.projectId,
        "name": event.name,
        "category": event.category,
        "quantity": event.quantity,
        "unit": event.unit,
        "price": event.price,
        "supplier": event.supplier,
        "date": event.date,
      });

      // Reload materials and summary, and emit remark
      add(LoadMaterials(event.projectId));
      add(LoadProjectSummary(event.projectId));

      emit(
        state.copyWith(
          isLoadingMaterials: false,
          updateMessage: remark, // Emit the remark
          // trigger a state change even if remark is same?
          // usually bloc listeners activate on state change.
          // If we want to show snackbar, we might need to reset it later or use a custom equatable config.
          // For now, assuming remark changes or is different enough.
          // A better pattern is to emit null after consuming, but let's see.
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMaterials: false, error: e.toString()));
    }
  }

  /// Delete material
  Future<void> _deleteMaterial(
    DeleteMaterial event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingMaterials: true, error: null));

    try {
      await api.deleteMaterial(event.materialId);

      // Reload materials and summary
      add(LoadMaterials(event.projectId));
      add(LoadProjectSummary(event.projectId));
    } catch (e) {
      emit(state.copyWith(isLoadingMaterials: false, error: e.toString()));
    }
  }

  Future<void> _loadProjects(
    LoadProjects event,
    Emitter<HomeState> emit,
  ) async {
    // Only update userName if it's a new user login or we don't have one yet
    final shouldUpdateName =
        state.userId != event.userId || state.userName == null;
    final currentUserName = shouldUpdateName ? event.userName : state.userName;

    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        userName: currentUserName,
        userId: event.userId,
        isLoggedOut: false,
      ),
    );

    try {
      final projects = await api.getProjects(event.userId);

      emit(state.copyWith(isLoading: false, projects: projects, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Create project and refresh list
  Future<void> _createProject(
    CreateProject event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await api.createProject(
        userId: event.userId,
        projectName: event.projectName,
        budget: event.budget,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final projects = await api.getProjects(event.userId);

      emit(state.copyWith(isLoading: false, projects: projects));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Update project and refresh list
  Future<void> _updateProject(
    UpdateProject event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await api.updateProject(
        projectId: event.projectId,
        projectName: event.projectName,
        budget: event.budget,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final projects = await api.getProjects(event.userId);

      emit(state.copyWith(isLoading: false, projects: projects));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Delete project and refresh list
  Future<void> _deleteProject(
    DeleteProject event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await api.deleteProject(event.projectId);

      final projects = await api.getProjects(event.userId);

      emit(state.copyWith(isLoading: false, projects: projects));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Load project summary
  Future<void> _loadProjectSummary(
    LoadProjectSummary event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final summary = await api.getProjectSummary(event.projectId);

      emit(
        state.copyWith(isLoading: false, projectSummary: summary, error: null),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Update user name
  Future<void> _updateUserName(
    UpdateUserName event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await authApi.updateUserName(userId: event.userId, name: event.name);

      emit(state.copyWith(isLoading: false, userName: event.name, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state.toJson();
  }
}
