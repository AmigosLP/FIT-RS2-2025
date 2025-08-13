import 'package:flutter/material.dart';
import 'package:zamene_mobile/models/support_ticket_model.dart';
import 'package:zamene_mobile/screens/new_support_ticket_screen.dart';
import 'package:zamene_mobile/services/support_ticket_service.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final _service = SupportTicketService();
  late Future<List<SupportTicketModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyTickets();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.getMyTickets());
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Moji tiketi'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewSupportTicketScreen()),
          );
          if (ok == true && mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('Tiket kreiran.'),
                backgroundColor: Colors.green,
              ));
            await _refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novi tiket'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<SupportTicketModel>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Greška: ${snap.error}'));
            }
            final items = snap.data ?? [];
            if (items.isEmpty) return const Center(child: Text('Nemate tikete.'));

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final t = items[i];
                final statusColor = t.isResolved ? Colors.green : primary;
                return GestureDetector(
                  onTap: () => _openDetails(t),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Naslov + status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.subject,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                t.isResolved ? 'Riješeno' : 'Otvoreno',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Kreirano: ${_fmt(t.createdAt)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(t.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                        if ((t.response ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 6),
                          Text('Odgovor podrške:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                          const SizedBox(height: 4),
                          Text(t.response!, maxLines: 3, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openDetails(SupportTicketModel t) {
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom, top: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.subject, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text('Kreirano: ${_fmt(t.createdAt)}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(t.message),
              if ((t.response ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 6),
                Text('Odgovor podrške', style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                const SizedBox(height: 6),
                Text(t.response!),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
