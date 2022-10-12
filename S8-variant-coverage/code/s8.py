import os
import pandas as pd
import gzip
import numpy as np
import matplotlib.pyplot as plt


class S8(object):
    def __init__(self, binsize: int = 1):
        self.binsize = binsize  # will be set to 1 - current data only has a binsize of 10

    def __get_absolute_path(self, input_path):
        return os.path.abspath(os.path.expanduser(input_path))

    def vcf_to_dataframe(self, path):
        vcf_path = self.__get_absolute_path(path)
        vcf_file = open(vcf_path, "r") if "gz" not in vcf_path else gzip.open(vcf_path, "rt")
        line_cnt = 0
        header_cnt = 0

        result = []

        for line in vcf_file:
            if line.__contains__("#"):
                header_cnt += 1
                continue
            cells = line.strip().split("\t")
            chrom_ = cells[0]
            start_ = int(cells[1])
            ref_ = cells[3]
            alt_ = cells[4]
            quality_ = float(cells[5])
            filter_ = cells[6]
            info_ = cells[7]
            format_ = cells[8]
            # sample_ = cells[9]

            if not (ref_.__contains__(",") or alt_.__contains__(",")):
                varient_type = ""
                ins_adjust = 0
                ref_alt_len = len(ref_) - len(alt_)
                if ref_alt_len == 0:
                    varient_type = "SNV"
                elif ref_alt_len > 0:  # ref_ longer
                    varient_type = "DEL"
                elif ref_alt_len < 0:  # alt_ longer
                    varient_type = "INS"
                    ins_adjust = 1
                else:
                    print("error", line)
                    continue
                end_ = start_ + abs(ref_alt_len - ins_adjust) + 1

                result.append([chrom_, start_, end_, varient_type])
        return pd.DataFrame(data=result, columns=["chrom_", "start_", "end_", "var_type"])

    def get_coverage_for_variant(self, mosdepth_file: str = "", vcf_file: str = ""):

        df_vcf_all_chroms = self.vcf_to_dataframe(vcf_file)
        df_vcf_all_chroms_keys = df_vcf_all_chroms.chrom_.unique()

        mosdepth_file = self.__get_absolute_path(mosdepth_file)
        df_coverage_all = pd.read_csv(mosdepth_file, sep="\t", header=None, names=["chrom_", "start_", "end_", "cov_"])
        df_coverage_all_chroms_keys = df_coverage_all.chrom_.unique()

        for vcf_chrom_key in df_vcf_all_chroms_keys:
            # get subset for chrom in vcf
            df_vcf = df_vcf_all_chroms.loc[df_vcf_all_chroms.chrom_ == vcf_chrom_key]

            # check if vcf chrom key exists in mosdepth (coverage) file
            if vcf_chrom_key in df_coverage_all_chroms_keys:
                df_coverage = df_coverage_all.loc[df_coverage_all.chrom_ == vcf_chrom_key]

                # TODO group by chrom
                # TODO set binsize to given value
                self.cov_list = df_coverage.cov_.tolist()  # use list instead of pandas row, index = index/binsize
                self.cnt = 0

                df_vcf["distance_"] = df_vcf.apply(lambda row: int(abs(row["end_"] - row["start_"]) / self.binsize) + 1,
                                                   axis=1)
                df_vcf["coverage_"] = df_vcf.apply(lambda row: self.get_mean(row["start_"], row["distance_"]), axis=1)
                df_vcf["bingroup_"] = df_vcf.apply(lambda row: int(((row["distance_"] - 1) / 10) + 1) * 10,
                                                   axis=1)  # calculate bp bin groups, 1-10=10, 11-20=20, ...

                for sv_type in df_vcf.var_type.unique():
                    df_data = df_vcf.loc[df_vcf.var_type == sv_type]
                    df_subset = df_data[["coverage_", "bingroup_"]]
                    # plt.hist(data=df_subset,x="bingroup_")
                    # plt.show()
                    df_grouped = df_subset.groupby("bingroup_")
                    df_mean = df_grouped.mean()
                    df_mean.plot(kind="bar")
                    plt.title(f"{str(vcf_chrom_key)}: average mean {str(sv_type)}")
                    plt.xlabel("binsize")
                    plt.ylabel("mean coverage")
                    plt.savefig(f"./data/{vcf_chrom_key}_{sv_type}.png")

                # df_vcf["coverage"] = vcf_coverage_list
                pass

    def get_mean(self, start, distance):
        s = int(start / self.binsize)
        x = self.cov_list[s:s + distance]
        tmp = np.mean(x)
        self.cnt += 1
        if np.isnan(tmp):
            return 0.0
        return tmp


if __name__ == '__main__':
    df = pd.DataFrame(data=[], columns=["a"])
    x = df.a.mean()

    s8 = S8(binsize=10)  # 10 for testing
    s8.get_coverage_for_variant(mosdepth_file=r"./data/coverage_chr22_only.bed",
                                vcf_file=r"./data/HG002.hiseqx.grch38_chr22.vcf")
