import 'package:construction_app/features/labour_tracking/bloc/labour_bloc.dart';
import 'package:construction_app/features/labour_tracking/bloc/labour_event.dart';
import 'package:construction_app/features/labour_tracking/bloc/labour_state.dart';
import 'package:construction_app/features/labour_tracking/data/labour_api_service.dart';
import 'package:construction_app/features/labour_tracking/data/labour_model.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLabourApiService extends LabourApiService {
  @override
  Future<List<Labour>> getLabourRecords(String projectId) async {
    return [
      Labour(
        id: '1',
        projectId: projectId,
        mode: 'daily',
        date: DateTime(2023, 10, 27),
        dailyLabourDetails: DailyLabourDetails(labourers: [], totalAmount: 100),
      ),
      Labour(
        id: '2',
        projectId: projectId,
        mode: 'daily',
        date: DateTime(2023, 10, 28),
        dailyLabourDetails: DailyLabourDetails(labourers: [], totalAmount: 200),
      ),
    ];
  }
}

void main() {
  test(
    'LabourBloc emits filtered records when FilterLabourByDate is added',
    () async {
      final apiService = FakeLabourApiService();
      final bloc = LabourBloc(apiService);

      final date1 = DateTime(2023, 10, 27);

      // Expectation workflow
      final expectedStates = [
        isA<LabourLoading>(),
        isA<LabourLoaded>()
            .having((s) => s.records.length, 'initial records', 2)
            .having((s) => s.filteredRecords.length, 'initial filtered', 2),
        isA<LabourLoaded>()
            .having((s) => s.records.length, 'records after filter', 2)
            .having((s) => s.filteredRecords.length, 'filtered', 1)
            .having((s) => s.selectedDate, 'selectedDate', date1),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadLabourRecords('p1'));
      // Allow microtask to complete for Load
      await Future.delayed(Duration.zero);
      bloc.add(FilterLabourByDate(date1));
    },
  );
}
