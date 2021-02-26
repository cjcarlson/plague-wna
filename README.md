# Mapping plague in the western United States

This repository contains the R scripts for Carlson, Bevins, and Schmid (2021) "Plague risk in the western United States over seven decades of environmental change", preprint forthcoming on bioRxiv. Primary data are available on reasonable request, while environmental data are all freely and openly available from public sources.

**There's also a copy of the preprint available that's been compressed for legibility, as the main preprint is nearly impossible to scroll through due to the number of high-resolution maps and figures.**

Scripts are organized into seven folders marking different stages of the pipeline:

```
A: Prepare data
├─ A1 Re-rasterize rodents.R
├─ A2 Soil macronutrient kriging.R
└─ A3 SoilGrids resampling.R

B: Extract and generate model datasets
├─ B1 Process and load environmental layers.R
├─ B2 Extract NWDP data.R
└─ B3 Extract human data.R

C: Main models and attribution models
├─ C0 Reload environment.R
├─ C1 Wildlife baseline model.R
├─ C2 Human baseline model.R
├─ C3 Wildlife attribution model.R
└─ C4 Human attribution model.R

D: Data visualization
├─ D1 Main figures.R
├─ D2 Partial dependence multipanel.R
├─ D3 Ternary.R
├─ D4 Variable importances.R
├─ D5 Alternate model maps.R
├─ D6 Spartials.R
├─ D7 Alternate model 1 partial figures.R
└─ D8 pH GAMs.R

E: Cross-validation on withheld data
└─ E1 Cross-validation 2000 to 2005.R

F: Generate alternate datasets
├─ F1 Wildlife Alt2 Pseudoabsences.R
└─ F2 Wildlife Alt3 Just coyote.R

G: Alternate models
├─ G0 Reload environment - alt for elevation.R
├─ G1 Wildlife Alt1 full variables.R
├─ G2 Human Alt2 full variables.R
├─ G3 Wildlife Alt2 pseudoabsences.R
└─ G4 Wildlife Alt3 coyote model.R
```
