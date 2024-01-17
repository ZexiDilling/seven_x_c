import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                                  icon: const Icon(Icons.female),
                                  onPressed: () {
                                    context
                                        .read<RankingBloc>()
                                        .setRankingShow(RankingShow.female);
                                  },
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(Icons.male),
                                  onPressed: () {
                                    context
                                        .read<RankingBloc>()
                                        .setRankingShow(RankingShow.male);
                                  },
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(Icons.rocket_launch),
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
                          if (state == RankingShow.male)
                            rankingList(currentComp, "male"),
                          if (state == RankingShow.female)
                            rankingList(currentComp, "female"),
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
              "${boulderId} ${boulderData["holdColour"]} - ${boulderData["points"]}"),
        );
      },
    ),
  );
}

SizedBox rankingList(CloudComp compData, String gender) {
  return SizedBox(
    height: 500,
    width: 400,
    child: ListView.builder(
      itemCount: compData.climbersComp!.values
          .where((climberData) => climberData['gender'] == gender)
          .length,
      itemBuilder: (context, index) {
        final filteredClimbers = compData.climbersComp!.values
            .where((climberData) => climberData['gender'] == gender)
            .toList();

        filteredClimbers.sort((a, b) {
          final pointsComparison = b['points'].compareTo(a['points']);
          if (pointsComparison != 0) {
            return pointsComparison;
          } else {
            return b['tops'].compareTo(a['tops']);
          }
        });

        final climberData = filteredClimbers[index];
        final climberId = compData.climbersComp!.keys
            .firstWhere((key) => compData.climbersComp![key] == climberData);

        return ListTile(
          title: Text(
              "Male Climber $climberId - Points: ${climberData['points']}, Tops: ${climberData['tops']}"),
        );
      },
    ),
  );
}

enum RankingShow { boulders, male, female }

class RankingBloc extends Cubit<RankingShow> {
  RankingBloc() : super(RankingShow.boulders);

  void setRankingShow(RankingShow show) => emit(show);
}
