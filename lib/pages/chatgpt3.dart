import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDialog extends StatefulWidget {
  final String? roomNumber;
  final DateTime? day;
  final Map<String, dynamic>? booking;

  BookingDialog({required this.roomNumber, required this.day, this.booking});

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _guestsController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.booking != null) {
      _guestsController.text = widget.booking!['guests'].toString();
      _priceController.text = widget.booking!['price'].toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _guestsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Booking for Room ${widget.roomNumber} on ${widget.day?.toString().substring(0, 10)}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: _isLoading ? CircularProgressIndicator() : Text('SAVE'),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            setState(() {
              _isLoading = true;
            });

            Map<String, dynamic> booking = {
              'room_number': widget.roomNumber,
              'date': widget.day,
              'guests': int.parse(_guestsController.text),
              'price': double.parse(_priceController.text),
            };

            try {
              await FirebaseFirestore.instance
                  .runTransaction((transaction) async {
                DocumentSnapshot snapshot = await transaction.get(
                    FirebaseFirestore.instance.collection('bookings').doc());

                if (widget.booking == null) {
                  // Create new booking
                  booking['id'] = snapshot.reference.id;
                  await transaction.set(snapshot.reference, booking);
                } else {
                  // Update existing booking
                  booking['id'] = widget.booking!['id'];
                  await transaction.update(
                      FirebaseFirestore.instance
                          .collection('bookings')
                          .doc(widget.booking!['id']),
                      booking);
                }
              });
            } catch (e) {
              print('Error saving booking: $e');
              setState(() {
                _isLoading = false;
              });
              return;
            }

            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop(booking);
          },
        ),
      ],
    );
  }
}
