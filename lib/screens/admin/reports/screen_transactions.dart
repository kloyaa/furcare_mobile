import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with SingleTickerProviderStateMixin {
  // Animation controller for page transitions and loading effects
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables
  final String _accessToken = ""; // TODO: Implement secure token storage
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _transactions = [];

  // For web-specific filtering and sorting
  String? _sortColumn;
  bool _sortAscending = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Load transactions data when widget initializes
    _fetchTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches transaction data from the API and handles loading states
  Future<void> _fetchTransactions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Add a small delay for better UX with loading indicator (web-specific)
      await Future.delayed(const Duration(milliseconds: 300));

      AdminApi adminApi = AdminApi(_accessToken);
      Response<dynamic> response = await adminApi.getTransactions();

      if (mounted) {
        setState(() {
          _transactions = response.data?.toList() ?? [];
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              e is DioException
                  ? "Network error: ${e.message}"
                  : "Failed to load transactions: $e";
          _isLoading = false;
        });
      }
    }
  }

  /// Filter transactions based on search query
  List<dynamic> get _filteredTransactions {
    if (_searchQuery.isEmpty) return _transactions;

    return _transactions.where((transaction) {
      // Get nested values safely
      final Map<String, dynamic> customer = transaction['customer'] ?? {};
      final Map<String, dynamic> pet = transaction['pet'] ?? {};
      final Map<String, dynamic> staff = transaction['staff'] ?? {};
      final Map<String, dynamic> service = transaction['service'] ?? {};

      // Customer name
      final String customerName =
          '${_getNestedValue(customer, ['firstName']) ?? ''} ${_getNestedValue(customer, ['lastName']) ?? ''}'
              .trim()
              .toLowerCase();
      final String customerFullName =
          _getNestedValue(customer, ['fullName'])?.toLowerCase() ?? '';

      // Pet info
      final String petName =
          _getNestedValue(pet, ['name'])?.toLowerCase() ?? '';

      // Staff info
      final String staffName =
          '${_getNestedValue(staff, ['firstName']) ?? ''} ${_getNestedValue(staff, ['lastName']) ?? ''}'
              .trim()
              .toLowerCase();
      final String staffFullName =
          _getNestedValue(staff, ['fullName'])?.toLowerCase() ?? '';

      // Service info
      final String serviceTitle =
          _getNestedValue(service, ['title'])?.toLowerCase() ?? '';

      final String searchLower = _searchQuery.toLowerCase();

      return customerName.contains(searchLower) ||
          customerFullName.contains(searchLower) ||
          petName.contains(searchLower) ||
          staffName.contains(searchLower) ||
          staffFullName.contains(searchLower) ||
          serviceTitle.contains(searchLower);
    }).toList();
  }

  /// Safely extracts nested values from maps
  T? _getNestedValue<T>(Map<String, dynamic> map, List<String> keys) {
    dynamic current = map;
    for (String key in keys) {
      if (current is! Map<String, dynamic>) return null;
      if (!current.containsKey(key)) return null;
      current = current[key];
    }
    return current as T?;
  }

  /// Navigates to different screens based on the provided route
  void _navigateTo(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Builds the app bar with navigation menu - optimized for web
  PreferredSizeWidget _buildAppBar() {
    // Ensure the app bar has enough height for web navigation
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      toolbarHeight: 64, // Taller for web
      shadowColor: Colors.black.withOpacity(0.05),
      automaticallyImplyLeading: false,
      title: Container(
        constraints: BoxConstraints(
          // Constrain width for larger screens
          maxWidth: 1200,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo or branding could go here
            Text(
              "FurCare Admin",
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            // Navigation links
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavItem("Profile", "/a/profile"),
                const SizedBox(width: 25.0),
                _buildReportsMenu(),
                const SizedBox(width: 25.0),
                _buildNavItem("Staffs", "/a/management/staff"),
                const SizedBox(width: 25.0),
                _buildNavItem("Users and Pets", "/a/management/customers"),
                const SizedBox(width: 25.0),
                _buildNavItem("Sign out", "/"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a navigation menu item with hover effects - web optimized
  Widget _buildNavItem(String label, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _navigateTo(route),
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppColors.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 14.0, // Larger for web
              fontWeight:
                  route.contains('report/transactions')
                      ? FontWeight.bold
                      : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the reports dropdown menu - web optimized
  Widget _buildReportsMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      tooltip: "Click to view reports",
      color: Colors.white,
      elevation: 4,
      position: PopupMenuPosition.under,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reports",
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            _buildPopupMenuItem('check_ins', 'Check ins'),
            _buildPopupMenuItem('service_usages', 'Service usages'),
            _buildPopupMenuItem('transactions', 'Transactions', isActive: true),
          ],
      onSelected: (String value) {
        switch (value) {
          case 'check_ins':
            _navigateTo("/a/report/checkins");
            break;
          case 'service_usages':
            _navigateTo("/a/report/service-usage");
            break;
          case 'transactions':
            // Already on transactions page
            break;
          default:
            break;
        }
      },
    );
  }

  /// Creates a popup menu item with consistent styling
  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    String label, {
    bool isActive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (isActive)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: isActive ? AppColors.primary : Colors.black87,
              fontSize: 14.0,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main body content with loading, error, and data states
  Widget _buildBody() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 1200,
        ), // Constrain width for readability
        child: Column(
          children: [
            // Search and filter bar - web specific
            if (!_isLoading &&
                _errorMessage == null &&
                _transactions.isNotEmpty)
              _buildSearchBar(),

            // Main content area
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  /// Builds a search bar and filters for web
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _fetchTransactions,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the content area based on loading/error states
  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading transactions...',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (_errorMessage != null) {
      return Center(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Data',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_errorMessage',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _fetchTransactions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No transactions found',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TransactionTable(
            transactions: _filteredTransactions,
            onRefresh: _fetchTransactions,
          ),
        ),
      );
    }
  }
}

/// Separate widget for displaying transaction data in a table format - web optimized
class TransactionTable extends StatefulWidget {
  final List<dynamic> transactions;
  final VoidCallback onRefresh;

  const TransactionTable({
    required this.transactions,
    required this.onRefresh,
    super.key,
  });

  @override
  State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
  // Sorting state
  String? _sortColumnName;
  bool _sortAscending = true;

  // Pagination state - web specific
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header with title and metadata
          _buildTableHeader(),

          // Actual data table
          Expanded(child: SingleChildScrollView(child: _buildTable())),

          // Pagination controls - web specific
          _buildPaginationControls(),
        ],
      ),
    );
  }

  /// Builds the table header section with title and metadata
  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction History',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Showing ${_getDisplayedRowCount()} of ${widget.transactions.length} transactions',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the number of rows currently displayed based on pagination
  int _getDisplayedRowCount() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex =
        (startIndex + _rowsPerPage) > widget.transactions.length
            ? widget.transactions.length
            : startIndex + _rowsPerPage;

    return endIndex - startIndex;
  }

  /// Builds the data table with sorting capabilities
  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
        ),
        child: DataTable(
          border: TableBorder(
            horizontalInside: BorderSide(
              width: 0.5,
              color: Colors.grey.shade200,
            ),
            bottom: BorderSide(width: 0.5, color: Colors.grey.shade200),
          ),
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          dataRowMinHeight: 56, // Taller rows for web
          dataRowMaxHeight: 72,
          columnSpacing: 24,
          columns: _buildColumns(),
          rows: _getPaginatedRows(),
        ),
      ),
    );
  }

  /// Builds columns with sorting functionality
  List<DataColumn> _buildColumns() {
    final columns = [
      _buildSortableColumn('Staff', 'staff'),
      _buildSortableColumn('Customer', 'customer'),
      _buildSortableColumn('Address', 'address'),
      _buildSortableColumn('Contact', 'contact'),
      _buildSortableColumn('Pet', 'pet'),
      _buildSortableColumn('Species', 'species'),
      _buildSortableColumn('Service', 'service'),
      _buildSortableColumn('Fee', 'fee'),
      _buildSortableColumn('Date', 'date'),
    ];

    return columns;
  }

  /// Creates a sortable column with indicator
  DataColumn _buildSortableColumn(String label, String columnName) {
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14.0, // Larger for web
            ),
          ),
          if (_sortColumnName == columnName)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: AppColors.primary,
            ),
        ],
      ),
      onSort: (_, __) {
        setState(() {
          if (_sortColumnName == columnName) {
            _sortAscending = !_sortAscending;
          } else {
            _sortColumnName = columnName;
            _sortAscending = true;
          }
        });
      },
    );
  }

  /// Gets a paginated subset of rows
  List<DataRow> _getPaginatedRows() {
    // Get sorted transactions
    final sortedTransactions = _getSortedTransactions();

    // Apply pagination
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex =
        (startIndex + _rowsPerPage) > sortedTransactions.length
            ? sortedTransactions.length
            : startIndex + _rowsPerPage;

    if (startIndex >= sortedTransactions.length) {
      return [];
    }

    final paginatedData = sortedTransactions.sublist(startIndex, endIndex);
    return _buildRows(paginatedData);
  }

  /// Sorts transactions based on current sort column and direction
  List<dynamic> _getSortedTransactions() {
    if (_sortColumnName == null) {
      return widget.transactions;
    }

    List<dynamic> sortedList = List.from(widget.transactions);

    sortedList.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      // Extract values based on sort column
      switch (_sortColumnName) {
        case 'staff':
          final staffA = a['staff'] as Map<String, dynamic>? ?? {};
          final staffB = b['staff'] as Map<String, dynamic>? ?? {};

          valueA = _getStaffName(staffA);
          valueB = _getStaffName(staffB);
          break;

        case 'customer':
          final customerA = a['customer'] as Map<String, dynamic>? ?? {};
          final customerB = b['customer'] as Map<String, dynamic>? ?? {};

          valueA = _getCustomerName(customerA);
          valueB = _getCustomerName(customerB);
          break;

        case 'pet':
          final petA = a['pet'] as Map<String, dynamic>? ?? {};
          final petB = b['pet'] as Map<String, dynamic>? ?? {};

          valueA = _getNestedValue(petA, ['name']) ?? '';
          valueB = _getNestedValue(petB, ['name']) ?? '';
          break;

        case 'service':
          final serviceA = a['service'] as Map<String, dynamic>? ?? {};
          final serviceB = b['service'] as Map<String, dynamic>? ?? {};

          valueA = _getNestedValue(serviceA, ['title']) ?? '';
          valueB = _getNestedValue(serviceB, ['title']) ?? '';
          break;

        case 'fee':
          final serviceA = a['service'] as Map<String, dynamic>? ?? {};
          final serviceB = b['service'] as Map<String, dynamic>? ?? {};

          valueA = _getNestedValue(serviceA, ['fee']) ?? 0;
          valueB = _getNestedValue(serviceB, ['fee']) ?? 0;
          break;

        case 'date':
          valueA = a['date'] ?? '';
          valueB = b['date'] ?? '';
          break;

        default:
          valueA = '';
          valueB = '';
      }

      // Compare values
      int comparison;
      if (valueA is num && valueB is num) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = valueA.toString().compareTo(valueB.toString());
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedList;
  }

  /// Helper to get staff name from data
  String _getStaffName(Map<String, dynamic> staff) {
    final firstName = _getNestedValue(staff, ['firstName']) ?? '';
    final lastName = _getNestedValue(staff, ['lastName']) ?? '';
    final fullName = _getNestedValue(staff, ['fullName']) ?? '';

    if (fullName.isNotEmpty) {
      return fullName;
    } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return 'N/A';
  }

  /// Helper to get customer name from data
  String _getCustomerName(Map<String, dynamic> customer) {
    final firstName = _getNestedValue(customer, ['firstName']) ?? '';
    final lastName = _getNestedValue(customer, ['lastName']) ?? '';
    final fullName = _getNestedValue(customer, ['fullName']) ?? '';

    if (fullName.isNotEmpty) {
      return fullName;
    } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return 'N/A';
  }

  /// Safely extracts nested values from maps
  T? _getNestedValue<T>(Map<String, dynamic> map, List<String> keys) {
    dynamic current = map;
    for (String key in keys) {
      if (current is! Map<String, dynamic>) return null;
      if (!current.containsKey(key)) return null;
      current = current[key];
    }
    return current as T?;
  }

  /// Creates data rows from transaction data with proper null handling
  List<DataRow> _buildRows(List<dynamic> transactions) {
    return transactions.map<DataRow>((data) {
      // Handle potential null values with null-aware operators
      final staffMap = data['staff'] as Map<String, dynamic>? ?? {};
      final customerMap = data['customer'] as Map<String, dynamic>? ?? {};
      final petMap = data['pet'] as Map<String, dynamic>? ?? {};
      final serviceMap = data['service'] as Map<String, dynamic>? ?? {};

      // Extract customer info with null safety
      final customerName = _getCustomerName(customerMap);

      // Extract address with null safety
      final String address =
          _getNestedValue(customerMap, ['address', 'present']) ??
          _getNestedValue(customerMap, ['address']) as String? ??
          'N/A';

      // Extract contact info with null safety
      final String contact =
          _getNestedValue(customerMap, ['contact', 'number']) ?? 'N/A';

      // Extract pet info with null safety
      final String pet = _getNestedValue(petMap, ['name']) ?? 'N/A';
      final String species =
          _getNestedValue(petMap, ['specie']) ??
          _getNestedValue(petMap, ['breed']) ??
          'N/A';

      // Extract staff info with null safety
      final staffName = _getStaffName(staffMap);

      // Extract service info with null safety
      final String service = _getNestedValue(serviceMap, ['title']) ?? 'N/A';
      final int fee =
          (_getNestedValue(serviceMap, ['fee']) as num?)?.toInt() ?? 0;

      // Format date with null safety
      String formattedDate = 'N/A';
      try {
        final String? dateStr = data['date'] as String?;
        if (dateStr != null) {
          final DateTime date = DateTime.parse(dateStr);
          formattedDate = DateFormat('MMM d, h:mm a').format(date);
        }
      } catch (e) {
        formattedDate = 'Invalid Date';
      }

      return DataRow(
        cells: [
          _buildDataCell(staffName),
          _buildDataCell(customerName),
          _buildDataCell(address),
          _buildDataCell(contact),
          _buildDataCell(pet),
          _buildDataCell(species),
          _buildServiceDataCell(service),
          _buildFeeDataCell(fee),
          _buildDataCell(formattedDate),
        ],
      );
    }).toList();
  }

  /// Creates a styled data cell with consistent formatting
  DataCell _buildDataCell(String text) {
    return DataCell(
      Text(
        text,
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
          fontSize: 14.0, // Larger for web
        ),
      ),
    );
  }

  /// Creates a formatted fee data cell
  DataCell _buildFeeDataCell(int fee) {
    return DataCell(
      Text(
        '₱$fee.00',
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w600,
          color: fee > 0 ? Colors.green[700] : AppColors.primary,
          fontSize: 14.0,
        ),
      ),
    );
  }

  /// Creates a special data cell for service with icon
  DataCell _buildServiceDataCell(String service) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: _getServiceColor(service).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16), // Pill shape for web
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getServiceIcon(service),
              size: 16,
              color: _getServiceColor(service),
            ),
            const SizedBox(width: 8),
            Text(
              service.toUpperCase(),
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w700,
                color: _getServiceColor(service),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns an appropriate icon based on service type
  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'grooming':
        return Icons.content_cut;
      case 'boarding':
        return Icons.home;
      case 'checkup':
        return Icons.medical_services;
      case 'vaccination':
        return Icons.health_and_safety;
      case 'surgery':
        return Icons.local_hospital;
      case 'daycare':
        return Icons.pets;
      case 'training':
        return Icons.school;
      default:
        return Icons.pets;
    }
  }

  /// Returns an appropriate color based on service type
  Color _getServiceColor(String service) {
    switch (service.toLowerCase()) {
      case 'grooming':
        return Colors.blue;
      case 'boarding':
        return Colors.green;
      case 'checkup':
        return Colors.orange;
      case 'vaccination':
        return Colors.purple;
      case 'surgery':
        return Colors.red;
      case 'daycare':
        return Colors.teal;
      case 'training':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Builds pagination controls for web interface
  Widget _buildPaginationControls() {
    final int totalPages = (widget.transactions.length / _rowsPerPage).ceil();
    if (totalPages <= 1) {
      return const SizedBox(); // No pagination needed
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rows per page dropdown
          Row(
            children: [
              Text(
                'Rows per page:',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _rowsPerPage,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _rowsPerPage = newValue;
                      _currentPage = 0; // Reset to first page
                    });
                  }
                },
                items:
                    [5, 10, 20, 50, 100].map<DropdownMenuItem<int>>((
                      int value,
                    ) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
              ),
            ],
          ),

          // Page navigation
          Row(
            children: [
              Text(
                '${_currentPage + 1} of $totalPages',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              // First page button
              IconButton(
                onPressed:
                    _currentPage > 0
                        ? () => setState(() => _currentPage = 0)
                        : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'First Page',
                splashRadius: 20,
                color: AppColors.primary,
              ),
              // Previous page button
              IconButton(
                onPressed:
                    _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous Page',
                splashRadius: 20,
                color: AppColors.primary,
              ),
              // Next page button
              IconButton(
                onPressed:
                    _currentPage < totalPages - 1
                        ? () => setState(() => _currentPage++)
                        : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next Page',
                splashRadius: 20,
                color: AppColors.primary,
              ),
              // Last page button
              IconButton(
                onPressed:
                    _currentPage < totalPages - 1
                        ? () => setState(() => _currentPage = totalPages - 1)
                        : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Last Page',
                splashRadius: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget for adding export functionality (CSV, PDF)
class ExportButton extends StatelessWidget {
  final List<dynamic> data;

  const ExportButton({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 10),
      tooltip: "Export data",
      icon: const Icon(Icons.download, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'csv',
              child: Row(
                children: [
                  Icon(Icons.table_chart, size: 20),
                  SizedBox(width: 8),
                  Text('Export as CSV'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'pdf',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, size: 20),
                  SizedBox(width: 8),
                  Text('Export as PDF'),
                ],
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'csv':
            _exportToCSV();
            break;
          case 'pdf':
            _exportToPDF();
            break;
        }
      },
    );
  }

  /// Exports transaction data to CSV format
  void _exportToCSV() {
    // In a web app, this would generate CSV data and trigger a download
    // For demonstration, we're just showing the implementation structure

    // 1. Generate CSV content
    final StringBuffer csv = StringBuffer();

    // 2. Add header row
    csv.writeln('Staff,Customer,Address,Contact,Pet,Species,Service,Fee,Date');

    // 3. Add data rows
    for (final transaction in data) {
      // Extract and format data (similar to table cell extraction)
      // Add as CSV row
      // ...
    }

    // 4. In web, trigger download using html.AnchorElement
    // Implementation depends on Flutter Web specifics

    debugPrint('CSV export functionality would trigger download here');
  }

  /// Exports transaction data to PDF format
  void _exportToPDF() {
    // In a web app, this would generate PDF and trigger a download
    // For demonstration, we're just showing the implementation structure

    // 1. Generate PDF document
    // 2. Add formatted transaction data
    // 3. Trigger download

    debugPrint('PDF export functionality would trigger download here');
  }
}

/// Helper mixin for data table operations (could be expanded)
mixin TableOperations {
  /// Formats currency values consistently
  String formatCurrency(int amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  /// Formats dates consistently
  String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  /// Safe getter for nested map values
  T? getNestedValue<T>(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;

    dynamic current = map;
    for (String key in keys) {
      if (current is! Map<String, dynamic>) return null;
      if (!current.containsKey(key)) return null;
      current = current[key];
    }
    return current as T?;
  }
}
