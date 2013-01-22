#!/bin/sh

# PARSE INPUT
# Default to 'VietorisRips'
# unless 'lazywitness' specified
if [ "$1" ]
then
    stream_type=$1
else
    stream_type=VietorisRips
fi

# JOB PARAMETERS
data_type=phage.s277
dist_type=newmatrix3
stream_type=VietorisRips
num_div=1000000000
maxfilt=100
ratio=1
max_dim=2
job_name=$data_type.$dist_type

# BUILD DIRECTORIES
d1=`pwd`
datestr=`date "+%y%m%d"`
run_dir=$d1/../cache/`date +%s`-$job_name.$datestr.R$ratio.MF$maxfilt.DIV$num_div.DIM$max_dim
log_dir=$run_dir/log
src_dir=$run_dir/src
out_dir=$run_dir/output
mkdir -p $run_dir
mkdir -p $log_dir
mkdir -p $src_dir
mkdir -p $out_dir
mkdir -p $src_dir/javaplex

# LOGFILES
ef=$log_dir/e'.$JOB_ID'
of=$log_dir/o'.$JOB_ID'
if [ -n "$(ls -A $log_dir)" ]; then
    rm $log_dir/*
fi

# HEAP SIZE
# m=8G, t=1::; echo -Xmx7000M > $src_dir/java.opts
# m=16G, t=2::; echo -Xmx14000M > $src_dir/java.opts
# m=32G; t=1::; echo -Xmx30000M > $src_dir/java.opts
m=64G; t=2::; echo -Xmx62000M > $src_dir/java.opts
#m=128G, t=3::; echo -Xmx122000M > $src_dir/java.opts
# m=192G; t=2::; echo -Xmx190000m > $src_dir/java.opts

# COPY DATA FILE
cp $d1/../data/$job_name.csv $run_dir/

# COPY ANNOTATION AND POSTPROCESSING FILES
#cp $d1/../data/$data_type.idx.annotations.txt $run_dir/
# cp $d1/parse_betti_info.py $src_dir

# COPY SRC FILE
cp $d1/matlab/RunBarcode_dist.m $src_dir; cp $d1/javaplex/load_javaplex.m $src_dir/javaplex; cp -r $d1/javaplex/lib $src_dir/javaplex; cp -r $d1/javaplex/utility $src_dir/javaplex;

# QSUB JOB
echo job_name=$job_name
echo stream_type=$stream_type
qsub -l mem=${m},time=${t} -R y -V -N j`date +%s` -e $ef -o $of $d1/qsub.RunBarcode.sh $data_type $dist_type $run_dir $out_dir $ratio $maxfilt $max_dim $num_div $stream_type
