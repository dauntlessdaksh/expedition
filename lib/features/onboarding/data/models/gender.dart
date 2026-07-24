/// User gender selection stored during onboarding.
enum Gender {
  male,
  female;

  String get label => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
      };

  String get storageValue => name;
}
