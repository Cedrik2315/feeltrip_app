# TODO: AiProposalCard Integration with DestinationService

## Approved Plan Steps:
- [ ] 1. Refactor lib/widgets/ai_proposal_card.dart: StatefulWidget, add userCurrency param (default 'USD'), fetch weather/photos/countryInfo, update UI with weather overlay, financial chips if different currency, toggle Logística section on tap.
- [ ] 2. Update lib/widgets/home_screen.dart: Add userCurrency: 'USD' to all AiProposalCard instances.
- [ ] 3. Test: Run app, verify Home screen cards show real weather/photo/logística; add API keys to .env if needed.
- [ ] 4. Complete: attempt_completion.

Current progress: Starting step 1/4

**Notes:**
- Samples: Café 2.50 EUR, Hotel/noche 80 EUR
- Fallbacks for missing API keys.
- onTap: Toggle logística + navigate to agency profile.

