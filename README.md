# Consumer CES & Follow-On Behavior

Investigating whether Customer Effort Score (CES) from the personal verification flow predicts downstream transfer behavior — conversion, frequency, value, and speed.

## Headline

After controlling for country and platform, each 1-point CES increase is associated with **7.9% more follow-on transfers** (negative binomial regression, p<0.0001). This is the strongest and most consistent behavioral signal in the data, significant across all platforms.

## Key findings

| Outcome | Signal? | Notes |
|---------|---------|-------|
| Follow-on transfer count | **Yes** | Significant across all platforms (p<0.01). Strongest signal. |
| Conversion to first transfer | **Mobile only** | Android (p=0.0005) & iOS (p=0.0002) show ~5-8pp lift. Web ns. |
| Transfer value | **No** | No meaningful relationship on mobile. Web driven by outliers. |
| First transfer amount | **No** | Confirms CES measures friction, not user wealth/intent. |
| Time to first transfer | **Reversed** | Lower-CES users transfer *faster* — likely a motivation bias. |
| Scale psychometrics (IRT) | **DIF confirmed** | Mobile vs web interpret scale differently (p<0.001). 7-point scale retains more info than 3-level collapse. |

## Method

- **Data**: CES survey responses from the personal verification flow (Web + Mobile), joined with post-survey transfer activity at user-month level.
- **Descriptive tests**: Kruskal-Wallis, Mann-Whitney U, chi-square for association between CES groups and behavioral outcomes.
- **Regression**: Negative binomial model for follow-on transfer count; logistic regression for conversion. Both control for platform and registration country.
- **IRT analysis**: Graded Response Model (GRM) fitted per platform to assess scale discrimination and threshold spacing. Differential Item Functioning (DIF) tested via likelihood ratio comparing mobile vs web. Ordinal logit and AIC comparison of 7-level vs collapsed 3-level scale.
- **Grouping**: Top-3-box (CES >= 5) vs bottom-box (CES < 4) sharpens mobile signals, but IRT confirms the 7-point scale retains useful information (lower AIC than 3-level collapse).

## Important caveats

1. **Convenience based data analysis.** Survey was not designed with this measurement framework in mind, meaning we should not expect strong signal (see additional caveat below). 
2. **Causality is not established.** Users with inherently stronger intent may both rate higher and transact more.
3. **Survivorship bias.** Users who rage-quit during verification never took the survey — the worst-experience users are missing entirely.
4. **Perception-based measurement.** User motivations and mental models add noise. Properly designed measurement systems would mitigate these issues.

## Implication

There is evidence of a downstream economic benefit from improving verification experiences (more repeat transactions), but properly designed experimentation with more data would be needed to quantify the true effect and isolate its drivers.

## Repo layout

| File | Purpose |
|------|---------|
| `Personal CES and Transaction Followon.ipynb` | Full analysis notebook |
| `personal_ces_query.sql` | Snowflake SQL query used to extract the dataset |
| `ces_transactions3.csv` | Output dataset (not distributed — contains user IDs) |
| `requirements.txt` | Python dependencies |

## Run

```bash
pip install -r requirements.txt
jupyter notebook "Personal CES and Transaction Followon.ipynb"
```

The notebook expects `ces_transactions3.csv` in the project root.

## Notes

- `ces_transactions3.csv` contains user-level data and should not be shared outside the team.
- The notebook imports a local `wise_colours` module for brand-consistent charts — this is not required for the analysis to run, only for styling.
