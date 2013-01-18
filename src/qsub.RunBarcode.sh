#!/bin/bash
#$ -S /bin/sh
#$ -cwd

######################################
time1=$( date "+%s" )
echo `pwd`
echo BEGIN `date`
echo MACHINE `hostname`
######################################

data_type=$1
dist_type=$2
run_dir=$3
output_dir=$4
ratio=$5
max_filt=$6
max_dim=$7
num_div=$8
stream_type=$9

job_name=$data_type.$dist_type

echo stream_type=$stream_type
cd $idir/src

/nfs/apps/matlab/current/bin/matlab -nodisplay -r "RunBarcode_dist('$job_name','$run_dir', '$stream_type', '$num_div', '$max_filt', '$max_dim', '$ratio'); exit;"
# python parse_betti_info.py -S $data_type -D $dist_type -I $idir


########################################
echo END `date`
time2=$( date "+%s" )
echo [deltat] $(( $time2 - $time1 ))
########################################
