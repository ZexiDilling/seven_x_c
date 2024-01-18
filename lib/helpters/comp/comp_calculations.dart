import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

void updateCompCalculations(FirebaseCloudStorage compService, CloudComp currentComp,
    CloudBoulder boulder, CloudProfile currentProfile, bool flashed, int attempts) {
  if (currentComp.compStyle == "totalBoulder" &&
      currentComp.compRules == "Classic") {
    compService.updatComp(
        compID: currentComp.compID,
        climbersComp: updateCompBoulderMap(
            currentProfile: currentProfile,
            boulder: boulder,
            currentComp: currentComp));
  }
}


Map<String, dynamic> getCompClimbersRanking(CloudComp currentComp) {
  Map<String, dynamic> compClimbers = {};
  
  currentComp.bouldersComp!.forEach((currentBoulder, boulderData) {
    List climberTopped = boulderData["Top"] ?? [];
    double boulderPoints = boulderData["points"]?.toDouble() ?? 0.0;
    // Loop through climbers who topped the current boulder
    climberTopped.forEach((userId) {
      compClimbers[userId] ??= {"tops": 0, "points": 0.0};
  
      compClimbers[userId]["tops"]++;
      compClimbers[userId]["points"] += boulderPoints;
    });
  });
  return compClimbers;
}

List<String> sortRanking(Map<String, dynamic> compClimbers) {
  
  // Create a list of user IDs sorted by points and tops
  List<String> sortedUserIds = compClimbers.keys.toList();
  sortedUserIds.sort((a, b) {
    int pointsA = compClimbers[a]["points"] ?? 0;
    int pointsB = compClimbers[b]["points"] ?? 0;
    int topsA = compClimbers[a]["tops"] ?? 0;
    int topsB = compClimbers[b]["tops"] ?? 0;
  
    if (pointsB != pointsA) {
      return pointsB.compareTo(pointsA); // Sort by points
    } else {
      return topsB.compareTo(topsA); // If points are equal, sort by tops
    }
  });
  return sortedUserIds;
}


Map<String, dynamic> compRanking(CloudComp currentComp) {
  Map<String, dynamic> ranking = {
    "total": {},
    "male": {},
    "female": {},
  };

  Map<String, dynamic> compClimbers = getCompClimbersRanking(currentComp);

  // Create a list of user IDs sorted by points and tops
  List<String> sortedUserIds = sortRanking(compClimbers);
  int rankTotal = 1;
  int rankMale = 1;
  int rankFemale = 1;
  // Update ranking based on sorted user IDs
  sortedUserIds.forEach((userId) {
    String gender = currentComp.climbersComp![userId]["gender"].toLowerCase();
    double points = compClimbers[userId]["points"].toDouble() ?? 0.0;
    int tops = compClimbers[userId]["tops"] ?? 0;

    // Update total ranking
    ranking["total"]![userId] = {
      "points": points,
      "tops": tops,
      "rank": rankTotal
    };
    rankTotal++;
    // Update gender-specific ranking
    if (gender == "male") {
      ranking["male"]![userId] = {
        "points": points,
        "tops": tops,
        "rank": rankMale
      };
      rankMale++;
    } else if (gender == "female") {
      ranking["female"]![userId] = {
        "points": points,
        "tops": tops,
        "rank": rankFemale
      };
      rankFemale++;
    }
  });

  return ranking;
}