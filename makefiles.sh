#must upload final gzipped CCR file to S3 before this
if [ ! -s gnomadbased-ccrs.bed.gz ]; then
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.bed.gz
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.bed.gz.tbi
fi
zcat ~/analysis/essentials/gnomadbased-ccrs.bed.gz | sort -k14,14nr | awk 'BEGIN{key=""; val=0} {{if (key !=$4 $7) val+=1} print $0 "\t" val; key=$4 $7}' | cut -f -4,7-8,10- | sort -k1,1 -k2,2n | cat <(printf "chrom\tstart\tend\tgene\tranges\tvarflag\tcpg\tcov_score\tresid\tresid_pctile\tccr_pct\tunique_key\n") - | bgzip -c > ccrs.bed.gz
zcat ccrs.bed.gz | sed '1d' | sed 's/^/chr/g' | awk '{print $1,$2,$3,$11}' OFS="\t" | bedtools merge -d -1 -c 4 -o mean > ccrs.bedGraph
bgzip -c ccrs.bedGraph > ccrs.bedGraph.gz; tabix -b 2 -e 3 ccrs.bedGraph.gz
bedGraphToBigWig ccrs.bedGraph hg19.chrom.sizes ccrs.bw