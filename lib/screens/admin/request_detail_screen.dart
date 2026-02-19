import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ambulance_request.dart';
import '../../services/admin_service.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen>
    with TickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final TextEditingController _driverController = TextEditingController();
  final TextEditingController _ambulanceController = TextEditingController();
  bool _isUpdating = false;
  late AnimationController _statusAnimController;
  late Animation<double> _statusAnimation;

  final List<String> _allStatuses = [
    'requested',
    'on_the_way',
    'arrived',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _statusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _statusAnimation = CurvedAnimation(
      parent: _statusAnimController,
      curve: Curves.easeInOutCubic,
    );
    _statusAnimController.forward();
  }

  @override
  void dispose() {
    _driverController.dispose();
    _ambulanceController.dispose();
    _statusAnimController.dispose();
    super.dispose();
  }

  Future<void> _advanceStatus(AmbulanceRequest request) async {
    final nextStatus = request.nextStatus;
    if (nextStatus == null) return;

    setState(() => _isUpdating = true);
    HapticFeedback.mediumImpact();

    try {
      await _adminService.updateRequestStatus(
        requestId: request.id,
        newStatus: nextStatus,
        driverName: _driverController.text.trim(),
        ambulanceNumber: _ambulanceController.text.trim(),
      );

      // Re-animate status stepper
      _statusAnimController.reset();
      _statusAnimController.forward();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to: ${_getStatusLabel(nextStatus)}'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Request Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ambulance_requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final request = AmbulanceRequest.fromFirestore(snapshot.data!);

          // Pre-fill text fields if empty
          if (_driverController.text.isEmpty && request.driverName.isNotEmpty) {
            _driverController.text = request.driverName;
          }
          if (_ambulanceController.text.isEmpty &&
              request.ambulanceNumber.isNotEmpty) {
            _ambulanceController.text = request.ambulanceNumber;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status Stepper ──
                _buildStatusStepper(request.status),
                const SizedBox(height: 24),

                // ── Details Card ──
                _buildInfoCard(
                  title: 'Emergency Details',
                  icon: Icons.description_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Request ID', request.id),
                      _buildInfoRow('User ID', request.userId),
                      _buildInfoRow(
                        'Details',
                        request.details ?? 'No details provided',
                      ),
                      if (request.location != null)
                        _buildInfoRow(
                          'Location',
                          '${request.location!.latitude.toStringAsFixed(4)}, '
                              '${request.location!.longitude.toStringAsFixed(4)}',
                        ),
                      if (request.createdAt != null)
                        _buildInfoRow(
                          'Created',
                          _formatDateTime(request.createdAt!),
                        ),
                      if (request.updatedAt != null)
                        _buildInfoRow(
                          'Last Updated',
                          _formatDateTime(request.updatedAt!),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Assignment Card ──
                _buildInfoCard(
                  title: 'Assignment',
                  icon: Icons.assignment_ind_outlined,
                  child: Column(
                    children: [
                      TextField(
                        controller: _driverController,
                        decoration: InputDecoration(
                          labelText: 'Driver Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: const Color(0xFFF0F0F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ambulanceController,
                        decoration: InputDecoration(
                          labelText: 'Ambulance Number',
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF0F0F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Advance Status Button ──
                if (request.nextStatus != null)
                  GestureDetector(
                    onTap: _isUpdating ? null : () => _advanceStatus(request),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _isUpdating
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF1A237E),
                                  Color(0xFF0D47A1),
                                ],
                              ),
                        color: _isUpdating ? Colors.grey.shade300 : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isUpdating
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFF1A237E)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _isUpdating
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Advance to ${_getStatusLabel(request.nextStatus!)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                if (request.nextStatus == null)
                  Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text(
                            'Request Completed',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusStepper(String currentStatus) {
    return FadeTransition(
      opacity: _statusAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Progress',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(_allStatuses.length, (index) {
                final status = _allStatuses[index];
                final currentIndex = _allStatuses.indexOf(currentStatus);
                final isCompleted = index <= currentIndex;
                final isCurrent = index == currentIndex;

                return Expanded(
                  child: Row(
                    children: [
                      // Circle indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: isCurrent ? 32 : 24,
                        height: isCurrent ? 32 : 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? _getStepColor(status)
                              : Colors.grey.shade200,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: _getStepColor(status)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          size: isCurrent ? 16 : 12,
                          color:
                              isCompleted ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
                      // Connecting line
                      if (index < _allStatuses.length - 1)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: index < currentIndex
                                ? _getStepColor(status)
                                : Colors.grey.shade200,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _allStatuses.map((s) {
                return Text(
                  _getShortLabel(s),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        s == currentStatus ? FontWeight.w700 : FontWeight.w400,
                    color: s == currentStatus
                        ? _getStepColor(s)
                        : Colors.grey.shade500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1A237E)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'on_the_way':
        return const Color(0xFF1565C0);
      case 'arrived':
        return const Color(0xFF2E7D32);
      case 'completed':
        return const Color(0xFF616161);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'requested':
        return 'Requested';
      case 'on_the_way':
        return 'On The Way';
      case 'arrived':
        return 'Arrived';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  String _getShortLabel(String status) {
    switch (status) {
      case 'requested':
        return 'REQ';
      case 'on_the_way':
        return 'OTW';
      case 'arrived':
        return 'ARR';
      case 'completed':
        return 'DONE';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
