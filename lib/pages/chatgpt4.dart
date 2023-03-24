import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcesPlanner extends StatefulWidget {
  @override
  _ResourcesPlannerState createState() => _ResourcesPlannerState();
}

class _ResourcesPlannerState extends State<ResourcesPlanner> {
  List<String> _roomNumbers = [
    '101',
    '102',
    '103',
    '201',
    '202',
    '203',
    '301',
    '302',
    '303',
  ];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 365));
  Map<String, Map<DateTime, Map<String, dynamic>>> _bookings = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('gptbookings').get();

      Map<String, Map<DateTime, Map<String, dynamic>>> bookings = {};

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        String roomNumber = data['room_number'];
        DateTime date = (data['date'] as Timestamp).toDate();

        if (!bookings.containsKey(roomNumber)) {
          bookings[roomNumber] = {};
        }
        if (!bookings[roomNumber]!.containsKey(date)) {
          bookings[roomNumber]![date] = {};
        }
        bookings[roomNumber]![date]![doc.id] = data;
      });

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBookingDialog(String roomNumber, DateTime day,
      [Map<String, dynamic>? booking]) async {
    Map<String, dynamic>? newBooking = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return BookingDialog(
            roomNumber: roomNumber, day: day, booking: booking);
      },
    );
    if (newBooking != null) {
      setState(() {
        if (!_bookings.containsKey(roomNumber)) {
          _bookings[roomNumber] = {};
        }
        if (!_bookings[roomNumber]!.containsKey(day)) {
          _bookings[roomNumber]![day] = {};
        }
        _bookings[roomNumber]![day]![newBooking['id']] = newBooking;
      });
    }
  }

  Widget _buildRoomHeader(String roomNumber) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Text(
          'Room $roomNumber',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDayHeader(DateTime day) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Text(
          '${day.day}/${day.month}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCell(String roomNumber, DateTime day) {
    Map<DateTime, Map<String, dynamic>>? bookings = _bookings[roomNumber];
    Map<String, dynamic>? booking;
    if (bookings != null) {
      booking = bookings[day];
    }

    return Expanded(
      child: InkWell(
        onTap: () => _showBookingDialog(roomNumber, day, booking),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: booking != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${booking['customer_name']}'),
                    Text('Price: ${booking['price']}'),
                    Text('Guests: ${booking['guests']}'),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRoomRow(String roomNumber) {
    List<Widget> cells = [];
    for (DateTime day = _startDate;
        day.isBefore(_endDate);
        day = day.add(Duration(days: 1))) {
      cells.add(_buildCell(roomNumber, day));
    }
    return Row(
      children: [
        _buildRoomHeader(roomNumber),
        ...cells,
      ],
    );
  }

  Widget _buildDayRow() {
    List<Widget> cells = [];
    for (DateTime day = _startDate;
        day.isBefore(_endDate);
        day = day.add(Duration(days: 1))) {
      cells.add(_buildDayHeader(day));
    }
    return Container(
      height: 100,
      child: Row(
        children: [
          _buildRoomHeader(''),
          ...cells,
        ],
      ),
    );
  }

  Widget _buildPlanner() {
    // Placeholder values for _dayWidth, _days, and _roomHeight
    final double _dayWidth = 100;
    final List<String> days = [
      '2022-01-01',
      '2022-01-02',
    ];
    final double _roomHeight = 50;

    List<Widget> rows = [_buildDayRow()];
    for (String roomNumber in _roomNumbers) {
      rows.add(_buildRoomRow(roomNumber));
    }
    return Container(
      height: 400,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _dayWidth * (days.length + 1),
          height: _roomHeight * (_roomNumbers.length + 1),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              children: rows,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resources Planner'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildPlanner(),
    );
  }
}

class BookingDialog extends StatefulWidget {
  final String roomNumber;
  final DateTime day;
  final Map<String, dynamic>? booking;

  BookingDialog({
    required this.roomNumber,
    required this.day,
    this.booking,
  });

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _guestsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _customerNameController.text = widget.booking!['customer_name'];
      _priceController.text = widget.booking!['price'].toString();
      _guestsController.text = widget.booking!['guests'].toString();
    }
  }

  Future<Map<String, dynamic>> _saveBooking() async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference bookingsRef =
          FirebaseFirestore.instance.collection('bookings');
      Map<String, dynamic> data = {
        'room_number': widget.roomNumber,
        'date': Timestamp.fromDate(widget.day),
        'customer_name': _customerNameController.text,
        'price': double.parse(_priceController.text),
        'guests': int.parse(_guestsController.text),
      };

      if (widget.booking != null) {
        await bookingsRef.doc(widget.booking!['id']).update(data);
        data['id'] = widget.booking!['id'];
      } else {
        DocumentReference bookingRef = await bookingsRef.add(data);
        data['id'] = bookingRef.id;
      }
      return data;
    } catch (error) {
      print(error.toString());
      throw error;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> data = await _saveBooking();
        Navigator.pop(context, data);
      } catch (error) {
        print(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred while saving booking'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.booking != null ? 'Edit' : 'New'} Booking'),
      content: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter customer name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter valid price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _guestsController,
                    decoration: InputDecoration(
                      labelText: 'Guests',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of guests';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter valid number of guests';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitForm,
          child: Text('Save'),
        ),
      ],
    );
  }
}
