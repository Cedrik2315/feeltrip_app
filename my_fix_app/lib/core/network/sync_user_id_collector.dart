import 'package:feeltrip_app/models/itinerary_model.dart';
import 'package:feeltrip_app/models/momento_model.dart';
import 'package:feeltrip_app/models/proposal_model.dart';

Set<String> collectPendingSyncUserIds({
  required Iterable<MomentoModel> pendingMomentos,
  required Iterable<MomentoModel> localMomentos,
  required Iterable<MomentoModel> errorMomentos,
  required Iterable<MomentoModel> deletedMomentos,
  required Iterable<ProposalModel> pendingProposals,
  required Iterable<ItineraryModel> pendingItineraries,
}) {
  return <String>{
    ...pendingMomentos.map((momento) => momento.userId),
    ...localMomentos.map((momento) => momento.userId),
    ...errorMomentos.map((momento) => momento.userId),
    ...deletedMomentos.map((momento) => momento.userId),
    ...pendingProposals.map((proposal) => proposal.userId),
    ...pendingItineraries.map((itinerary) => itinerary.userId),
  }..removeWhere((userId) => userId.isEmpty);
}
