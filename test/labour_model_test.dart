import 'package:construction_app/features/labour_tracking/data/labour_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Labour model parses null numeric values correctly', () {
    final Map<String, dynamic> json = {
      '_id': '123',
      'projectId': 'proj1',
      'mode': 'Contract',
      'date': '2023-10-27T10:00:00.000Z',
      'contractDetails': {
        'contractorName': null,
        'estimatedAmount': null,
        'paidAmount': null,
      },
      'dailyLabourDetails': {
        'labourers': [
          {'name': null, 'wage': null},
        ],
        'totalAmount': null,
      },
    };

    try {
      final labour = Labour.fromJson(json);
      expect(labour.id, '123');
      expect(labour.contractDetails?.estimatedAmount, 0.0);
      expect(labour.contractDetails?.paidAmount, 0.0);
      expect(labour.contractDetails?.contractorName, '');
      expect(labour.dailyLabourDetails?.totalAmount, 0.0);
      expect(labour.dailyLabourDetails?.labourers.first.wage, 0.0);
      expect(labour.dailyLabourDetails?.labourers.first.name, '');
      print('Labour model parsing test passed!');
    } catch (e) {
      fail('Labour model parsing failed: $e');
    }
  });
}
