
README

Perform lift-over from GRCh38 to CHM13v2.0 then perform inspection to check lift-over works
Generate OtherDifficult regions like MHC, KIR, and VDJ for CHM13v2.0 (S4)
Inputs: MHC, KIR, and VDJ BED files for GRCh38
Outputs: BED files for MHC, KIR, and VDJ on CHM13v2.0
Implementation Notes: Use https://genome.ucsc.edu/cgi-bin/hgLiftOver with the MHC, KID, VCJ BEDs at:  https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/genome-stratifications/v3.1/GRCh38/OtherDifficult/. Can look at examples for GRCh38 at https://github.com/genome-in-a-bottle/genome-stratifications/blob/master/GRCh38/OtherDifficult/GRCh38_Generating_v4.1_excluded_beds.ipynb

