import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contract.dart';

class ContractForm extends StatefulWidget {
  final void Function(Contract) onSubmit;
  final Contract? initialContract;

  const ContractForm({
    super.key,
    required this.onSubmit,
    this.initialContract,
  });

  @override
  State<ContractForm> createState() => _ContractFormState();
}

class _ContractFormState extends State<ContractForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _unitController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.initialContract != null) {
      _titleController.text = widget.initialContract!.title;
      _descriptionController.text = widget.initialContract!.description;
      _cropTypeController.text = widget.initialContract!.cropType;
      _quantityController.text = widget.initialContract!.quantity.toString();
      _priceController.text = widget.initialContract!.pricePerUnit.toString();
      _locationController.text = widget.initialContract!.location;
      _unitController.text = widget.initialContract!.unit;
      _startDate = widget.initialContract!.startDate;
      _endDate = widget.initialContract!.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cropTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final contract = Contract(
        id: widget.initialContract?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        cropType: _cropTypeController.text,
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text,
        pricePerUnit: double.parse(_priceController.text),
        location: _locationController.text,
        startDate: _startDate,
        endDate: _endDate,
        createdBy: widget.initialContract?.createdBy ?? '',
        createdAt: widget.initialContract?.createdAt ?? DateTime.now(),
        applicants: widget.initialContract?.applicants ?? [],
        isActive: widget.initialContract?.isActive ?? true,
      );
      widget.onSubmit(contract);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialContract == null ? 'Create Contract' : 'Edit Contract'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _cropTypeController,
                decoration: const InputDecoration(labelText: 'Crop Type'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a crop type' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter a quantity'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a unit' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per Unit'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a price' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a location' : null,
              ),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _submitForm();
            Navigator.pop(context);
          },
          child: Text(widget.initialContract == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
} 