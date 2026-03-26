import 'package:flutter/material.dart';
import '../models/address_model.dart';

class AddressController extends ChangeNotifier {
  List<AddressModel> _addresses = [
    AddressModel(
      id: '1',
      recipientName: 'Sokrit',
      phoneNumber: '(+855) 168 227 999',
      addressLine1: 'Dun Penh Street 123',
      addressLine2: 'Prampi Makara District',
      city: 'Phnom Penh',
      state: 'Phnom Penh',
      zipCode: '10001',
      country: 'Cambodia',
      isDefault: true,
    ),
    AddressModel(
      id: '2',
      recipientName: 'Kheamra',
      phoneNumber: '(+855) 123 456 222',
      addressLine1: 'Siem Reap Street 456',
      city: 'Siem Reap',
      state: 'Siem Reap',
      zipCode: '10002',
      country: 'Cambodia',
      isDefault: false,
    ),
  ];

  List<AddressModel> get addresses => _addresses;

  AddressModel? get defaultAddress => _addresses.firstWhere(
    (addr) => addr.isDefault,
    orElse: () => _addresses.isNotEmpty ? _addresses.first: AddressModel(
            recipientName: '',
            phoneNumber: '',
            addressLine1: '',
            city: '',
            state: '',
            zipCode: '',
            country: '',
          ),
  );

  /* Delay to simulate loading static addresses */
  Future<void> fetchAddresses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  /* Add a new address (static only, no API) */
  Future<bool> addAddress(AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newAddress = address.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );


    if (newAddress.isDefault) {
      _addresses = _addresses.map((addr) {
        return addr.copyWith(isDefault: false);
      }).toList();
    }

    _addresses.add(newAddress);
    notifyListeners();
    return true;
  }

  /* Update an existing address */
  Future<bool> updateAddress(String id, AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      
      /* If this is set as default, unset other defaults */
      if (address.isDefault) {
        _addresses = _addresses.map((addr) {
          return addr.copyWith(isDefault: false);
        }).toList();
      }

      _addresses[index] = address.copyWith(id: id);
      notifyListeners();
      return true;
    }
    return false;
  }

  /* Delete an address */
  Future<bool> deleteAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _addresses.removeWhere((addr) => addr.id == id);
    notifyListeners();
    return true;
  }

  /* Set an address as default */
  Future<bool> setDefaultAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _addresses = _addresses.map((addr) {
      return addr.copyWith(isDefault: addr.id == id);
    }).toList();
    notifyListeners();
    return true;
  }
}
