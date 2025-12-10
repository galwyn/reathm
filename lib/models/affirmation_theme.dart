enum AffirmationTheme {
  general,
  stoic,
  tough_love,
  gentle,
  spiritual;

  String get displayName {
    switch (this) {
      case AffirmationTheme.stoic:
        return 'Stoic';
      case AffirmationTheme.tough_love:
        return 'Tough Love';
      case AffirmationTheme.gentle:
        return 'Gentle';
      case AffirmationTheme.spiritual:
        return 'Spiritual';
      case AffirmationTheme.general:
      default:
        return 'General';
    }
  }

  String get id {
    switch (this) {
      case AffirmationTheme.stoic:
        return 'stoic';
      case AffirmationTheme.tough_love:
        return 'tough_love';
      case AffirmationTheme.gentle:
        return 'gentle';
      case AffirmationTheme.spiritual:
        return 'spiritual';
      case AffirmationTheme.general:
      default:
        return 'general';
    }
  }
}
