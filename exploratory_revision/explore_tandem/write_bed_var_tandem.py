




import sys
chrom= sys.argv[1]
file="GRCh38_AllTandemRepeats.bed"
vcf_file_address= "HG002.hiseqx.pcr-free.40x.deepvariant-v1.0.grch38.vcf"




def read_bed(bed_file):

    file_handle=open(bed_file,"r")
    bed_dic={}
    for line in file_handle:
        values= line.strip().split()
        chrom=values[0]
        start=int(values[1])
        end=int(values[2])
        if chrom in bed_dic:
            bed_dic[chrom].append((start,end))
        else:
            bed_dic[chrom]=[(start,end)]
    print(len(bed_dic),len(bed_dic[chrom]))  
    return bed_dic

bed_dic = read_bed(file)
    


vcf_file = open(vcf_file_address,'r')


variants_dic={}

for line in vcf_file:
    line_strip = line.strip()
    #lines_list.append(line_strip)
    if line_strip.startswith('#'):
        pass
        #header_lines_list.append(line_strip)
        #sample_names = line_strip.split('\t')[9:11]       # last line of header contains sample name
    else:
        line_parts=line_strip.split('\t')
        chrom= line_parts[0]
        var_pos = int(line_parts[1])
        ref = line_parts[3]
        alt = line_parts[4]
        #q,filt,inf = line_parts[5:8]
        #frmat,samp1,samp2 = line_parts[8:11]
        #frmat,bench,samp = line_parts[8:11] #['GT:GQ:DP:AD:VAF:PL', './.:17:380:309,23:0.0605263:0,18,22']
        if "," in alt:
            alt1=alt
            continue
        var_len= abs(len(alt)-len(ref))+1 # if negative is dletion
        if "," in alt: print("here")
        if chrom in variants_dic:
            variants_dic[chrom].append((var_pos,var_len))
        else:
            print(chrom)
            variants_dic[chrom]=[(var_pos,var_len)]
print(len(variants_dic),len(variants_dic[chrom]))        



print(len(variants_dic),len(variants_dic["chr1"]))        




bed_numvars={}


rec_list=bed_dic[chrom]
    
print(chrom,len(rec_list))
#bed_numvars[chrom]={}
variants = variants_dic[chrom]  #(var_pos, var_len)
ii=0
for (rec_st,rec_end) in rec_list: 
    ii+=1
    if ii%200==0:print(ii,rec_st)
    num_var = 0

    for (var_pos,var_len) in variants :
        if rec_st <= var_pos and var_pos+var_len-1 <= rec_end  : # rec0  < var < var+len  <  rec1
            num_var += 1        

    if num_var:
        if num_var in bed_numvars:
            bed_numvars[num_var].append((chrom,rec_st,rec_end))
        else:
            bed_numvars[num_var]=[(chrom,rec_st,rec_end)]


print(len(bed_numvars))
#import pickle
#with open('filename_'+chrom+'.pickle', 'wb') as handle:
#    pickle.dump(bed_numvars, handle, protocol=pickle.HIGHEST_PROTOCOL)

    
bed_numvars_bins={"1":{},"2":{},"3-10":{},"10-30":{},"30-50":{},"50-100":{},"100-":{}}

for num_var, recs in bed_numvars.items():
    if num_var==1 or num_var==2 :
        bin_=str(num_var)
    elif 3<=num_var<10: 
        bin_="3-10"
    elif 10<=num_var<30: 
        bin_="10-30"
    elif 30<=num_var<50: 
        bin_="30-50"
    elif 50<=num_var<100: 
        bin_="50-100"
    elif 100<=num_var: 
        bin_="100-"

    bed_numvars_bins[bin_][num_var]=recs

    
print("bed_numvars_bins", len(bed_numvars_bins))


for bin_, bed_numvars_bin in bed_numvars_bins.items():
    print(bin_)
    file_out= open("numvr_"+str(bin_)+"_"+str(chrom)+".bed",'w')

    for num_var, recs in bed_numvars_bin.items():
        print(num_var)

        for (chrom,rec_st,rec_end) in recs:
            file_out.write(chrom+"\t"+str(rec_st)+"\t"+str(rec_end)+"\t"+str(num_var)+"\n")

    file_out.close()

print("done",chrom)

