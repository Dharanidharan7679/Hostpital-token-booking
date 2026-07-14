import 'package:flutter/material.dart';

class NewPatientFormScreen extends StatefulWidget {
  const NewPatientFormScreen({super.key});

  @override
  _NewPatientFormScreenState createState() => _NewPatientFormScreenState();
}

class _NewPatientFormScreenState extends State<NewPatientFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _showConfirmation = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showConfirmation = true;
      });
      _animController.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Patient Form",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 6,
              color: Colors.white,
              shadowColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField("Full Name", _nameController),
                      _buildTextField("Age", _ageController, isNumber: true),
                      _buildTextField("Gender", _genderController),
                      _buildTextField("Phone Number", _phoneController,
                          isPhone: true),
                      _buildTextField("Address", _addressController, maxLines: 3),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            "APPLY",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_showConfirmation)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 30),
                              SizedBox(width: 10),
                              Text("Application Submitted",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text("Name: ${_nameController.text}",
                              style: const TextStyle(fontSize: 16)),
                          Text("Age: ${_ageController.text}",
                              style: const TextStyle(fontSize: 16)),
                          Text("Gender: ${_genderController.text}",
                              style: const TextStyle(fontSize: 16)),
                          Text("Phone: ${_phoneController.text}",
                              style: const TextStyle(fontSize: 16)),
                          Text("Address: ${_addressController.text}",
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: Icon(_getIcon(label), color: Colors.blue.shade600),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }
          if (isPhone && value.length != 10) {
            return "Enter a valid 10-digit phone number";
          }
          return null;
        },
      ),
    );
  }

  IconData _getIcon(String label) {
    switch (label) {
      case "Full Name":
        return Icons.person_outline;
      case "Age":
        return Icons.calendar_today_outlined;
      case "Gender":
        return Icons.transgender;
      case "Phone Number":
        return Icons.phone_outlined;
      case "Address":
        return Icons.home_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
