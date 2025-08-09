// lib/models/wallet_model.dart

class Wallet {
  final double balance;
  final List<Transaction> transactions;

  Wallet({required this.balance, required this.transactions});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    var txList = json['transactions'] as List;
    List<Transaction> transactions = txList.map((i) => Transaction.fromJson(i)).toList();
    return Wallet(
      balance: (json['balance'] as num).toDouble(),
      transactions: transactions,
    );
  }
}

class Transaction {
  final String description;
  final double amount;
  final DateTime createdAt;
  final String type;

  Transaction({
    required this.description,
    required this.amount,
    required this.createdAt,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final utcTime = DateTime.parse(json['created_at']);
    return Transaction(
      description: json['description'] ?? 'No description',
      amount: (json['amount'] as num).toDouble(),
      createdAt: utcTime.toLocal(),
      type: json['type'] ?? 'credit',
    );
  }
}