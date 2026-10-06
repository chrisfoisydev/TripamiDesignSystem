import 'package:flutter/widgets.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

// Example content for the gallery. Not real people.

const alex = TPMember(id: 'alex', name: 'Alex Rivera', color: TPMemberColor.clay, online: true);
const maya = TPMember(id: 'maya', name: 'Maya Chen', color: TPMemberColor.marigold, online: true);
const leo = TPMember(id: 'leo', name: 'Leo Okafor', color: TPMemberColor.fern);
const jonah = TPMember(id: 'jonah', name: 'Jonah Weiss', color: TPMemberColor.sky);
const priya = TPMember(id: 'priya', name: 'Priya Nair', color: TPMemberColor.iris);
const sam = TPMember(id: 'sam', name: 'Sam Torres', color: TPMemberColor.plum);

const lisbonCrew = [alex, maya, leo, jonah, priya, sam];
const kyotoCrew = [alex, leo, priya];

const lisbonPhoto = AssetImage('assets/lisbon.jpg');
const kyotoPhoto = AssetImage('assets/kyoto.jpg');
const dinner1 = AssetImage('assets/dinner1.jpg');
const dinner2 = AssetImage('assets/dinner2.jpg');
const dinner3 = AssetImage('assets/dinner3.jpg');

const fridayDinnerOptions = [
  TPPollOption(
    id: 'taberna',
    title: 'Taberna da Rua',
    detail: 'Petiscos · Bairro Alto · €€',
    image: dinner1,
    voters: [maya, leo, alex],
  ),
  TPPollOption(
    id: 'cervejaria',
    title: 'Cervejaria Ramiro',
    detail: 'Seafood · Intendente · €€€',
    image: dinner2,
    voters: [sam],
  ),
  TPPollOption(
    id: 'prado',
    title: 'Prado',
    detail: 'Seasonal · Baixa · €€€',
    image: dinner3,
    voters: [],
  ),
];
