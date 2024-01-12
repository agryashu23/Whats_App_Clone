import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/features/select_contacts/repository/select_contact_repo.dart';

final getContactProvider = FutureProvider.autoDispose((ref) async {
  final selectContactRepo = ref.watch(selectContactsRepoProvider);
  return selectContactRepo.getContacts();
});

final selectContactControllerProvider = Provider.autoDispose((ref) {
  final selectContactRepo = ref.watch(selectContactsRepoProvider);
  return SelectContactController(
      ref: ref, selectContactRepo: selectContactRepo);
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepo selectContactRepo;

  SelectContactController({required this.ref, required this.selectContactRepo});

  void selectContact(Contact selectContact, BuildContext context) async {
    selectContactRepo.selectContact(selectContact, context);
  }
}
