import 'package:flutter/material.dart';
import 'package:zamene_desktop/models/support_ticket_model.dart';
import 'package:zamene_desktop/providers/admin_support_provider.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  final _service = AdminSupportService();

  late TabController _tab;
  late Future<List<SupportTicketModel>> _openFuture;
  late Future<List<SupportTicketModel>> _resolvedFuture;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _refresh();
  }

  void _refresh() {
    setState(() {
      _openFuture = _service.getTickets(resolved: false);
      _resolvedFuture = _service.getTickets(resolved: true);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: TabBar(
            controller: _tab,
            labelColor: primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: primary,
            tabs: const [
              Tab(text: 'Otvoreni'),
              Tab(text: 'Riješeni'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _TicketsList(
                title: 'Otvoreni tiketi',
                future: _openFuture,
                onRefresh: _refresh,
                onRespond: _handleRespond,
                onResolveToggle: (t, val) => _handleResolve(t, val),
                primaryColor: primary,
              ),
              _TicketsList(
                title: 'Riješeni tiketi',
                future: _resolvedFuture,
                onRefresh: _refresh,
                onRespond: _handleRespond,
                onResolveToggle: (t, val) => _handleResolve(t, val),
                primaryColor: primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleRespond(SupportTicketModel t) async {
    final controller = TextEditingController(text: t.response ?? '');
    final primary = Theme.of(context).colorScheme.primary;

    final result = await showDialog<_AdminResponseResult>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Odgovor na tiket #${t.supportTicketID}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Naslov: ${t.subject}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Poruka korisnika:',
                  style: TextStyle(color: Colors.grey[700])),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(t.message),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Vaš odgovor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Slanjem odgovora korisnik će dobiti obavijest.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Pošalji'),
            onPressed: () {
              Navigator.pop(
                context,
                _AdminResponseResult(
                  response: controller.text.trim(),
                  resolve: false,
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.task_alt, color: Colors.white),
            label: const Text('Pošalji i riješi'),
            onPressed: () {
              Navigator.pop(
                context,
                _AdminResponseResult(
                  response: controller.text.trim(),
                  resolve: true,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );

    if (result == null) return;
    if (result.response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite odgovor prije slanja.')),
      );
      return;
    }

    try {
      await _service.respond(
        ticketId: t.supportTicketID,
        responseText: result.response,
        resolve: result.resolve,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resolve
              ? 'Odgovor poslan i tiket je označen kao riješen.'
              : 'Odgovor poslan.'),
          backgroundColor: result.resolve ? Colors.green : null,
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  Future<void> _handleResolve(SupportTicketModel t, bool value) async {
    try {
      await _service.updateTicket(ticketId: t.supportTicketID, isResolved: value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(value ? 'Tiket označen kao riješen.' : 'Tiket vraćen u otvorene.'),
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }
}

class _AdminResponseResult {
  final String response;
  final bool resolve;
  _AdminResponseResult({required this.response, required this.resolve});
}

class _TicketsList extends StatelessWidget {
  final String title;
  final Future<List<SupportTicketModel>> future;
  final VoidCallback onRefresh;
  final ValueChanged<SupportTicketModel> onRespond;
  final void Function(SupportTicketModel, bool) onResolveToggle;
  final Color primaryColor;

  const _TicketsList({
    required this.title,
    required this.future,
    required this.onRefresh,
    required this.onRespond,
    required this.onResolveToggle,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await future;
      },
      child: FutureBuilder<List<SupportTicketModel>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Greška: ${snap.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            );
          }

          final data = snap.data ?? const [];
          if (data.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Nema podataka.'),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }
              final t = data[index - 1];
              final date =
                  '${t.createdAt.day.toString().padLeft(2, '0')}.${t.createdAt.month.toString().padLeft(2, '0')}.${t.createdAt.year}';

              return Card(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          const Icon(Icons.confirmation_number_outlined, size: 18),
                          Text(
                            '#${t.supportTicketID}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Chip(
                            label: Text(
                              t.isResolved ? 'Riješen' : 'Otvoren',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                t.isResolved ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Kreiran: $date',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.subject,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((t.response ?? '').isNotEmpty) ...[
                        const Divider(height: 18),
                        Text('Odgovor admina:',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(t.response!),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => onRespond(t),
                            icon: const Icon(Icons.reply, color: Colors.white),
                            label: const Text(
                              'Odgovori',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => onResolveToggle(t, !t.isResolved),
                            icon: Icon(
                              t.isResolved
                                  ? Icons.undo
                                  : Icons.task_alt_outlined,
                            ),
                            label: Text(
                              t.isResolved
                                  ? 'Vrati u otvorene'
                                  : 'Označi riješenim',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
