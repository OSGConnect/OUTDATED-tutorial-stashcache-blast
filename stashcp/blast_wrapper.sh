#!/bin/bash

module load stashcp
module load blast

set -e

stashcp /user/eharstad/public/blast_database_old/nt.fa .
stashcp /user/eharstad/public/blast_database_old/nt.fa.nhr .
stashcp /user/eharstad/public/blast_database_old/nt.fa.nin .
stashcp /user/eharstad/public/blast_database_old/nt.fa.nsq .

"$@"
