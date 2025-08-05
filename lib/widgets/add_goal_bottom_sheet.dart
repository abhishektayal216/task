import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';

class AddGoalBottomSheet extends StatefulWidget {
  final Goal? goal;

  const AddGoalBottomSheet({super.key, this.goal});

  @override
  State<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<AddGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  GoalCategory _selectedCategory = GoalCategory.workCareer;
  GoalType _selectedType = GoalType.weekly;
  DateTime _selectedTargetDate = DateTime.now().add(const Duration(days: 7));
  
  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final goal = widget.goal!;
    _titleController.text = goal.title;
    _descriptionController.text = goal.description;
    _selectedCategory = goal.category;
    _selectedType = goal.type;
    _selectedTargetDate = goal.targetDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildCategorySection(),
                const SizedBox(height: 16),
                _buildTypeSection(),
                const SizedBox(height: 16),
                _buildTargetDateSection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          _isEditing ? 'Edit Goal' : 'Add New Goal',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Goal Title',
        hintText: 'Enter goal title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.flag),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a goal title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Describe your goal',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a goal description';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GoalCategory.values.map((category) {
            return _buildCategoryChip(category);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(GoalCategory category) {
    final isSelected = _selectedCategory == category;
    final goal = Goal(
      id: '',
      title: '',
      description: '',
      category: category,
      type: GoalType.daily,
      targetDate: DateTime.now(),
      linkedTasks: [],
      createdAt: DateTime.now(),
    );
    
    return FilterChip(
      label: Text(goal.categoryText),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategory = category;
          });
        }
      },
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: GoalType.values.map((type) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildTypeChip(type),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(GoalType type) {
    final isSelected = _selectedType == type;
    final goal = Goal(
      id: '',
      title: '',
      description: '',
      category: GoalCategory.workCareer,
      type: type,
      targetDate: DateTime.now(),
      linkedTasks: [],
      createdAt: DateTime.now(),
    );
    
    return FilterChip(
      label: Text(goal.typeText),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
            _updateDefaultTargetDate();
          });
        }
      },
    );
  }

  void _updateDefaultTargetDate() {
    final now = DateTime.now();
    switch (_selectedType) {
      case GoalType.daily:
        _selectedTargetDate = DateTime(now.year, now.month, now.day, 23, 59);
        break;
      case GoalType.weekly:
        _selectedTargetDate = now.add(const Duration(days: 7));
        break;
      case GoalType.monthly:
        _selectedTargetDate = DateTime(now.year, now.month + 1, now.day);
        break;
      case GoalType.yearly:
        _selectedTargetDate = DateTime(now.year + 1, now.month, now.day);
        break;
    }
  }

  Widget _buildTargetDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTargetDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedTargetDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_isEditing) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _deleteGoal,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Delete'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _saveGoal,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(_isEditing ? 'Update Goal' : 'Add Goal'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (date != null) {
      setState(() {
        _selectedTargetDate = date;
      });
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goal = Goal(
      id: widget.goal?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      type: _selectedType,
      targetDate: _selectedTargetDate,
      progress: widget.goal?.progress ?? 0.0,
      isCompleted: widget.goal?.isCompleted ?? false,
      linkedTasks: widget.goal?.linkedTasks ?? [],
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      context.read<GoalProvider>().updateGoal(goal);
    } else {
      context.read<GoalProvider>().addGoal(goal);
    }

    Navigator.pop(context);
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(widget.goal!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}