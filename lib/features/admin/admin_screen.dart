import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

enum _AdminTab { games, players, venues, finance, refunds }

/// Operations dashboard. Designed desktop-web first, with a phone layout
/// for checking today's games on the go.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  _AdminTab _tab = _AdminTab.games;

  @override
  Widget build(BuildContext context) {
    final admin = context.services.admin;
    return AsyncView<AdminDashboard>(
      load: admin.dashboard,
      builder: (context, data) => LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= 900;
          return JogaScaffold(
            showBack: true,
            padding: EdgeInsets.fromLTRB(
              wide ? Space.xxl : Space.gutter,
              Space.sm,
              wide ? Space.xxl : Space.gutter,
              Space.xl,
            ),
            children: [
              Row(
                children: [
                  const Expanded(child: Headline('Operations')),
                  JogaChip(
                    label: 'Next 7 days · ${Format.shortDate(data.date)}',
                    tone: ChipTone.muted,
                  ),
                ],
              ),
              _Kpis(data: data, wide: wide),
              if (data.resultsOutstanding > 0)
                JogaCard(
                  tone: CardTone.fire,
                  child: Row(
                    children: [
                      Text(
                        '${data.resultsOutstanding}',
                        style: AppText.h1.copyWith(color: AppColors.fire),
                      ),
                      const SizedBox(width: Space.md),
                      const Expanded(
                        child: Text(
                          'Finished games waiting for the organiser to '
                          'submit results',
                          style: AppText.smallStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ChipRow(
                children: [
                  for (final tab in _AdminTab.values)
                    JogaChip.filter(
                      label: _label(tab),
                      selected: tab == _tab,
                      onTap: () => setState(() => _tab = tab),
                    ),
                ],
              ),
              if (_tab == _AdminTab.games)
                wide
                    ? _GamesTable(rows: data.games)
                    : _GamesList(rows: data.games)
              else
                JogaCard(
                  padding: const EdgeInsets.all(Space.xl),
                  child: Text(
                    '${_label(_tab)} management is designed and built in '
                    'milestone M3.',
                    style: AppText.small,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _label(_AdminTab tab) => switch (tab) {
        _AdminTab.games => 'Games',
        _AdminTab.players => 'Players',
        _AdminTab.venues => 'Venues',
        _AdminTab.finance => 'Finance',
        _AdminTab.refunds => 'Refunds',
      };
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.data, required this.wide});

  final AdminDashboard data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatTile(value: '${data.gamesCount}', label: 'Games'),
      StatTile(value: '${data.players}', label: 'Players'),
      StatTile(
        value: '${data.almostFull}',
        label: 'Almost full',
        valueColor: AppColors.fire,
      ),
      StatTile(
        value: '${data.atRisk}',
        label: 'At risk',
        valueColor: AppColors.danger,
      ),
    ];
    final money = [
      StatTile(value: Format.moneyShort(data.revenuePence), label: 'Revenue'),
      StatTile(
        value: Format.moneyShort(data.marginPence),
        label: 'Margin',
        valueColor: data.marginPence >= 0 ? AppColors.lime : AppColors.danger,
      ),
    ];
    if (wide) return StatRow(tiles: [...tiles, ...money]);
    return Column(
      children: [
        StatRow(tiles: tiles),
        const SizedBox(height: Space.sm),
        StatRow(tiles: money),
      ],
    );
  }
}

Widget _healthChip(AdminGameRow row) {
  if (row.resultOutstanding) {
    return const JogaChip(label: 'Result due', tone: ChipTone.fire);
  }
  return switch (row.health) {
    GameHealth.full =>
      JogaChip(label: row.health.label, tone: ChipTone.selected),
    GameHealth.filling => JogaChip(label: row.health.label),
    GameHealth.atRisk =>
      JogaChip(label: row.health.label, tone: ChipTone.danger),
  };
}

class _GamesList extends StatelessWidget {
  const _GamesList({required this.rows});

  final List<AdminGameRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows) ...[
          JogaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${Format.relativeDay(row.game.startsAt)} '
                        '${Format.time(row.game.startsAt)} · '
                        '${row.game.venue.name}',
                        style: AppText.bodyStrong,
                      ),
                    ),
                    _healthChip(row),
                  ],
                ),
                Text(
                  '${row.game.format.label} · ${row.game.venue.city.label} · '
                  '${row.game.booked}/${row.game.capacity} players',
                  style: AppText.small,
                ),
                const SizedBox(height: Space.sm),
                Row(
                  children: [
                    _Money('Revenue', row.revenuePence),
                    _Money('Venue', row.venueCostPence),
                    _Money('Margin', row.marginPence, emphasise: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
        ],
      ],
    );
  }
}

class _Money extends StatelessWidget {
  const _Money(this.label, this.pence, {this.emphasise = false});

  final String label;
  final int pence;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final color = !emphasise
        ? AppColors.textPrimary
        : pence >= 0
            ? AppColors.lime
            : AppColors.danger;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.tiny),
          Text(
            Format.money(pence),
            style: AppText.smallStrong.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Desktop table view.
class _GamesTable extends StatelessWidget {
  const _GamesTable({required this.rows});

  final List<AdminGameRow> rows;

  @override
  Widget build(BuildContext context) {
    TableRow header() => TableRow(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          children: [
            for (final h in [
              'When',
              'Venue',
              'City',
              'Format',
              'Players',
              'Revenue',
              'Venue cost',
              'Margin',
              'Status',
            ])
              Padding(
                padding: const EdgeInsets.all(Space.sm),
                child: Text(h.toUpperCase(), style: AppText.label),
              ),
          ],
        );

    Widget cell(String text, {Color? color}) => Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: Text(
            text,
            style:
                AppText.small.copyWith(color: color ?? AppColors.textPrimary),
          ),
        );

    return JogaCard(
      padding: const EdgeInsets.all(Space.sm),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {1: FlexColumnWidth(2)},
        children: [
          header(),
          for (final row in rows)
            TableRow(
              children: [
                cell(
                  '${Format.relativeDay(row.game.startsAt)} '
                  '${Format.time(row.game.startsAt)}',
                ),
                cell(row.game.venue.name),
                cell(row.game.venue.city.label),
                cell(row.game.format.label),
                cell('${row.game.booked}/${row.game.capacity}'),
                cell(Format.money(row.revenuePence)),
                cell(Format.money(row.venueCostPence)),
                cell(
                  Format.money(row.marginPence),
                  color:
                      row.marginPence >= 0 ? AppColors.lime : AppColors.danger,
                ),
                Padding(
                  padding: const EdgeInsets.all(Space.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _healthChip(row),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
