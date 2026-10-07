// Realistic content for the catalog: one Lisbon trip, a crew of six.
import 'package:tripami_design_system/tripami_design_system.dart';

final crew = [
  for (final (i, (id, name)) in [
    ('alex', 'Alex Rivera'),
    ('maya', 'Maya Chen'),
    ('leo', 'Leo Okafor'),
    ('jonah', 'Jonah Weiss'),
    ('priya', 'Priya Nair'),
    ('sam', 'Sam Torres'),
    ('ines', 'Inês Duarte'),
    ('kai', 'Kai Tanaka'),
  ].indexed)
    TPMember(id: id, name: name, color: TPMemberColor.forJoinIndex(i), online: i.isEven),
];

TPMember get alex => crew[0];
TPMember get maya => crew[1];
TPMember get leo => crew[2];
TPMember get jonah => crew[3];
TPMember get priya => crew[4];

final lisbonDay = [
  TPBraidMoment(time: '08:00', events: [
    TPBraidEvent(id: 'b', title: 'Breakfast together', start: '08:00', end: '09:00', place: 'Manteigaria', participantIds: {for (final m in crew.take(5)) m.id}),
  ]),
  const TPBraidMoment(time: '09:30', events: [
    TPBraidEvent(id: 't', title: 'Tram 28 to Graça', start: '09:30', end: '11:00', place: 'Martim Moniz', participantIds: {'alex', 'maya'}),
    TPBraidEvent(id: 'a', title: 'Wandering Alfama', start: '09:30', end: '12:00', place: 'No plans, just vibes', participantIds: {'leo'}, loose: true),
    TPBraidEvent(id: 'p', title: 'Pastéis class', start: '09:30', end: '11:30', place: 'Belém', participantIds: {'jonah', 'priya'}),
  ]),
  TPBraidMoment(time: '13:00', events: [
    TPBraidEvent(id: 'l', title: 'Lunch at Taberna da Rua', start: '13:00', end: '14:30', place: 'Bairro Alto', participantIds: {for (final m in crew.take(5)) m.id}, now: true),
  ]),
];

/// A 50-person group trip: seven groups that split up mid-morning.
(List<TPMember>, List<TPBraidGroup>, List<TPBraidMoment>) bigTrip() {
  final people = [for (var i = 0; i < 50; i++) TPMember(id: 'p$i', name: 'Traveler $i', color: TPMemberColor.forJoinIndex(i))];
  const names = ['Rome crew', 'Early risers', 'Foodies', 'Museum nerds', 'Night owls', 'Beach day', 'Shoppers'];
  final groups = [
    for (var g = 0; g < 7; g++)
      TPBraidGroup(
        id: 'g$g',
        name: names[g],
        color: TPMemberColor.forJoinIndex(g),
        memberIds: {for (var i = g * 7; i < (g == 6 ? 50 : g * 7 + 7); i++) 'p$i'},
      ),
  ];
  final everyone = {for (final p in people) p.id};
  const tours = ['Colosseum tour', 'Trastevere walk', 'Food market', 'Borghese Gallery', 'Late brunch', 'Ostia beach'];
  final moments = [
    TPBraidMoment(time: '09:00', events: [TPBraidEvent(id: 'w', title: 'Welcome breakfast', participantIds: everyone)]),
    TPBraidMoment(time: '10:30', events: [
      for (var g = 0; g < 6; g++) TPBraidEvent(id: 't$g', title: tours[g], participantIds: groups[g].memberIds),
    ]),
    TPBraidMoment(time: '19:00', events: [TPBraidEvent(id: 'd', title: 'Group dinner', place: 'Da Enzo', participantIds: everyone, now: true)]),
  ];
  return (people, groups, moments);
}
