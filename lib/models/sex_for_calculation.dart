enum SexForCalculation {
  female,
  male,
  preferNotToSay;

  String get value {
    switch (this) {
      case SexForCalculation.female:
        return 'female';
      case SexForCalculation.male:
        return 'male';
      case SexForCalculation.preferNotToSay:
        return 'prefer_not_to_say';
    }
  }

  String get label {
    switch (this) {
      case SexForCalculation.female:
        return 'Female';
      case SexForCalculation.male:
        return 'Male';
      case SexForCalculation.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  static SexForCalculation? fromValue(String? value) {
    for (final item in SexForCalculation.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}
