


# how to run
# python code_bed.py  HG002.hiseqx.pcr-free.40x.dedup.grch38.regions.bed



import sys
import matplotlib.pyplot as plt
import numpy as np

print("started")
mosdepth_file= sys.argv[1]
file_handl=open(mosdepth_file,"r")
depth_chr_all=[]
depth_chr=[]
chrom=""
chrom_prev=" "
chrom_list=[]
for line in file_handl:
    values= line.strip().split()
    chrom=values[0]
    depth=float(values[3])
    if chrom[:3]!="chr" or chrom[3]!="U" :
        continue
    if chrom == chrom_prev:
        depth_chr.append(depth)
    else:
        
        
        if depth_chr:
            print(chrom_prev, " is read")
            chrom_list.append(chrom_prev)
            depth_chr_all.append(depth_chr)  
        depth_chr=[depth]
    chrom_prev= chrom
    
print(chrom_prev, " is read")
depth_chr_all.append(depth_chr)        
       

print(len(depth_chr_all), len(depth_chr), depth_chr[19000*1000:19000*1000+10])


bin_size = 100
for depth_thresh1, depth_thresh2 in [(0,20),(20,40),(40,60),(60,80),(80,100000)]  : 
    print(depth_thresh1, depth_thresh2)
    file_out= open("coverag_"+str(depth_thresh1)+"_"+str(depth_thresh2)+".bed",'w') # "_"+chrm+
    for chr_idx, chrom in enumerate(chrom_list):
        depth_chr= depth_chr_all[chr_idx]
        print(chrom)
        chr_size=len(depth_chr)
        bin_num = int(chr_size/bin_size)   # ignoring last incomplete bin    
        #regions_cov = []
        for bin_idx in range(bin_num):  # bin_num # ignoring last incomplete bin
            bin_coordinate = (bin_idx*bin_size, (bin_idx+1)*bin_size-1)
            bin_region = range(bin_coordinate[0],bin_coordinate[1]+1)
            depth_bin = [depth_chr[jj] for jj in  bin_region]
            depth_avg = np.mean(depth_bin)
            if depth_thresh1 <= depth_avg < depth_thresh2:
                #regions_cov.append([bin_coordinate,depth_avg])
                file_out.write(chrom+"\t"+str(bin_coordinate[0])+"\t"+str(bin_coordinate[1])+"\t"+str(depth_avg)+"\n")


        #print(len(regions_cov),depth_avg)
        #for [bin_coordinate,depth_avg] in regions_cov:
        #    file_out.write(chrom+"\t"+str(bin_coordinate[0])+"\t"+str(bin_coordinate[1])+"\t"+str(depth_avg)+"\n")

    file_out.close()                


print("done") 
#plt.hist(depth_chr,bins=1000)
#plt.xscale('log')
#plt.yscale('log')
#plt.show()
#plt.savefig('hist.pdf')
