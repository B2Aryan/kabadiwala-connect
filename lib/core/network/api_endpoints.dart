/// Centralized API endpoint constants for Kabadiwala Connect
class ApiEndpoints {
  static const String defaultBaseUrl = 'http://localhost:5000/api';

  // Health
  static const String health = '/health';

  // Recyclers
  static const String recyclers = '/recyclers';
  static String recyclerById(String id) => '/recyclers/$id';

  // Lots
  static const String lots = '/lots';
  static String lotById(String id) => '/lots/$id';

  // Handover Requests
  static const String handoverRequests = '/handover-requests';
  static String handoverRequestById(String id) => '/handover-requests/$id';

  // Transactions
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';

  // Earnings
  static const String earningsSummary = '/earnings/summary';
}
