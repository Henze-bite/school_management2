class Fee {
  final String id;
  final String studentId;
  final String classId;
  final double amount;
  final String feeType; // tuition, library, sports, etc.
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status; // pending, paid, overdue
  final String? paymentMethod;
  final String? receiptNumber;

  Fee({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.amount,
    required this.feeType,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentMethod,
    this.receiptNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'amount': amount,
      'feeType': feeType,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'receiptNumber': receiptNumber,
    };
  }

  factory Fee.fromMap(Map<String, dynamic> map) {
    return Fee(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      classId: map['classId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      feeType: map['feeType'] ?? '',
      dueDate: DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      paidDate: map['paidDate'] != null
          ? DateTime.parse(map['paidDate'])
          : null,
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'],
      receiptNumber: map['receiptNumber'],
    );
  }

  Fee copyWith({
    String? id,
    String? studentId,
    String? classId,
    double? amount,
    String? feeType,
    DateTime? dueDate,
    DateTime? paidDate,
    String? status,
    String? paymentMethod,
    String? receiptNumber,
  }) {
    return Fee(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      amount: amount ?? this.amount,
      feeType: feeType ?? this.feeType,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptNumber: receiptNumber ?? this.receiptNumber,
    );
  }
}

