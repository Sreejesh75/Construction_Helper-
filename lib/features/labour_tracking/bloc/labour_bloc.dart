import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/labour_api_service.dart';
import 'labour_event.dart';
import 'labour_state.dart';

class LabourBloc extends Bloc<LabourEvent, LabourState> {
  final LabourApiService _apiService;

  LabourBloc(this._apiService) : super(LabourInitial()) {
    on<LoadLabourRecords>(_onLoadLabourRecords);
    on<AddLabourRecord>(_onAddLabourRecord);
  }

  Future<void> _onLoadLabourRecords(
    LoadLabourRecords event,
    Emitter<LabourState> emit,
  ) async {
    emit(LabourLoading());
    try {
      final records = await _apiService.getLabourRecords(event.projectId);

      double totalContractPaid = 0;
      double totalContractEstimated =
          0; // This logic might need refinement based on business rules
      double totalDailyWage = 0;

      // Map to track unique contractors to avoid summing estimated amount multiple times if it's the same contract
      // However, the current model structure implies each record might be a payment for a specific contract or a new contract?
      // Based on typical "Contract Mode", we might just sum up what we have or just take the Paid Amount.
      // The requirement says: "For contractors: Aggregated paidAmount vs estimatedAmount."
      // I'll group by contractorName and take the MAX estimatedAmount found for that contractor?
      // Or simply sum them if they represent *different* contracts.
      // Let's assume for now we sum Paid, and for Estimated, we might need a more complex logic, but I'll stick to a simple sum for now
      // or maybe the user enters the Total Estimated Cost every time?
      // Safe bet: Sum `paidAmount`. For `estimatedAmount`, maybe just show the sum of estimates from all records (if each record is a new contract)
      // or if it's installments, the estimate shouldn't be summed.
      // For this implementation, I will sum `paidAmount` and `estimatedAmount` from the records,
      // but users should be aware if they duplicate estimates.

      // Better approach for display:
      // Group by Contractor.
      // For each contractor, take the *latest* estimatedAmount (or max).
      // Sum those up.

      Map<String, double> contractorEstimates = {};

      for (var record in records) {
        if (record.mode == 'contract' && record.contractDetails != null) {
          totalContractPaid += record.contractDetails!.paidAmount;

          String contractor = record.contractDetails!.contractorName;
          double estimate = record.contractDetails!.estimatedAmount;

          if (!contractorEstimates.containsKey(contractor) ||
              estimate > contractorEstimates[contractor]!) {
            contractorEstimates[contractor] = estimate;
          }
        } else if (record.mode == 'daily' &&
            record.dailyLabourDetails != null) {
          totalDailyWage += record.dailyLabourDetails!.totalAmount;
        }
      }

      totalContractEstimated = contractorEstimates.values.fold(
        0,
        (sum, val) => sum + val,
      );

      emit(
        LabourLoaded(
          records: records,
          totalContractPaid: totalContractPaid,
          totalContractEstimated: totalContractEstimated,
          totalDailyWage: totalDailyWage,
        ),
      );
    } catch (e) {
      emit(LabourError(e.toString()));
    }
  }

  Future<void> _onAddLabourRecord(
    AddLabourRecord event,
    Emitter<LabourState> emit,
  ) async {
    // Keep current state if possible or show loading
    // We want to show success message, then reload.
    // But emitting Loading might clear the list.
    // Let's emit Loading for now? Or just handle it.

    emit(LabourLoading());
    try {
      await _apiService.addLabourRecord(event.labour);
      emit(const LabourOperationSuccess("Labour record added successfully"));
      // Immediately reload
      add(LoadLabourRecords(event.labour.projectId));
    } catch (e) {
      emit(LabourError(e.toString()));
    }
  }
}
