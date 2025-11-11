import 'package:flutter/material.dart';

void showSummarySheet(
  BuildContext context, {
  required List<Map<String, dynamic>> liked,
  required List<Map<String, dynamic>> passed,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Liked'),
                Tab(text: 'Passed'),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TabBarView(
                children: [
                  _List(profiles: liked),
                  _List(profiles: passed),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _List extends StatelessWidget {
  final List<Map<String, dynamic>> profiles;
  const _List({required this.profiles});

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return const Center(child: Text('Nothing here yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 12),
      itemCount: profiles.length,
      separatorBuilder: (_, __) => const Divider(height: 12),
      itemBuilder: (_, i) {
        final p = profiles[i];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(p['image'])),
          title: Text('${p['name']}'),
          subtitle: Text(p['bio']),
          trailing: Text('${p['age']}'),
        );
      },
    );
  }
}
