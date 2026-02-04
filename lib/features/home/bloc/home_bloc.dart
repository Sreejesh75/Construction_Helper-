import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/data/auth_api_service.dart';
import '../data/home_api_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
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

  /// Logout
  Future<void> _logout(LogoutEvent event, Emitter<HomeState> emit) async {
    try {
      await authApi.logout();
      emit(state.copyWith(isLoggedOut: true));
    } catch (e) {
      // Even if API fails, we likely want to allow logout on client side
      // or at least show error. For now, force logout.
      emit(state.copyWith(isLoggedOut: true));
    }
  }

  // ... existing methods

  /// Load materials for a project
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
      await api.updateMaterial(event.materialId, {
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
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        userName: event.userName,
        isLoggedOut:
            false, // Reset logout state when loading projects (i.e. logging in)
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
}
