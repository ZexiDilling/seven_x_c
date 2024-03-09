import 'dart:collection';
import 'package:seven_x_c/helpters/time_calculations.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_gym_data.dart';
import 'package:seven_x_c/views/boulder/ranking_view.dart' show semesterMap;

Future<PointsData> getPoints(
  CloudProfile currentProfile,
  CloudGymData currentGymData,
  Map<String, String> selectedTime,
  TimePeriod selectedTimePeriod,
  Map<int, String> gradeNumberToColour,
  bool perTimeInterval,
  String graphStyle,
) async {
  bool gotData = true;
  double pointsBoulder = 0;
  double pointsSetter = 0;
  double pointsChallenges = 0;
  int amountBoulder = 0;
  int amountSetter = 0;
  int amountChallenges = 0;
  int amountBoulderFlashed = 0;
  int maxBoulderClimbed = 0;
  int maxBoulderFlashed = 0;
  int maxClimbed = 0;
  int maxFlash = 0;
  int daysClimbed = 0;
  int daysSetting = 0;
  int amountChallengesCreated = 0;
  LinkedHashMap<String, int> boulderClimbedAmount = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxClimbed = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxFlashed = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderClimbedColours =
      LinkedHashMap();
  LinkedHashMap<String, int> boulderSetAmount = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetGradeColours =
      LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetHoldColours =
      LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetGrading = LinkedHashMap();
  LinkedHashMap<String, Map<int, Map<String, int>>> boulderGradeToHoldColour =
      LinkedHashMap();
  List<String> allSetters = ["All"];
  LinkedHashMap<String, Map<String, Map<String, int>>>
      boulderGradeColourToHoldColour = LinkedHashMap();
  LinkedHashMap<String, Map<String, Map<int, int>>> boulderHoldColourToGrade =
      LinkedHashMap();
  LinkedHashMap<String, Map<String, Map<String, int>>>
      boulderHoldColourToGradeColour = LinkedHashMap();
  String maxBoulderClimbedColour = "";
  String maxBoulderFlashedColour = "";
  // bool perTimeInterval = false;
  try {
    switch (graphStyle) {
      case "climber":
        if (currentProfile.dateBoulderTopped != null) {
          switch (selectedTimePeriod) {
            case TimePeriod.year:
              var yearData =
                  currentProfile.dateBoulderTopped![selectedTime["year"]];
              int latestMonth =
                  DateTime.now().year > int.parse(selectedTime["year"]!)
                      ? 12
                      : DateTime.now().month;
              if (yearData != null) {
                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  if (perTimeInterval) {
                    boulderClimbedAmount[month] ??= 0;
                    boulderClimbedMaxClimbed[month] ??= maxClimbed;
                    boulderClimbedMaxFlashed[month] ??= maxFlash;
                    boulderClimbedColours[month] ??= {};
                  }
                }
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
                            daysClimbed++;
                            for (var boulder in dayData.keys) {
                              if (boulder != "maxToppedGrade" &&
                                  boulder != "maxFlahsedGrade") {
                                Map<String, dynamic> boulderData =
                                    dayData[boulder];
                                pointsBoulder += boulderData["points"] ?? 0;
                                amountBoulder++;

                                boulderClimbedAmount[month] ??= 0;
                                boulderClimbedAmount[month] =
                                    (boulderClimbedAmount[month] ?? 0) + 1;

                                boulderClimbedMaxClimbed[month] ??= maxClimbed;
                                if (boulderData["gradeNumber"] >
                                    boulderClimbedMaxClimbed[month]) {
                                  boulderClimbedMaxClimbed[month] =
                                      boulderData["gradeNumber"];
                                  maxClimbed = boulderData["gradeNumber"];
                                  maxBoulderClimbedColour =
                                      boulderData["gradeColour"];
                                } else {
                                  boulderClimbedMaxClimbed[month] = maxClimbed;
                                }
                                if (boulderData["flashed"]) {
                                  amountBoulderFlashed++;
                                  boulderClimbedMaxFlashed[month] ??= maxFlash;
                                  if (boulderData["gradeNumber"] >
                                      boulderClimbedMaxFlashed[month]) {
                                    boulderClimbedMaxFlashed[month] =
                                        boulderData["gradeNumber"];
                                    maxFlash = boulderData["gradeNumber"];
                                    maxBoulderFlashedColour =
                                        boulderData["gradeColour"];
                                  } else {
                                    boulderClimbedMaxFlashed[month] = maxFlash;
                                  }
                                }

                                boulderClimbedColours[month] ??= {};
                                boulderClimbedColours[month]![
                                    boulderData["gradeColour"]] ??= 0;
                                boulderClimbedColours[month]![
                                        boulderData["gradeColour"]] =
                                    (boulderClimbedColours[month]![
                                                boulderData["gradeColour"]] ??
                                            0) +
                                        1;
                                maxBoulderClimbed = maxClimbed;
                                maxBoulderFlashed = maxFlash;
                              }
                            }
                          }
                        }
                      }
                    }
                  } else {
                    if (!perTimeInterval) {
                      if (int.parse(month) <= latestMonth) {
                        boulderClimbedAmount[month] ??= 0;
                        boulderClimbedMaxClimbed[month] ??= maxClimbed;
                        boulderClimbedMaxFlashed[month] ??= maxFlash;
                        boulderClimbedColours[month] ??= {};
                      } else {
                        boulderClimbedAmount[month] ??= 0;
                        boulderClimbedMaxClimbed[month] ??= 0;
                        boulderClimbedMaxFlashed[month] ??= 0;
                        boulderClimbedColours[month] ??= {};
                      }
                    }
                  }
                }
              } else {
                gotData = false;
              }
            case TimePeriod.semester:
              var yearData =
                  currentProfile.dateBoulderTopped![selectedTime["year"]];
              int latestMonth =
                  DateTime.now().year > int.parse(selectedTime["year"]!)
                      ? 12
                      : DateTime.now().month;
              if (yearData != null) {
                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  if (perTimeInterval &&
                      semesterMap[selectedTime["semester"]]!.contains(month)) {
                    boulderClimbedAmount[month] ??= 0;
                    boulderClimbedMaxClimbed[month] ??= maxClimbed;
                    boulderClimbedMaxFlashed[month] ??= maxFlash;
                    boulderClimbedColours[month] ??= {};
                  }
                }

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
                                daysClimbed++;
                                for (var boulder in dayData.keys) {
                                  if (boulder != "maxToppedGrade" &&
                                      boulder != "maxFlahsedGrade") {
                                    Map<String, dynamic> boulderData =
                                        dayData[boulder];
                                    pointsBoulder += boulderData["points"] ?? 0;
                                    amountBoulder++;
                                    boulderClimbedAmount[month] ??= 0;
                                    boulderClimbedAmount[month] =
                                        (boulderClimbedAmount[month] ?? 0) + 1;

                                    boulderClimbedMaxClimbed[month] ??=
                                        maxClimbed;
                                    if (boulderData["gradeNumber"] >
                                        boulderClimbedMaxClimbed[month]) {
                                      boulderClimbedMaxClimbed[month] =
                                          boulderData["gradeNumber"];
                                      maxClimbed = boulderData["gradeNumber"];
                                      maxBoulderClimbedColour =
                                          boulderData["gradeColour"];
                                    } else {
                                      boulderClimbedMaxClimbed[month] =
                                          maxClimbed;
                                    }

                                    if (boulderData["flashed"]) {
                                      amountBoulderFlashed++;
                                      boulderClimbedMaxFlashed[month] ??=
                                          maxFlash;
                                      if (boulderData["gradeNumber"] >
                                          boulderClimbedMaxFlashed[month]) {
                                        boulderClimbedMaxFlashed[month] =
                                            boulderData["gradeNumber"];
                                        maxFlash = boulderData["gradeNumber"];
                                        maxBoulderFlashedColour =
                                            boulderData["gradeColour"];
                                      } else {
                                        boulderClimbedMaxFlashed[month] =
                                            maxFlash;
                                      }
                                    }

                                    boulderClimbedColours[month] ??= {};
                                    boulderClimbedColours[month]![
                                        boulderData["gradeColour"]] ??= 0;
                                    boulderClimbedColours[month]![
                                            boulderData["gradeColour"]] =
                                        (boulderClimbedColours[month]![
                                                    boulderData[
                                                        "gradeColour"]] ??
                                                0) +
                                            1;

                                    maxBoulderClimbed = maxClimbed;
                                    maxBoulderFlashed = maxFlash;
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (!perTimeInterval) {
                        if (int.parse(month) <= latestMonth) {
                          boulderClimbedAmount[month] ??= 0;
                          boulderClimbedMaxClimbed[month] ??= maxClimbed;
                          boulderClimbedMaxFlashed[month] ??= maxFlash;
                          boulderClimbedColours[month] ??= {};
                        } else {
                          boulderClimbedAmount[month] ??= 0;
                          boulderClimbedMaxClimbed[month] ??= 0;
                          boulderClimbedMaxFlashed[month] ??= 0;
                          boulderClimbedColours[month] ??= {};
                        }
                      }
                    }
                  }
                }
              } else {
                gotData = false;
              }
            case TimePeriod.month:
              var monthData =
                  currentProfile.dateBoulderTopped![selectedTime["year"]]
                      [selectedTime["month"]];

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

                  if (perTimeInterval) {
                    for (var day in allDaysInMonth) {
                      boulderClimbedAmount[day] ??= 0;
                      boulderClimbedMaxClimbed[day] ??= maxClimbed;
                      boulderClimbedMaxFlashed[day] ??= maxFlash;
                      boulderClimbedColours[day] ??= {};
                    }
                  }

                  for (var weeks in monthData.keys) {
                    var weekData = monthData[weeks];

                    if (weekData != null) {
                      for (var day in allDaysInMonth) {
                        var dayData = weekData[day];
                        if (dayData != null) {
                          daysClimbed++;
                          for (var boulder in dayData.keys) {
                            if (boulder != "maxToppedGrade" &&
                                boulder != "maxFlahsedGrade") {
                              Map<String, dynamic> boulderData =
                                  dayData[boulder];
                              pointsBoulder += boulderData["points"] ?? 0;
                              amountBoulder++;
                              boulderClimbedAmount[day] ??= 0;
                              boulderClimbedAmount[day] =
                                  (boulderClimbedAmount[day] ?? 0) + 1;

                              boulderClimbedMaxClimbed[day] ??= maxClimbed;
                              if (boulderData["gradeNumber"] >
                                  boulderClimbedMaxClimbed[day]) {
                                boulderClimbedMaxClimbed[day] =
                                    boulderData["gradeNumber"];
                                maxClimbed = boulderData["gradeNumber"];
                                maxBoulderClimbedColour =
                                    boulderData["gradeColour"];
                              } else {
                                boulderClimbedMaxClimbed[day] = maxClimbed;
                              }

                              if (boulderData["flashed"]) {
                                amountBoulderFlashed++;
                                boulderClimbedMaxFlashed[day] ??= maxFlash;
                                if (boulderData["gradeNumber"] >
                                    boulderClimbedMaxFlashed[day]) {
                                  boulderClimbedMaxFlashed[day] =
                                      boulderData["gradeNumber"];
                                  maxFlash = boulderData["gradeNumber"];
                                  maxBoulderFlashedColour =
                                      boulderData["gradeColour"];
                                } else {
                                  boulderClimbedMaxFlashed[day] = maxFlash;
                                }
                              }

                              boulderClimbedColours[day] ??= {};
                              boulderClimbedColours[day]![
                                  boulderData["gradeColour"]] ??= 0;
                              boulderClimbedColours[day]![
                                      boulderData["gradeColour"]] =
                                  (boulderClimbedColours[day]![
                                              boulderData["gradeColour"]] ??
                                          0) +
                                      1;
                              maxBoulderClimbed = maxClimbed;
                              maxBoulderFlashed = maxFlash;
                            }
                          }
                        } else {
                          if (!perTimeInterval) {
                            boulderClimbedAmount[day] ??= 0;
                            boulderClimbedMaxClimbed[day] ??= maxClimbed;
                            boulderClimbedMaxFlashed[day] ??= maxFlash;
                            boulderClimbedColours[day] ??= {};
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                gotData = false;
              }
            case TimePeriod.week:
              var weekData =
                  currentProfile.dateBoulderTopped![selectedTime["year"]]
                      [selectedTime["month"]][selectedTime["week"]];
              // Iterate over all possible days in the week
              // Calculate the date based on ISO week number and weekday
              int year = int.parse(selectedTime["year"]!);
              int week = int.parse(selectedTime["week"]!);
              DateTime startOfWeek = getStartDateOfWeek(year, week);
              Map<String, String> dateToDay = {};
              for (var dayNumber in List.generate(7, (index) => index + 1)) {
                // Calculate the date based on ISO week number and weekday
                DateTime currentDate =
                    startOfWeek.add(Duration(days: dayNumber - 1));
                String currentDay = currentDate.day.toString();
                // Now you can use the day of the week
                String dayOfWeek = currentDate.weekday.toString();

                dateToDay[currentDay] = dayOfWeek;

                if (perTimeInterval) {
                  boulderClimbedAmount[dayOfWeek] ??= 0;
                  boulderClimbedMaxClimbed[dayOfWeek] ??= maxClimbed;
                  boulderClimbedMaxFlashed[dayOfWeek] ??= maxFlash;
                  boulderClimbedColours[dayOfWeek] ??= {};
                }
              }
              if (weekData != null) {
                for (var dayNumber in List.generate(7, (index) => index + 1)) {
                  DateTime currentDate =
                      startOfWeek.add(Duration(days: dayNumber - 1));
                  String day = currentDate.day.toString();
                  String dayOfWeek = dateToDay[day]!;
                  var dayData = weekData[day];
                  if (dayData != null) {
                    daysClimbed++;
                    for (var boulder in dayData.keys) {
                      if (boulder != "maxToppedGrade" &&
                          boulder != "maxFlahsedGrade") {
                        Map<String, dynamic> boulderData = dayData[boulder];
                        pointsBoulder += boulderData["points"] ?? 0;
                        amountBoulder++;

                        boulderClimbedAmount[dayOfWeek] ??= 0;
                        boulderClimbedAmount[dayOfWeek] =
                            (boulderClimbedAmount[dayOfWeek] ?? 0) + 1;

                        boulderClimbedMaxClimbed[dayOfWeek] ??= maxClimbed;
                        if (boulderData["gradeNumber"] >
                            boulderClimbedMaxClimbed[dayOfWeek]) {
                          boulderClimbedMaxClimbed[dayOfWeek] =
                              boulderData["gradeNumber"];
                          maxClimbed = boulderData["gradeNumber"];
                          maxBoulderClimbedColour = boulderData["gradeColour"];
                        } else {
                          boulderClimbedMaxClimbed[dayOfWeek] = maxClimbed;
                        }
                        if (boulderData["flashed"]) {
                          amountBoulderFlashed++;
                          boulderClimbedMaxFlashed[dayOfWeek] ??= maxFlash;
                          if (boulderData["gradeNumber"] >
                              boulderClimbedMaxFlashed[dayOfWeek]) {
                            boulderClimbedMaxFlashed[dayOfWeek] =
                                boulderData["gradeNumber"];
                            maxFlash = boulderData["gradeNumber"];
                            maxBoulderFlashedColour =
                                boulderData["gradeColour"];
                          } else {
                            boulderClimbedMaxFlashed[dayOfWeek] = maxFlash;
                          }
                        }

                        boulderClimbedColours[dayOfWeek] ??= {};
                        boulderClimbedColours[dayOfWeek]![
                            boulderData["gradeColour"]] ??= 0;
                        boulderClimbedColours[dayOfWeek]![
                                boulderData["gradeColour"]] =
                            (boulderClimbedColours[dayOfWeek]![
                                        boulderData["gradeColour"]] ??
                                    0) +
                                1;
                        maxBoulderClimbed = maxClimbed;
                        maxBoulderFlashed = maxFlash;
                      }
                    }
                  } else {
                    boulderClimbedAmount[dayOfWeek] ??= 0;
                    boulderClimbedMaxClimbed[dayOfWeek] ??= maxClimbed;
                    boulderClimbedMaxFlashed[dayOfWeek] ??= maxFlash;
                    boulderClimbedColours[dayOfWeek] ??= {};
                  }
                }
              } else {
                gotData = false;
              }
          }
        }
      case "setter":
        if (currentProfile.dateBoulderSet != null) {
          switch (selectedTimePeriod) {
            case TimePeriod.year:
              var yearData =
                  currentProfile.dateBoulderSet![selectedTime["year"]];

              int latestMonth =
                  DateTime.now().year > int.parse(selectedTime["year"]!)
                      ? 12
                      : DateTime.now().month;
              if (yearData != null) {
                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  boulderSetAmount[month] ??= 0;
                  boulderSetGradeColours[month] ??= {};
                  boulderSetHoldColours[month] ??= {};
                  boulderSetGrading[month] ??= {};
                  boulderGradeToHoldColour[month] ??= {};
                  boulderGradeColourToHoldColour[month] ??= {};
                  boulderHoldColourToGrade[month] ??= {};
                  boulderHoldColourToGradeColour[month] ??= {};
                }
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
                            daysSetting++;
                            for (var boulder in dayData.keys) {
                              Map<String, dynamic> boulderData =
                                  dayData[boulder];

                              pointsSetter += boulderData["points"] ?? 0;
                              amountSetter++;

                              setterGraphSetup(
                                  month,
                                  boulderClimbedAmount,
                                  boulderSetGradeColours,
                                  boulderData,
                                  boulderSetHoldColours,
                                  boulderGradeToHoldColour,
                                  boulderGradeColourToHoldColour,
                                  boulderHoldColourToGrade,
                                  boulderHoldColourToGradeColour,
                                  boulderSetAmount);
                            }
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                gotData = false;
              }
            case TimePeriod.semester:
              var yearData =
                  currentProfile.dateBoulderSet![selectedTime["year"]];
              int latestMonth =
                  DateTime.now().year > int.parse(selectedTime["year"]!)
                      ? 12
                      : DateTime.now().month;

              if (yearData != null) {
                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  if (semesterMap[selectedTime["semester"]]!.contains(month)) {
                    boulderSetAmount[month] ??= 0;
                    boulderSetGradeColours[month] ??= {};
                    boulderSetHoldColours[month] ??= {};
                    boulderSetGrading[month] ??= {};
                    boulderGradeToHoldColour[month] ??= {};
                    boulderGradeColourToHoldColour[month] ??= {};
                    boulderHoldColourToGrade[month] ??= {};
                    boulderHoldColourToGradeColour[month] ??= {};
                  }
                }

                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  var monthData = yearData[month];

                  if (semesterMap[selectedTime["semester"]]!.contains(month)) {
                    if (int.parse(month) <= latestMonth) {
                      if (monthData != null) {
                        for (var weeks in monthData.keys) {
                          var weekData = monthData[weeks];
                          if (weekData != null) {
                            for (var days in weekData.keys) {
                              var dayData = weekData[days];
                              if (dayData != null) {
                                daysSetting++;
                                for (var boulder in dayData.keys) {
                                  Map<String, dynamic> boulderData =
                                      dayData[boulder];

                                  pointsSetter += boulderData["points"] ?? 0;
                                  amountSetter++;
                                  setterGraphSetup(
                                      month,
                                      boulderClimbedAmount,
                                      boulderSetGradeColours,
                                      boulderData,
                                      boulderSetHoldColours,
                                      boulderGradeToHoldColour,
                                      boulderGradeColourToHoldColour,
                                      boulderHoldColourToGrade,
                                      boulderHoldColourToGradeColour,
                                      boulderSetAmount);
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                gotData = false;
              }
            case TimePeriod.month:
              var monthData = currentProfile
                  .dateBoulderSet![selectedTime["year"]][selectedTime["month"]];
              {
                var allDaysInMonth = List.generate(
                  DateTime(
                    int.parse(selectedTime["year"]!),
                    int.parse(selectedTime["month"]!) + 1,
                    0,
                  ).day,
                  (index) => (index + 1).toString(),
                );

                for (var day in allDaysInMonth) {
                  boulderSetAmount[day] ??= 0;
                  boulderSetGradeColours[day] ??= {};
                  boulderSetHoldColours[day] ??= {};
                  boulderSetGrading[day] ??= {};
                  boulderGradeToHoldColour[day] ??= {};
                  boulderGradeColourToHoldColour[day] ??= {};
                  boulderHoldColourToGrade[day] ??= {};
                  boulderHoldColourToGradeColour[day] ??= {};
                }

                // Iterate over all possible days in the month
                if (monthData != null) {
                  for (var weeks in monthData.keys) {
                    var weekData = monthData[weeks];
                    if (weekData != null) {
                      for (var day in allDaysInMonth) {
                        var dayData = weekData[day];
                        if (dayData != null) {
                          daysSetting++;
                          for (var boulder in dayData.keys) {
                            Map<String, dynamic> boulderData = dayData[boulder];

                            pointsSetter += boulderData["points"] ?? 0;
                            amountSetter++;

                            setterGraphSetup(
                                day,
                                boulderClimbedAmount,
                                boulderSetGradeColours,
                                boulderData,
                                boulderSetHoldColours,
                                boulderGradeToHoldColour,
                                boulderGradeColourToHoldColour,
                                boulderHoldColourToGrade,
                                boulderHoldColourToGradeColour,
                                boulderSetAmount);
                          }
                        } else {
                          if (!perTimeInterval) {
                            boulderClimbedAmount[day] ??= 0;
                            boulderClimbedMaxClimbed[day] ??= maxClimbed;
                            boulderClimbedMaxFlashed[day] ??= maxFlash;
                            boulderClimbedColours[day] ??= {};
                          }
                        }
                      }
                    }
                  }
                } else {
                  gotData = false;
                }
              }
            case TimePeriod.week:
              var weekData =
                  currentProfile.dateBoulderSet![selectedTime["year"]]
                      [selectedTime["month"]][selectedTime["week"]];
              // Iterate over all possible days in the week

              // Calculate the date based on ISO week number and weekday
              int year = int.parse(selectedTime["year"]!);
              int week = int.parse(selectedTime["week"]!);
              DateTime startOfWeek = getStartDateOfWeek(year, week);
              Map<String, String> dateToDay = {};
              for (var dayNumber in List.generate(7, (index) => index + 1)) {
                // Calculate the date based on ISO week number and weekday
                DateTime currentDate =
                    startOfWeek.add(Duration(days: dayNumber - 1));
                String currentDay = currentDate.day.toString();
                // Now you can use the day of the week
                String dayOfWeek = currentDate.weekday.toString();

                dateToDay[currentDay] = dayOfWeek;

                boulderSetAmount[dayOfWeek] ??= 0;
                boulderSetGradeColours[dayOfWeek] ??= {};
                boulderSetHoldColours[dayOfWeek] ??= {};
                boulderSetGrading[dayOfWeek] ??= {};
                boulderGradeToHoldColour[dayOfWeek] ??= {};
                boulderGradeColourToHoldColour[dayOfWeek] ??= {};
                boulderHoldColourToGrade[dayOfWeek] ??= {};
                boulderHoldColourToGradeColour[dayOfWeek] ??= {};
              }
              if (weekData != null) {
                for (var dayNumber in List.generate(7, (index) => index + 1)) {
                  DateTime currentDate =
                      startOfWeek.add(Duration(days: dayNumber - 1));
                  String day = currentDate.day.toString();
                  String dayOfWeek = dateToDay[day]!;
                  var dayData = weekData[day];
                  if (dayData != null) {
                    daysSetting++;
                    for (var boulder in dayData.keys) {
                      Map<String, dynamic> boulderData = dayData[boulder];

                      pointsSetter += boulderData["points"] ?? 0;
                      amountSetter++;

                      setterGraphSetup(
                          dayOfWeek,
                          boulderClimbedAmount,
                          boulderSetGradeColours,
                          boulderData,
                          boulderSetHoldColours,
                          boulderGradeToHoldColour,
                          boulderGradeColourToHoldColour,
                          boulderHoldColourToGrade,
                          boulderHoldColourToGradeColour,
                          boulderSetAmount);
                    }
                  }
                }
              } else {
                gotData = false;
              }

            default:
              gotData = false;
              pointsBoulder = 0;
              pointsSetter = 0;
              pointsChallenges = 0;
              amountBoulder = 0;
              amountSetter = 0;
              amountChallenges = 0;
          }
        }

      case "allSetterData":
        boulderSetGradeColours["all"] = {};
        if (currentGymData.gymDataBoulders != null) {
          switch (selectedTimePeriod) {
            case TimePeriod.year:
              var yearData =
                  currentGymData.gymDataBoulders![selectedTime["year"]];

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
                              Map<String, dynamic> boulderData =
                                  dayData[boulder];

                              amountBoulder++;

                              allSetterGraphSetup(
                                  boulderGradeToHoldColour,
                                  boulderData,
                                  boulderGradeColourToHoldColour,
                                  boulderHoldColourToGrade,
                                  boulderHoldColourToGradeColour,
                                  boulderSetGradeColours,
                                  allSetters);
                            }
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                gotData = false;
              }
            case TimePeriod.semester:
              var yearData =
                  currentGymData.gymDataBoulders![selectedTime["year"]];
              int latestMonth =
                  DateTime.now().year > int.parse(selectedTime["year"]!)
                      ? 12
                      : DateTime.now().month;

              if (yearData != null) {
                for (var month
                    in List.generate(12, (index) => (index + 1).toString())) {
                  var monthData = yearData[month];
                  if (semesterMap[selectedTime["semester"]]!.contains(month)) {
                    if (int.parse(month) <= latestMonth) {
                      if (monthData != null) {
                        for (var weeks in monthData.keys) {
                          var weekData = monthData[weeks];
                          if (weekData != null) {
                            for (var days in weekData.keys) {
                              var dayData = weekData[days];
                              if (dayData != null) {
                                daysSetting++;
                                for (var boulder in dayData.keys) {
                                  Map<String, dynamic> boulderData =
                                      dayData[boulder];

                                  amountBoulder++;

                                  allSetterGraphSetup(
                                      boulderGradeToHoldColour,
                                      boulderData,
                                      boulderGradeColourToHoldColour,
                                      boulderHoldColourToGrade,
                                      boulderHoldColourToGradeColour,
                                      boulderSetGradeColours,
                                      allSetters);
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                gotData = false;
              }
            case TimePeriod.month:
              var monthData =
                  currentGymData.gymDataBoulders![selectedTime["year"]]
                      [selectedTime["month"]];
              {
                var allDaysInMonth = List.generate(
                  DateTime(
                    int.parse(selectedTime["year"]!),
                    int.parse(selectedTime["month"]!) + 1,
                    0,
                  ).day,
                  (index) => (index + 1).toString(),
                );

                // Iterate over all possible days in the month
                if (monthData != null) {
                  for (var weeks in monthData.keys) {
                    var weekData = monthData[weeks];
                    if (weekData != null) {
                      for (var day in allDaysInMonth) {
                        var dayData = weekData[day];
                        if (dayData != null) {
                          daysSetting++;
                          for (var boulder in dayData.keys) {
                            Map<String, dynamic> boulderData = dayData[boulder];

                            amountBoulder++;

                            allSetterGraphSetup(
                                boulderGradeToHoldColour,
                                boulderData,
                                boulderGradeColourToHoldColour,
                                boulderHoldColourToGrade,
                                boulderHoldColourToGradeColour,
                                boulderSetGradeColours,
                                allSetters);
                          }
                        }
                      }
                    }
                  }
                } else {
                  gotData = false;
                }
              }
            case TimePeriod.week:
              var weekData =
                  currentGymData.gymDataBoulders![selectedTime["year"]]
                      [selectedTime["month"]][selectedTime["week"]];
              // Iterate over all possible days in the week

              // Calculate the date based on ISO week number and weekday
              int year = int.parse(selectedTime["year"]!);
              int week = int.parse(selectedTime["week"]!);
              DateTime startOfWeek = getStartDateOfWeek(year, week);
              Map<String, String> dateToDay = {};
              for (var dayNumber in List.generate(7, (index) => index + 1)) {
                // Calculate the date based on ISO week number and weekday
                DateTime currentDate =
                    startOfWeek.add(Duration(days: dayNumber - 1));
                String currentDay = currentDate.day.toString();
                // Now you can use the day of the week
                String dayOfWeek = currentDate.weekday.toString();

                dateToDay[currentDay] = dayOfWeek;
              }
              if (weekData != null) {
                for (var dayNumber in List.generate(7, (index) => index + 1)) {
                  DateTime currentDate =
                      startOfWeek.add(Duration(days: dayNumber - 1));
                  String day = currentDate.day.toString();
                  var dayData = weekData[day];
                  if (dayData != null) {
                    daysSetting++;
                    for (var boulder in dayData.keys) {
                      Map<String, dynamic> boulderData = dayData[boulder];

                      amountBoulder++;

                      allSetterGraphSetup(
                          boulderGradeToHoldColour,
                          boulderData,
                          boulderGradeColourToHoldColour,
                          boulderHoldColourToGrade,
                          boulderHoldColourToGradeColour,
                          boulderSetGradeColours,
                          allSetters);
                    }
                  }
                }
              } else {
                gotData = false;
              }

            default:
              gotData = false;
              pointsBoulder = 0;
              pointsSetter = 0;
              pointsChallenges = 0;
              amountBoulder = 0;
              amountSetter = 0;
              amountChallenges = 0;
          }
        }

      default:
        gotData = false;
        pointsBoulder = 0;
        pointsSetter = 0;
        pointsChallenges = 0;
        amountBoulder = 0;
        amountSetter = 0;
        amountChallenges = 0;
    }
    return PointsData(
      gotData: gotData,
      pointsBoulder: pointsBoulder,
      pointsSetter: pointsSetter,
      pointsChallenges: pointsChallenges,
      amountBoulderClimbed: amountBoulder,
      amountSetter: amountSetter,
      amountChallengesDone: amountChallenges,
      boulderClimbedAmount: boulderClimbedAmount,
      boulderClimbedMaxClimbed: boulderClimbedMaxClimbed,
      boulderClimbedMaxFlashed: boulderClimbedMaxFlashed,
      boulderClimbedColours: boulderClimbedColours,
      boulderSetAmount: boulderSetAmount,
      boulderSetGradeColours: boulderSetGradeColours,
      boulderSetHoldColours: boulderSetHoldColours,
      boulderSetGrading: boulderSetGrading,
      allSetters: allSetters,
      boulderGradeToHoldColour: boulderGradeToHoldColour,
      boulderGradeColourToHoldColour: boulderGradeColourToHoldColour,
      boulderHoldColourToGrade: boulderHoldColourToGrade,
      boulderHoldColourToGradeColour: boulderHoldColourToGradeColour,
      amountBoulderFlashed: amountBoulderFlashed,
      maxBoulderClimbed: maxBoulderClimbed,
      maxBoulderFlashed: maxBoulderFlashed,
      daysClimbed: daysClimbed,
      daysSetting: daysSetting,
      amountChallengesCreated: amountChallengesCreated,
      maxBoulderClimbedColour: maxBoulderClimbedColour,
      maxBoulderFlashedColour: maxBoulderFlashedColour,
    );
  } catch (e) {
    return PointsData(
      gotData: false,
      pointsBoulder: 0,
      pointsSetter: 0,
      pointsChallenges: 0,
      amountBoulderClimbed: 0,
      amountSetter: 0,
      amountChallengesDone: 0,
      boulderClimbedAmount: boulderClimbedAmount,
      boulderClimbedMaxClimbed: boulderClimbedMaxClimbed,
      boulderClimbedMaxFlashed: boulderClimbedMaxFlashed,
      boulderClimbedColours: boulderClimbedColours,
      boulderSetAmount: boulderSetAmount,
      boulderSetGradeColours: boulderSetGradeColours,
      boulderSetHoldColours: boulderSetHoldColours,
      boulderSetGrading: boulderSetGrading,
      allSetters: allSetters,
      boulderGradeToHoldColour: boulderGradeToHoldColour,
      boulderGradeColourToHoldColour: boulderGradeColourToHoldColour,
      boulderHoldColourToGrade: boulderHoldColourToGrade,
      boulderHoldColourToGradeColour: boulderHoldColourToGradeColour,
      amountBoulderFlashed: amountBoulderFlashed,
      maxBoulderClimbed: maxBoulderClimbed,
      maxBoulderFlashed: maxBoulderFlashed,
      daysClimbed: daysClimbed,
      daysSetting: daysSetting,
      amountChallengesCreated: amountChallengesCreated,
      maxBoulderClimbedColour: maxBoulderClimbedColour,
      maxBoulderFlashedColour: maxBoulderFlashedColour,
    );
  }
}

void allSetterGraphSetup(
    LinkedHashMap<String, Map<int, Map<String, int>>> boulderGradeToHoldColour,
    Map<String, dynamic> boulderData,
    LinkedHashMap<String, Map<String, Map<String, int>>>
        boulderGradeColourToHoldColour,
    LinkedHashMap<String, Map<String, Map<int, int>>> boulderHoldColourToGrade,
    LinkedHashMap<String, Map<String, Map<String, int>>>
        boulderHoldColourToGradeColour,
    LinkedHashMap<String, Map<String, int>> boulderSetGradeColours,
    List allSetters) {
  String currentSetter = boulderData["setter"];
  if (!allSetters.contains(currentSetter)) {
    allSetters.add(currentSetter);
  }

  boulderSetGradeColours["all"]![boulderData["gradeColour"]] =
      (boulderSetGradeColours["all"]![boulderData["gradeColour"]] ?? 0) + 1;

  boulderGradeToHoldColour[currentSetter] ??= {};
  boulderGradeToHoldColour[currentSetter]![boulderData["gradeNumberSetter"]] ??=
      {};
  boulderGradeToHoldColour[currentSetter]![boulderData["gradeNumberSetter"]]![
      boulderData["holdColour"]] = (boulderGradeToHoldColour[currentSetter]![
              boulderData["gradeNumberSetter"]]![boulderData["holdColour"]] ??
          0) +
      1;
  boulderGradeColourToHoldColour[currentSetter] ??= {};
  boulderGradeColourToHoldColour[currentSetter]![boulderData["gradeColour"]] ??=
      {};
  boulderGradeColourToHoldColour[currentSetter]![boulderData["gradeColour"]]![
          boulderData["holdColour"]] =
      (boulderGradeColourToHoldColour[currentSetter]![
                  boulderData["gradeColour"]]![boulderData["holdColour"]] ??
              0) +
          1;
  boulderHoldColourToGrade[currentSetter] ??= {};
  boulderHoldColourToGrade[currentSetter]![boulderData["holdColour"]] ??= {};
  boulderHoldColourToGrade[currentSetter]![boulderData["holdColour"]]![
          boulderData["gradeNumberSetter"]] =
      (boulderHoldColourToGrade[currentSetter]![boulderData["holdColour"]]![
                  boulderData["gradeNumberSetter"]] ??
              0) +
          1;
  boulderHoldColourToGradeColour[currentSetter] ??= {};
  boulderHoldColourToGradeColour[currentSetter]![boulderData["holdColour"]] ??=
      {};
  boulderHoldColourToGradeColour[currentSetter]![boulderData["holdColour"]]![
          boulderData["gradeColour"]] =
      (boulderHoldColourToGradeColour[currentSetter]![
                  boulderData["holdColour"]]![boulderData["gradeColour"]] ??
              0) +
          1;
}

void setterGraphSetup(
    String timePeriode,
    LinkedHashMap<String, int> boulderClimbedAmount,
    LinkedHashMap<String, Map<String, int>> boulderSetGradeColours,
    Map<String, dynamic> boulderData,
    LinkedHashMap<String, Map<String, int>> boulderSetHoldColours,
    LinkedHashMap<String, Map<int, Map<String, int>>> boulderGradeToHoldColour,
    LinkedHashMap<String, Map<String, Map<String, int>>>
        boulderGradeColourToHoldColour,
    LinkedHashMap<String, Map<String, Map<int, int>>> boulderHoldColourToGrade,
    LinkedHashMap<String, Map<String, Map<String, int>>>
        boulderHoldColourToGradeColour,
    LinkedHashMap<String, int> boulderSetAmount) {
  boulderSetAmount[timePeriode] ??= 0;
  boulderSetAmount[timePeriode] = (boulderSetAmount[timePeriode] ?? 0) + 1;
  boulderClimbedAmount[timePeriode] ??= 0;
  boulderClimbedAmount[timePeriode] =
      (boulderClimbedAmount[timePeriode] ?? 0) + 1;
  boulderSetGradeColours[timePeriode] ??= {};
  boulderSetGradeColours[timePeriode]![boulderData["gradeColour"]] ??= 0;
  boulderSetGradeColours[timePeriode]![boulderData["gradeColour"]] =
      (boulderSetGradeColours[timePeriode]![boulderData["gradeColour"]] ?? 0) +
          1;

  boulderSetHoldColours[timePeriode] ??= {};
  boulderSetHoldColours[timePeriode]![boulderData["holdColour"]] ??= 0;
  boulderSetHoldColours[timePeriode]![boulderData["holdColour"]] =
      (boulderSetHoldColours[timePeriode]![boulderData["holdColour"]] ?? 0) + 1;
  boulderGradeToHoldColour[timePeriode] ??= {};
  boulderGradeToHoldColour[timePeriode]![boulderData["gradeNumberSetter"]] ??=
      {};
  boulderGradeToHoldColour[timePeriode]![boulderData["gradeNumberSetter"]]![
      boulderData["holdColour"]] ??= 0;
  boulderGradeToHoldColour[timePeriode]![boulderData["gradeNumberSetter"]]![
      boulderData["holdColour"]] = (boulderGradeToHoldColour[timePeriode]![
              boulderData["gradeNumberSetter"]]![boulderData["holdColour"]] ??
          0) +
      1;
  boulderGradeColourToHoldColour[timePeriode] ??= {};
  boulderGradeColourToHoldColour[timePeriode]![boulderData["gradeColour"]] ??=
      {};
  boulderGradeColourToHoldColour[timePeriode]![boulderData["gradeColour"]]![
      boulderData["holdColour"]] ??= 0;
  boulderGradeColourToHoldColour[timePeriode]![boulderData["gradeColour"]]![
          boulderData["holdColour"]] =
      (boulderGradeColourToHoldColour[timePeriode]![
                  boulderData["gradeColour"]]![boulderData["holdColour"]] ??
              0) +
          1;

  boulderHoldColourToGrade[timePeriode] ??= {};

  boulderHoldColourToGrade[timePeriode]![boulderData["holdColour"]] ??= {};

  boulderHoldColourToGrade[timePeriode]![boulderData["holdColour"]]![
      boulderData["gradeNumberSetter"]] ??= 0;

  boulderHoldColourToGrade[timePeriode]![boulderData["holdColour"]]![
          boulderData["gradeNumberSetter"]] =
      (boulderHoldColourToGrade[timePeriode]![boulderData["holdColour"]]![
                  boulderData["gradeNumberSetter"]] ??
              0) +
          1;
  boulderHoldColourToGradeColour[timePeriode] ??= {};
  boulderHoldColourToGradeColour[timePeriode]![boulderData["holdColour"]] ??=
      {};
  boulderHoldColourToGradeColour[timePeriode]![boulderData["holdColour"]]![
      boulderData["gradeColour"]] ??= 0;
  boulderHoldColourToGradeColour[timePeriode]![boulderData["holdColour"]]![
          boulderData["gradeColour"]] =
      (boulderHoldColourToGradeColour[timePeriode]![boulderData["holdColour"]]![
                  boulderData["gradeColour"]] ??
              0) +
          1;
}

String? findGradeColour(Map<int, String> gradeNumberToColour, int gradeNumber) {
  // Iterate through the sorted keys in gradeNumberToColour
  for (int key in gradeNumberToColour.keys.toList()..sort()) {
    if (gradeNumber <= key) {
      return gradeNumberToColour[key];
    }
  }
  return null; // Return null if no match is found
}

class PointsData {
  double pointsBoulder;
  double pointsSetter;
  double pointsChallenges;
  int amountBoulderFlashed;
  int maxBoulderClimbed;
  int maxBoulderFlashed;
  int daysClimbed;
  int daysSetting;
  int amountBoulderClimbed;
  int amountSetter;
  int amountChallengesDone;
  int amountChallengesCreated;
  String maxBoulderClimbedColour;
  String maxBoulderFlashedColour;
  bool gotData;

  LinkedHashMap<String, int> boulderClimbedAmount = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxClimbed = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxFlashed = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderClimbedColours =
      LinkedHashMap();
  LinkedHashMap<String, int> boulderSetAmount = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetGradeColours =
      LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetHoldColours =
      LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetGrading = LinkedHashMap();
  List<String> allSetters = [];
  LinkedHashMap<String, Map<int, Map<String, int>>> boulderGradeToHoldColour =
      LinkedHashMap();
  LinkedHashMap<String, Map<String, Map<String, int>>>
      boulderGradeColourToHoldColour = LinkedHashMap();
  LinkedHashMap<String, Map<String, Map<int, int>>> boulderHoldColourToGrade =
      LinkedHashMap();
  LinkedHashMap<String, Map<String, Map<String, int>>>
      boulderHoldColourToGradeColour = LinkedHashMap();

  PointsData(
      {required this.gotData,
      required this.pointsBoulder,
      required this.pointsSetter,
      required this.pointsChallenges,
      required this.amountBoulderClimbed,
      required this.amountBoulderFlashed,
      required this.maxBoulderClimbed,
      required this.maxBoulderClimbedColour,
      required this.maxBoulderFlashed,
      required this.maxBoulderFlashedColour,
      required this.daysClimbed,
      required this.daysSetting,
      required this.amountSetter,
      required this.amountChallengesDone,
      required this.amountChallengesCreated,
      required this.boulderClimbedAmount,
      required this.boulderClimbedMaxClimbed,
      required this.boulderClimbedMaxFlashed,
      required this.boulderClimbedColours,
      required this.boulderSetAmount,
      required this.boulderSetGradeColours,
      required this.boulderSetHoldColours,
      required this.boulderSetGrading,
      required this.allSetters,
      required this.boulderGradeToHoldColour,
      required this.boulderGradeColourToHoldColour,
      required this.boulderHoldColourToGrade,
      required this.boulderHoldColourToGradeColour});
}
