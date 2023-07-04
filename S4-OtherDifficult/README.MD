
README

Perform lift-over from GRCh38 to CHM13v2.0 then perform inspection to check lift-over works
Generate OtherDifficult regions like MHC, KIR, and VDJ for CHM13v2.0 (S4)

Inputs: MHC, KIR, and VDJ BED files for GRCh38
Outputs: BED files for MHC, KIR, and VDJ on CHM13v2.0

The lift over is done using minimap2 and bedtools merge.

