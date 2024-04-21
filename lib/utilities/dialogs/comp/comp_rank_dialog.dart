import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/helpters/comp/comp_calculations.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';

void showCompRankings(
  BuildContext context, {
  required FirebaseCloudStorage? compService,
  required CloudComp currentComp,
  required CloudProfile? currentProfile,
  required Function(bool) setCompView,
}) {
  Map<String, dynamic> rankings = compRanking(currentComp);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BlocProvider(
        create: (_) => RankingBloc(),
        child: Builder(
          builder: (context) {
            return BlocBuilder<RankingBloc, RankingShow>(
              builder: (context, state) {
                return AlertDialog(
                  content: Text(currentComp.compName),
                  actions: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            child: Text("Live View ?"),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(IconManager.showRanking),
                                  onPressed: () {
                                    context
                                        .read<RankingBloc>()
                                        .setRankingShow(RankingShow.total);
                                  },
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(IconManager.femaleRankings),
                                  onPressed: () {
                                    context
                                        .read<RankingBloc>()
                                        .setRankingShow(RankingShow.female);
                                  },
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(IconManager.maleRankings),
                                  onPressed: () {
                                    context
                                        .read<RankingBloc>()
                                        .setRankingShow(RankingShow.male);
                                  },
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(IconManager.boulderRankings),
                                  onPressed: () {
                                    context
                                        .read<RankingBloc>()
                                        .setRankingShow(RankingShow.boulders);
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (state == RankingShow.boulders)
                            rankBoulders(currentComp),
                          if (state == RankingShow.total)
                            rankingList(rankings, "total"),
                          if (state == RankingShow.male)
                            rankingList(rankings, "male"),
                          if (state == RankingShow.female)
                            rankingList(rankings, "female"),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              showErrorDialog(context, "INFO!");
                            },
                            child: const Text("Info")),
                        ElevatedButton(
                            onPressed: () {
                              setCompView(false);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Exit comp"))
                      ],
                    )
                  ],
                );
              },
            );
          },
        ),
      );
    },
  );
}

SizedBox rankBoulders(CloudComp compData) {
  return SizedBox(
    height: 500,
    width: 400,
    child: ListView.builder(
      itemCount: compData.bouldersComp!.length,
      itemBuilder: (context, index) {
        final boulderId = compData.bouldersComp!.keys.elementAt(index);
        final boulderData = compData.bouldersComp![boulderId];
        return ListTile(
          title: Text(
              "$boulderId ${boulderData["holdColour"]} - ${boulderData["points"]}"),
        );
      },
    ),
  );
}

SizedBox rankingList(Map<String, dynamic> rankings, String gender) {
  List<String> sortedUserIds = sortRanking(rankings[gender]);
  
  return SizedBox(
    height: 500,
    width: 400,
    child: ListView.builder(
      itemCount: sortedUserIds.length,
      itemBuilder: (context, index) {
        String climberId = sortedUserIds[index];
        Map<String, dynamic> climberData = rankings[gender][climberId];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              (index + 1).toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text("Climber ID: $climberId"),
          subtitle: Text(
            "Points: ${climberData['points']}, Tops: ${climberData['tops']}",
          ),
        );
      },
    ),
  );
}

enum RankingShow { boulders, male, female, total }

class RankingBloc extends Cubit<RankingShow> {
  RankingBloc() : super(RankingShow.boulders);

  void setRankingShow(RankingShow show) => emit(show);
}
