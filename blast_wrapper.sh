#!/bin/bash
source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/5.6.2/init/bash
module load blast
module load stashcp

stashcp -r -s user/userid/blast_database -l .
cd blast_database

"$@"

