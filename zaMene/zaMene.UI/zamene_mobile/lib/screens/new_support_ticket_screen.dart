import 'package:flutter/material.dart';
import 'package:zamene_mobile/services/support_ticket_service.dart';

class NewSupportTicketScreen extends StatefulWidget {
  const NewSupportTicketScreen({super.key});
  @override
  State<NewSupportTicketScreen> createState() => _NewSupportTicketScreenState();
}

class _NewSupportTicketScreenState extends State<NewSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _subjCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await SupportTicketService().createTicket(
        subject: _subjCtrl.text.trim(),
        message: _msgCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true); // da profil screen može pokazati “uspjeh”
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Novi tiket podrške')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _subjCtrl,
              decoration: const InputDecoration(labelText: 'Naslov/Subject'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obavezno polje' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _msgCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Poruka/Message'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obavezno polje' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(_loading ? 'Slanje…' : 'Pošalji', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: primary),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
