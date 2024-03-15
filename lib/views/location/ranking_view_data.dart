import 'dart:collection';

import 'package:seven_x_c/helpters/time_calculations.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

Future<List<String>> getRankingsBasedOnCriteria(
  FirebaseCloudStorage userService,
  TimePeriod selectedTimePeriod,
  String criteria,
  Map<String, String> selectedTime,
) async {
  try {
    // Fetch all users
    Iterable<CloudProfile> users = await userService.getAllUsers().first;
    // Filter users based on different criteria
    Map<String, dynamic> filteredRankings = {};

    if (users.isNotEmpty) {
      for (var user in users) {
        double points = 0;
        int amount = 0;
        Map<String, dynamic>? rankingData;
        String amountText = "";
        switch (criteria) {
          case 'boulderRankingsByPoints':
            rankingData = user.dateBoulderTopped;
            amountText = "Tops";
          case 'boulderRankingsByAmount':
            rankingData = user.dateBoulderTopped;
            amountText = "Tops";
          case 'challengeRankings':
            rankingData = null;
          case 'setterRankingsByAmount':
            rankingData = user.dateBoulderSet;
            amountText = "Set";
          case "setterRankingsByPoints":
            rankingData = user.dateBoulderSet;
            amountText = "Set";
        }
        if (rankingData != null) {
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
                if (user.displayName == "Charlie") {}
                for (var dayNumber in List.generate(7, (index) => index + 1)) {
                  DateTime currentDate =
                      startOfWeek.add(Duration(days: dayNumber - 1));
                  String day = currentDate.day.toString();
                  if (user.displayName == "Charlie") {}
                  var dayData = weekData[day];
                  if (user.displayName == "Charlie") {}
                  if (dayData != null) {
                    for (var boulder in dayData.keys) {
                      if (boulder != "maxToppedGrade" &&
                          boulder != "maxFlahsedGrade") {
                        Map<String, dynamic> boulderData = dayData[boulder];
                        points += boulderData["points"];

                        amount += 1;
                      }
                    }
                  }
                }
              }
          }
                  user.isAnonymous == true
            ? filteredRankings["Anonymous"] = "points: $points - $amountText: $amount"
            : filteredRankings[user.displayName] = "points: $points - $amountText: $amount";
        }

      }
    }

    return mapSorter(filteredRankings);
  } catch (e) {
    return [];
  }
}

List<String> mapSorter(Map<String, dynamic> filteredRankings) {
  var sortedKeys = filteredRankings.keys.toList(growable: false)
    ..sort((k1, k2) => filteredRankings[k1].compareTo(filteredRankings[k2]));

  LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
      key: (k) => k, value: (k) => filteredRankings[k]);

  List<String> resultList = [];

  // Iterate over the sorted map and create a list of strings
  for (var entry in sortedMap.entries) {
    String keyValueString = "${entry.key} - ${entry.value}";
    resultList.add(keyValueString);
  }

  // Print the result list
  return resultList;
}
