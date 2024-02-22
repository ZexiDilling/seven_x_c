enum TimePeriod { week, month, semester, year }

// Map enum values to display strings
final Map<TimePeriod, String> timePeriodStrings = {
  TimePeriod.week: 'Week',
  TimePeriod.month: 'Month',
  TimePeriod.semester: 'Semester',
  TimePeriod.year: 'Year',
};

DateTime calculateDateThreshold(TimePeriod timePeriod) {
  DateTime currentTime = DateTime.now();

  switch (timePeriod) {
    case TimePeriod.week:
      // Find the last Monday of the current week
      DateTime lastMonday =
          currentTime.subtract(Duration(days: currentTime.weekday - 1));
      // Find the next Sunday
      return lastMonday;

    case TimePeriod.month:
      // Return the first day of the current month
      return DateTime(currentTime.year, currentTime.month, 1);

    case TimePeriod.semester:
      // Determine the semester start based on the current month
      if (currentTime.month >= 1 && currentTime.month <= 6) {
        // Semester starts in January
        return DateTime(currentTime.year, 1, 1);
      } else {
        // Semester starts in August
        return DateTime(currentTime.year, 8, 1);
      }

    case TimePeriod.year:
      // Return the first day of the current month 12 months ago
      return currentTime.subtract(
          const Duration(days: 30 * 12)); // Assuming 30 days in a month

    default:
      return DateTime(0); // Or handle the default case accordingly
  }
}

DateTime calculateEndDate(TimePeriod selectedTimePeriod, DateTime startDate) {
  switch (selectedTimePeriod) {
    case TimePeriod.week:
      // Find the next Sunday from the start date
      return startDate.add(const Duration(days: 7));

    case TimePeriod.month:
      // Find the last day of the current month
      return DateTime(startDate.year, startDate.month + 1, 1)
          .subtract(const Duration(days: 1));

    case TimePeriod.semester:
      // Determine the end of the semester based on the current month
      if (startDate.month >= 1 && startDate.month <= 6) {
        // Semester ends in July
        return DateTime(startDate.year, 7, 31);
      } else {
        // Semester ends in December
        return DateTime(startDate.year, 12, 31);
      }

    default:
      // Default case (handle accordingly)
      return DateTime.now();
  }
}

String getTimePeriodLabel(TimePeriod timePeriod) {
  switch (timePeriod) {
    case TimePeriod.week:
      return 'Week';
    case TimePeriod.month:
      return 'Month';
    case TimePeriod.semester:
      return 'Semester';
    case TimePeriod.year:
      return 'Year';
  }
}

int grabMonthBasedOnYearAndWeek(int year, int weekNumber) {
  DateTime january4th = DateTime(year, 1, 4);
  DateTime firstDayOfYear = DateTime(year, 1, 1);

  // Calculate the start date of the week
  DateTime startDate =
      january4th.subtract(Duration(days: january4th.weekday - 1));
  startDate = startDate.add(Duration(days: (weekNumber - 1) * 7));

  // If the calculated start date is before the beginning of the year, adjust it
  if (startDate.isBefore(firstDayOfYear)) {
    startDate = firstDayOfYear;
  }

  // Get the month of the calculated start date
  int month = startDate.month;
  return month;
}

DateTime grabFirstDayOfWeekBasedOnYearAndWeek(int year, int weekNumber) {
  DateTime january4th = DateTime(year, 1, 4);
  DateTime firstDayOfYear = DateTime(year, 1, 1);

  // Calculate the start date of the week
  DateTime startDate =
      january4th.subtract(Duration(days: january4th.weekday - 1));
  startDate = startDate.add(Duration(days: (weekNumber - 1) * 7));

  // If the calculated start date is before the beginning of the year, adjust it
  if (startDate.isBefore(firstDayOfYear)) {
    startDate = firstDayOfYear;
  }

  // Calculate the first day of the week
  DateTime firstDayOfWeek =
      startDate.subtract(Duration(days: startDate.weekday - 1));

  return firstDayOfWeek;
}

int getFirstWeekOfMonth(int year, int month) {
  DateTime firstDayOfMonth = DateTime(year, month, 1);

  // Find the weekday of the first day of the month
  int weekday = firstDayOfMonth.weekday;

  // Calculate the difference between the first day of the month and the first Sunday
  int difference = (weekday - DateTime.sunday + 7) % 7;

  // Calculate the first day of the first week
  DateTime firstDayOfFirstWeek =
      firstDayOfMonth.subtract(Duration(days: difference));

  // Ensure that the calculated date is within the same month
  if (firstDayOfFirstWeek.isBefore(firstDayOfMonth)) {
    firstDayOfFirstWeek = firstDayOfMonth;
  }
  int weekNumber = grabIsoWeekNumber(firstDayOfFirstWeek);

  return weekNumber;
}

int grabIsoWeekNumber(DateTime date) {
  DateTime january4th = DateTime(date.year, 1, 4);
  int daysSinceJanuary4th = date.difference(january4th).inDays;
  int weekNumber = ((daysSinceJanuary4th + january4th.weekday + 6) / 7).floor();

  if (weekNumber == 0) {
    // If the date is in the last week of the previous year
    weekNumber = grabIsoWeekNumber(DateTime(date.year - 1, 12, 31));
  }

  return weekNumber;
}

DateTime getStartDateOfWeek(int year, int weekNumber) {
  DateTime january4th = DateTime(year, 1, 4);
  int daysToAdd = (weekNumber - 1) * 7 - january4th.weekday + 1;
  return january4th.add(Duration(days: daysToAdd));
}

DateTime getEndDateOfWeek(int year, int weekNumber) {
  DateTime startDate = getStartDateOfWeek(year, weekNumber);
  return startDate.add(const Duration(days: 6));
}

int graLastDayOfMonth(int year, int month) {
  // Create a DateTime object for the first day of the next month
  DateTime firstDayOfNextMonth = DateTime(year, month + 1, 1);

  // Subtract one day to get the last day of the current month
  DateTime lastDayOfMonth = firstDayOfNextMonth.subtract(const Duration(days: 1));

  return lastDayOfMonth.day;
}

String weekLable(Map<String, String> selectedTime) {
  int year = int.parse(selectedTime["year"]!);
  int weekNumber = int.parse(selectedTime["week"]!);
  DateTime starteDate = getStartDateOfWeek(year, weekNumber);

  String startDay = starteDate.day.toString();
  String startMonth = starteDate.month.toString();
  String startYear = starteDate.year.toString().substring(2);

  DateTime endDate = getEndDateOfWeek(year, weekNumber);
  String endDay = endDate.day.toString();
  String endMonth = endDate.month.toString();
  String endYear = endDate.year.toString().substring(2);
  String weekLable =
      "$startDay/$startMonth/$startYear - $endDay/$endMonth/$endYear";
  return weekLable;
}

String monthLable(Map<String, String> selectedTime) {

  String year = selectedTime["year"]!;
  String month = monthNames[int.parse(selectedTime["month"]!)];

  String monthLable = "$month - $year";
  return monthLable;
  
}

String semesterLable(Map<String, String> selectedTime) {
  String year = selectedTime["year"]!;
  String semester = selectedTime["semester"]!;

  String semesterLable = "$semester - $year";
  return semesterLable;
}

String yearLable(Map<String, String> selectedTime) {
  return selectedTime["year"]!;
}

Map<String, String> getSelectedTime(DateTime date) {
  return {
    "year": date.year.toString(),
    "semester": (date.month >= 2 && date.month <= 7) ? "spring" : "fall",
    "month": date.month.toString(),
    "week": grabIsoWeekNumber(date).toString(),
    "day": date.day.toString(),
  };
}

DateTime getDateTimeFromSelectedTime(Map<String, String> selectedTime) {
  int year = int.parse(selectedTime["year"]!);
  int month = int.parse(selectedTime["month"]!);
  int day = int.parse(selectedTime["day"]!);

  // Calculate the date based on the year, month, and week
  DateTime date = DateTime(year, month, day);

  return date;
}

List<String> monthNames = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

Map<String, String> weekAdjustment(Map<String, String> selectedTime, bool add) {
  int year = int.parse(selectedTime["year"]!);
  int week = int.parse(selectedTime["week"]!);

  if (add) {
    week++;
  } else {
    week--;
  }
  if (week > 52) {
    year++;
    week = 1;
  } else if (week < 1) {
    year--;
    week = 52;
  }

  int month = grabMonthBasedOnYearAndWeek(year, week);

  return {
    "year": year.toString(),
    "semester": (month >= 2 && month <= 7) ? "spring" : "fall",
    "month": month.toString(),
    "week": week.toString(),
    "day": grabFirstDayOfWeekBasedOnYearAndWeek(year, week).toString(),
  };
}

Map<String, String> montAdjustment(Map<String, String> selectedTime, bool add) {
  int year = int.parse(selectedTime["year"]!);
  int month = int.parse(selectedTime["month"]!);

  if (add) {
    month++;
  } else {
    month--;
  }
  if (month > 12) {
    year++;
    month = 1;
  } else if (month < 1) {
    year--;
    month = 12;
  }

  int week = getFirstWeekOfMonth(year, month);

  return {
    "year": year.toString(),
    "semester": (month >= 2 && month <= 7) ? "spring" : "fall",
    "month": month.toString(),
    "week": week.toString(),
    "day": grabFirstDayOfWeekBasedOnYearAndWeek(year, week).toString(),
  };
}

Map<String, String> semesterAdjustment(
    Map<String, String> selectedTime, bool add) {
  int year = int.parse(selectedTime["year"]!);
  int month = int.parse(selectedTime["month"]!);
  String semester = selectedTime["semester"]!;
  int week = 0;

  if (add) {
    if (semester == "fall") {
      year++;
      month = 2;
      week = getFirstWeekOfMonth(year, month);
    } else {
      month = 8;
      week = getFirstWeekOfMonth(year, month);
    }
  } else {
    if (semester == "fall") {
      month = 2;
      week = getFirstWeekOfMonth(year, month);
    } else {
      year--;
      month = 8;
      week = getFirstWeekOfMonth(year, month);
    }
  }

  return {
    "year": year.toString(),
    "semester": (month >= 2 && month <= 7) ? "spring" : "fall",
    "month": month.toString(),
    "week": week.toString(),
    "day": grabFirstDayOfWeekBasedOnYearAndWeek(year, week).toString(),
  };
}

Map<String, String> yearAdjustment(Map<String, String> selectedTime, bool add) {
  int year = int.parse(selectedTime["year"]!);

  if (add) {
    year++;
  } else {
    year--;
  }

  int month = int.parse(selectedTime["month"]!);

  int week = grabIsoWeekNumber(DateTime(year, month, 1));

  return {
    "year": year.toString(),
    "semester": (month >= 2 && month <= 7) ? "spring" : "fall",
    "month": month.toString(),
    "week": week.toString(),
    "day": grabFirstDayOfWeekBasedOnYearAndWeek(year, week).toString(),
  };
}
