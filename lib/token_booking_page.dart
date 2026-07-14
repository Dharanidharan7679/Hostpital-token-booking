import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'token_confirmation_page.dart';

class TokenBookingPage extends StatefulWidget {
  final Map<String, String>? doctor; // <-- Add this parameter

  const TokenBookingPage({super.key, this.doctor}); // <-- Accept doctor

  @override
  _TokenBookingPageState createState() => _TokenBookingPageState();
}

class _TokenBookingPageState extends State<TokenBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regNoController = TextEditingController();
  final _mobileController = TextEditingController();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  static int _tokenCounter = 0;
  int _currentToken = 0;
  int _bookedTokensCount = 0;
  bool _isLoadingCount = false;
  final int _maxTokensPerDay = 20;

  @override
  void initState() {
    super.initState();
    _fetchTokenCount(_selectedDay);
  }

  Future<void> _fetchTokenCount(DateTime date) async {
    setState(() {
      _isLoadingCount = true;
    });
    try {
      // Normalize date to start of day for accurate comparison
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      bool isToday = isSameDay(date, DateTime.now());
      String collectionName = isToday ? "tokens" : "appointments";

      Query query = FirebaseFirestore.instance
          .collection(collectionName)
          .where("bookedDate", isGreaterThanOrEqualTo: startOfDay)
          .where("bookedDate", isLessThan: endOfDay);

      if (widget.doctor != null) {
        query = query.where("doctor", isEqualTo: widget.doctor!['name']);
      }

      var snapshot = await query.get();
      setState(() {
        _bookedTokensCount = snapshot.docs.length;
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() {
        _isLoadingCount = false;
      });
    }
  }

  Future<void> _bookToken() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tokenCounter++;
        _currentToken = _tokenCounter;
      });

      try {
        bool isToday = isSameDay(_selectedDay, DateTime.now());
        String collectionName = isToday ? "tokens" : "appointments";

        await FirebaseFirestore.instance.collection(collectionName).add({
          "name": _nameController.text,
          "age": _ageController.text,
          "regNo": _regNoController.text,
          "mobile": _mobileController.text,
          "bookedDate": _selectedDay,
          "doctor": widget.doctor != null ? widget.doctor!['name'] : null,
          "tokenNumber": _currentToken,
          "type": isToday ? "Token (Walk-in)" : "Appointment (Scheduled)",
          "createdAt": Timestamp.now(),
        });

        // Add a notification
        await FirebaseFirestore.instance.collection("notifications").add({
          "title": isToday ? "Token Booked" : "Appointment Scheduled",
          "message": "Your ${isToday ? 'token' : 'appointment'} for $_selectedDay with ${widget.doctor != null ? widget.doctor!['name'] : 'the hospital'} is confirmed.",
          "patientName": _nameController.text,
          "createdAt": Timestamp.now(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TokenConfirmationPage(
              name: _nameController.text,
              age: _ageController.text,
              regNo: _regNoController.text,
              mobile: _mobileController.text,
              bookedDate: _selectedDay,
              tokenNumber: _currentToken,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error booking token: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.doctor != null ? "Book with ${widget.doctor!['name']}" : "Book Appointment",
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Calendar Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Select Appointment Date",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 16),
                  TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _fetchTokenCount(selectedDay);
                    },
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF2563EB)),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, "Patient Name", Icons.person_outline, "Enter patient name"),
                    const SizedBox(height: 16),
                    _buildTextField(_ageController, "Age", Icons.cake_outlined, "Enter valid age", isNumber: true),
                    const SizedBox(height: 16),
                    _buildTextField(_regNoController, "Register Number", Icons.badge_outlined, "Enter valid reg no"),
                    const SizedBox(height: 16),
                    _buildTextField(_mobileController, "Mobile Number", Icons.phone_android, "Enter 10-digit number", isNumber: true, isPhone: true),
                    const SizedBox(height: 24),

                    if (_isLoadingCount)
                      const CircularProgressIndicator(color: Color(0xFF2563EB))
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _bookedTokensCount >= _maxTokensPerDay ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _bookedTokensCount >= _maxTokensPerDay
                              ? "Status: FULL ($_bookedTokensCount/$_maxTokensPerDay Slots)"
                              : "Status: Available ($_bookedTokensCount/$_maxTokensPerDay Slots)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _bookedTokensCount >= _maxTokensPerDay ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _bookedTokensCount >= _maxTokensPerDay ? null : _bookToken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: const Color(0xFF94A3B8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                          shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                        ),
                        icon: const Icon(Icons.event_available, color: Colors.white),
                        label: Text(
                          _bookedTokensCount >= _maxTokensPerDay ? "Slot Full" : "Confirm Booking",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String errorMsg, {bool isNumber = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return errorMsg;
        if (isPhone && !RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Enter valid 10-digit number";
        if (isNumber && !isPhone && (int.tryParse(value) == null || int.parse(value) <= 0)) return "Enter valid number";
        return null;
      },
    );
  }
}
