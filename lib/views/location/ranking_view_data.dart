import 'package:seven_x_c/helpters/time_calculations.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

Future<RankingData> getRankingsBasedOnCriteria(
  FirebaseCloudStorage userService,
  TimePeriod selectedTimePeriod,
  String rankingSelected,
  Map<String, String> selectedTime,
) async {
  try {
    // Fetch all users
    Iterable<CloudProfile> users = await userService.getAllUsers().first;
    // Filter users based on different criteria
    Map<String, dynamic> filteredRankings = {};
    Map<String, dynamic> boulderBreakDown = {};
    String sortMethod = "";

    if (users.isNotEmpty) {
      for (var user in users) {
        double points = 0;
        int amount = 0;
        Map<String, dynamic>? rankingData;
        String amountText = "";
        Map<String, int> tempBoulderBreakDown = {};

        switch (rankingSelected) {
          case 'boulderRankingsByPoints':
            rankingData = user.dateBoulderTopped;
            amountText = "Tops";
            sortMethod = "points";
          case 'boulderRankingsByAmount':
            rankingData = user.dateBoulderTopped;
            amountText = "Tops";
            sortMethod = "amount";
          case 'challengeRankings':
            rankingData = null;
          case 'setterRankingsByPoints':
            rankingData = user.dateBoulderSet;
            amountText = "Set";
            sortMethod = "points";
          case "setterRankingsByAmount":
            rankingData = user.dateBoulderSet;
            amountText = "Set";
            sortMethod = "amount";
        }

        if (rankingData != null) {
          //   print(user.displayName);
          //   print(user.userID);
          // print(rankingData);
          //   print(selectedTime);
          switch (selectedTimePeriod) {
            case TimePeriod.year:
              var yearData = rankingData[selectedTime["year"]];
              int latestMonth =
                  DateTime.now().year > int.parse(selectedTime["year"]!)
                      ? 12
                      : DateTime.now().month;
              if (yearData != null) {
                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  var monthData = yearData[month];
                  if (monthData != null && int.parse(month) <= latestMonth) {
                    for (var weeks in monthData.keys) {
                      var weekData = monthData[weeks];
                      if (weekData != null) {
                        for (var days in weekData.keys) {
                          var dayData = weekData[days];
                          if (dayData != null) {
                            for (var boulder in dayData.keys) {
                              if (boulder != "maxToppedGrade" &&
                                  boulder != "maxFlahsedGrade") {
                                Map<String, dynamic> boulderData =
                                    dayData[boulder];
                                points += boulderData["points"];
                                amount += 1;
                                String grade = boulderData["gradeColour"];
                                if (tempBoulderBreakDown.containsKey(grade)) {
                                 tempBoulderBreakDown[grade] =  tempBoulderBreakDown[grade]! + 1;
                                } else {
                                  tempBoulderBreakDown[grade] = 1;
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            case TimePeriod.semester:
              var yearData = rankingData[selectedTime["year"]];
              int latestMonth =
                  DateTime.now().year > int.parse(selectedTime["year"]!)
                      ? 12
                      : DateTime.now().month;
              if (yearData != null) {
                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  var monthData = yearData[month];

                  if (semesterMap[selectedTime["semester"]]!.contains(month)) {
                    if (monthData != null && int.parse(month) <= latestMonth) {
                      var monthData = yearData[month];
                      {
                        for (var weeks in monthData.keys) {
                          var weekData = monthData[weeks];
                          if (weekData != null) {
                            for (var days in weekData.keys) {
                              var dayData = weekData[days];
                              if (dayData != null) {
                                for (var boulder in dayData.keys) {
                                  if (boulder != "maxToppedGrade" &&
                                      boulder != "maxFlahsedGrade") {
                                    Map<String, dynamic> boulderData =
                                        dayData[boulder];
                                    points += boulderData["points"];
                                    amount += 1;
                                    String grade = boulderData["gradeColour"];
                                    if (tempBoulderBreakDown.containsKey(grade)) {
                                     tempBoulderBreakDown[grade] =  tempBoulderBreakDown[grade]! + 1;
                                    } else {
                                      tempBoulderBreakDown[grade] = 1;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            case TimePeriod.month:
              var yearData = rankingData[selectedTime["year"]];
              if (yearData == null) {
                break;
              }
              var monthData =
                  rankingData[selectedTime["year"]][selectedTime["month"]];

              if (monthData != null) {
                {
                  var allDaysInMonth = List.generate(
                    DateTime(
                      int.parse(selectedTime["year"]!),
                      int.parse(selectedTime["month"]!) + 1,
                      0,
                    ).day,
                    (index) => (index + 1).toString(),
                  );
                  for (var weeks in monthData.keys) {
                    var weekData = monthData[weeks];

                    if (weekData != null) {
                      for (var day in allDaysInMonth) {
                        var dayData = weekData[day];
                        if (dayData != null) {
                          for (var boulder in dayData.keys) {
                            if (boulder != "maxToppedGrade" &&
                                boulder != "maxFlahsedGrade") {
                              Map<String, dynamic> boulderData =
                                  dayData[boulder];
                              points += boulderData["points"];
                              amount += 1;
                              String grade = boulderData["gradeColour"];
                              if (tempBoulderBreakDown.containsKey(grade)) {
                               tempBoulderBreakDown[grade] =  tempBoulderBreakDown[grade]! + 1;
                              } else {
                                tempBoulderBreakDown[grade] = 1;
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            case TimePeriod.week:
              var yearData = rankingData[selectedTime["year"]];
              if (yearData == null) {
                break;
              } else {
                var monthData = yearData[selectedTime["month"]];
                if (monthData == null) {
                  break;
                }
              }
              
              var weekData = rankingData[selectedTime["year"]]
                  [selectedTime["month"]][selectedTime["week"]];
              // Iterate over all possible days in the week
              // Calculate the date based on ISO week number and weekday
              int year = int.parse(selectedTime["year"]!);
              int week = int.parse(selectedTime["week"]!);
              DateTime startOfWeek = getStartDateOfWeek(year, week);

              if (weekData != null) {
                for (var dayNumber in List.generate(7, (index) => index + 1)) {
                  DateTime currentDate =
                      startOfWeek.add(Duration(days: dayNumber - 1));
                  String day = currentDate.day.toString();
                  var dayData = weekData[day];
                  if (dayData != null) {
                    for (var boulder in dayData.keys) {
                      if (boulder != "maxToppedGrade" &&
                          boulder != "maxFlahsedGrade") {
                        Map<String, dynamic> boulderData = dayData[boulder];
                        points += boulderData["points"];
                        amount += 1;
                        String grade = boulderData["gradeColour"];
                        if (tempBoulderBreakDown.containsKey(grade)) {
                          tempBoulderBreakDown[grade] = tempBoulderBreakDown[grade]! + 1;
                        } else {
                          tempBoulderBreakDown[grade] = 1;
                        }
                      }
                    }
                  }
                }
              }
          }
          String userName = "";
          user.isAnonymous == true
              ? userName = "Anonymous"
              : userName = user.displayName;

          filteredRankings[userName] = {};
          filteredRankings[userName]["rankings"] = "points: $points - $amountText: $amount";
          if (amount < 1) {boulderBreakDown[userName] = null;} else {boulderBreakDown[userName] = tempBoulderBreakDown; }
           
        }
      }
    }

    return RankingData(
        gotData: true, rankings: mapSorter(filteredRankings, sortMethod), boulderBreakDown: boulderBreakDown);
  } catch (e) {
    return RankingData(gotData: false, rankings: [], boulderBreakDown: {});
  }
}

List<String> mapSorter(Map<String, dynamic> filteredRankings, String sortBy) {
  // Parse points and amount from the string value
  List<MapEntry<String, dynamic>> parsedEntries =
      filteredRankings.entries.map((entry) {
    final value = entry.value["rankings"];
    final pointsMatch = RegExp(r'points: (\d+)').firstMatch(value);
    final amountMatch = RegExp(r'(\w+): (\d+)').allMatches(value).last;

    final points = pointsMatch != null ? int.parse(pointsMatch.group(1)!) : 0;
    // ignore: unnecessary_null_comparison
    final amount = amountMatch != null ? int.parse(amountMatch.group(2)!) : 0;

    return MapEntry(
        entry.key, {'points': points, 'amount': amount, 'value': value});
  }).toList();

  // Sort based on the selected criteria
  parsedEntries.sort((a, b) {
    final aValue = a.value;
    final bValue = b.value;

    if (sortBy == 'points') {
      return bValue['points'].compareTo(aValue['points']);
    } else if (sortBy == 'amount') {
      return bValue['amount'].compareTo(aValue['amount']);
    } else {
      return 0; // Default case, no sorting
    }
  });

  List<String> resultList = [];

  // Create the result list from the sorted entries
  for (var entry in parsedEntries) {
    if (sortBy == 'points') {
      resultList.add("${entry.key} - Points: ${entry.value['points']}");
    } else if (sortBy == 'amount') {
      resultList.add("${entry.key} - Amount: ${entry.value['amount']}");
    }
  }

  return resultList;
}

class RankingData {
  bool gotData;
  List<String> rankings;
  Map<String, dynamic> boulderBreakDown;
  RankingData({required this.gotData, required this.rankings, required this.boulderBreakDown});
}
