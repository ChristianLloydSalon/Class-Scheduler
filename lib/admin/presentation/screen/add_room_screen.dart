import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class AddRoomScreen extends HookWidget {
  const AddRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final codeController = useTextEditingController();
    final nameController = useTextEditingController();
    final chairsController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final type = useState<String>('room'); // 'room' or 'lab'
    final hasWhiteboard = useState(false);
    final hasBlackboard = useState(false);
    final hasTV = useState(false);
    final hasPC = useState(false);

    Future<bool> isCodeExists(String code) async {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('rooms')
              .where('code', isEqualTo: code.toUpperCase())
              .get();
      return snapshot.docs.isNotEmpty;
    }

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        final code = codeController.text.trim().toUpperCase();
        if (await isCodeExists(code)) {
          if (!context.mounted) return;
          showToast(
            'Error',
            'Room code already exists',
            ToastificationType.error,
          );
          return;
        }

        await FirebaseFirestore.instance.collection('rooms').add({
          'code': code,
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          'chairs': int.parse(chairsController.text.trim()),
          'type': type.value,
          'whiteboard': hasWhiteboard.value,
          'blackboard': hasBlackboard.value,
          'tv': hasTV.value,
          'pc': hasPC.value,
          'name_search': nameController.text.trim().toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!context.mounted) return;
        showToast(
          'Success',
          'Room added successfully',
          ToastificationType.success,
        );
        Navigator.pop(context);
      } catch (e) {
        showToast('Error', 'Failed to add room', ToastificationType.error);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Room', style: context.textStyles.heading2.textPrimary),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a new room',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      PrimaryTextField(
                        controller: nameController,
                        labelText: 'Room Name',
                        hintText: 'Computer Laboratory 1',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          if (value.trim().isEmpty) {
                            return 'Name cannot be only whitespace';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        controller: codeController,
                        labelText: 'Room Code',
                        hintText: 'CL1',
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Code is required';
                          }
                          if (!RegExp(
                            r'^[A-Z0-9-]+$',
                          ).hasMatch(value.toUpperCase())) {
                            return 'Code can only contain letters, numbers, and hyphens';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        controller: descriptionController,
                        labelText: 'Description',
                        hintText: 'Main computer laboratory',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        controller: chairsController,
                        labelText: 'Number of Chairs',
                        hintText: '30',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Number of chairs is required';
                          }
                          final chairs = int.tryParse(value);
                          if (chairs == null || chairs < 1) {
                            return 'Invalid number of chairs';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Room Type',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'room',
                            label: Text('Room'),
                            icon: Icon(Icons.meeting_room),
                          ),
                          ButtonSegment(
                            value: 'lab',
                            label: Text('Laboratory'),
                            icon: Icon(Icons.computer),
                          ),
                        ],
                        selected: {type.value},
                        onSelectionChanged: (Set<String> newSelection) {
                          type.value = newSelection.first;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Facilities',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Whiteboard'),
                            selected: hasWhiteboard.value,
                            onSelected: (value) => hasWhiteboard.value = value,
                          ),
                          FilterChip(
                            label: const Text('Blackboard'),
                            selected: hasBlackboard.value,
                            onSelected: (value) => hasBlackboard.value = value,
                          ),
                          FilterChip(
                            label: const Text('TV'),
                            selected: hasTV.value,
                            onSelected: (value) => hasTV.value = value,
                          ),
                          FilterChip(
                            label: const Text('PC'),
                            selected: hasPC.value,
                            onSelected: (value) => hasPC.value = value,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    width: double.infinity,
                    onPressed: handleSubmit,
                    text: 'Add Room',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure all fields are filled correctly',
                    style: context.textStyles.caption1.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
