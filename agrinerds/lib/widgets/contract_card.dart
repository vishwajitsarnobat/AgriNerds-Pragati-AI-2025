import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contract.dart';

class ContractCard extends StatelessWidget {
  final Contract contract;
  final VoidCallback? onApply;

  const ContractCard({
    super.key,
    required this.contract,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showContractDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      contract.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onApply != null)
                    ElevatedButton(
                      onPressed: onApply,
                      child: const Text('Apply'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                contract.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.eco,
                    label: contract.cropType,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    icon: Icons.attach_money,
                    label: '${contract.quantity} ${contract.unit} @ ${currencyFormat.format(contract.pricePerUnit)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.calendar_today,
                    label: '${dateFormat.format(contract.startDate)} - ${dateFormat.format(contract.endDate)}',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    icon: Icons.location_on,
                    label: contract.location,
                  ),
                ],
              ),
              if (contract.applicants.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${contract.applicants.length} ${contract.applicants.length == 1 ? 'applicant' : 'applicants'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showContractDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contract.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                contract.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Crop Type', contract.cropType),
              _buildDetailRow('Quantity', '${contract.quantity} ${contract.unit}'),
              _buildDetailRow('Price per Unit', '₹${contract.pricePerUnit}'),
              _buildDetailRow('Total Value', '₹${contract.quantity * contract.pricePerUnit}'),
              _buildDetailRow('Location', contract.location),
              _buildDetailRow('Start Date', DateFormat('MMM d, yyyy').format(contract.startDate)),
              _buildDetailRow('End Date', DateFormat('MMM d, yyyy').format(contract.endDate)),
              if (contract.applicants.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Applicants (${contract.applicants.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...contract.applicants.map((applicant) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $applicant',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (onApply != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onApply?.call();
              },
              child: const Text('Apply'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 