[title]: - "StashCache-Blast"
[TOC]
 
## Overview

This tutorial will use a [BLAST](http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastHome) workflow to demonstrate the functionality of StashCache for transferring input files to active jobs.  BLAST (Basic Local Alignment Search Tool) is an open-source bioinformatics tool developed by the NCBI that searches for alignments between query sequences and a genetic database. 

The input files for a BLAST job include:

* one or more query files
* one or more genetic database files
* database index files

In this exercise, the database is contained in a single 1.3 GB file, and the query is divided into 2 files of approximately 7.5 MB each (small enough to use the HT Condor file transfer mechanism). Each query must be compared to the database file using BLAST, so 2 jobs are needed in this workflow.  If BLAST jobs have an excessively long run time, it is also possible to subdivide the database file to shorten job duration and increase the total number of jobs required. 

Even when subdivided into smaller segments for use in a High Throughput Computing environment, the database files can still be quite large.  Due to its size (1.3 GB) and the fact that it is used for multiple jobs, the database file and corresponding index files will be transferred to the compute sites using StashCache, which takes advantage of proxy caching to improve transfer speed and efficiency.  Learn more about StashCache and basic usage instructions [here](https://support.opensciencegrid.org/solution/articles/12000002775-introduction-to-stashcache).

## Tutorial Instructions

1) First log into the OSG Connect submit host (login.osgconnect.net), download the tutorial files using the *tutorial* command, and cd into the newly created directory:

	$ tutorial stashcache-blast
	$ cd tutorial-stashcache-blast

2) The tutorial-stashcache-blast directory contains a number of files, described below:

* HT Condor submit script: **blast.submit**
* Job wrapper script: **blast_wrapper.sh**
* Query files: **query_0.fa  query_1.fa**

In addition to these files, the following input files are needed for the jobs:
* database file: **nt.fa**
* database index files: **nt.fa.nhr  nt.fa.nin  nt.fa.nsq**

These files are currently being stored in */stash2/user/eharstad/public/blast_database/*.  In step 3 (below), you will copy them into your own stash directory before submitting the job. 

***
First, let's take a look a the HT Condor job submission script:

	$ cat blast.submit

     	universe = vanilla

     	executable = blast_wrapper.sh
     	arguments  = blastn -db nt.fa -query ../query_$(Process).fa
     	should_transfer_files = YES
     	when_to_transfer_output = ON_EXIT
     	transfer_input_files = query_$(Process).fa

     	requirements = (CVMFS_oasis_opensciencegrid_org_REVISION >= 3600) && (OpSysMajorVer == 6)
     	request_disk = 2G
     	+WantsStashCache = true

     	output = job.out.$(Cluster).$(Process)
     	error = job.err.$(Cluster).$(Process)
     	log = job.log.$(Cluster).$(Process)
 
     	queue 2

The executable for this job is a wrapper script (*blast_wrapper.sh*) that takes as arguments the blast command that we want to run on the compute host.  We specify which query file we want transferred (using HT Condor) to each job site with the *transfer_input_files* command.  This job also requires OASIS, and at lest 2 GB of disk space for input files, which we specify with the *requirements* and *request_disk* commands.  

Note the one additional line that is required in the submit script of any job that uses StashCache:

	+WantsStashCache = true

Finally, since there are 2 query files we queue 2 jobs with the *queue 2* command.  Because we have used the $(Process) macro in the name of the query input files, only one query file will be transferred to each job.

***
Now, let's take a look at the job wrapper script which is the job's executable:

	$ cat blast_wrapper.sh

	#!/bin/bash
     	source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/5.6.2/init/bash
     	module load blast
     	module load stashcp

     	stashcp -r -s user/userid/blast_database -l .
     	cd blast_database

     	"$@"

We first source the initialization script for the OASIS modules.  Next, the wrapper script loads the blast and stashcp modules so that it can access the software on the compute host.

The stashcp tool is used to copy the directory containing our blast database and index files from stash to the current working directory on the host:
     
	stashcp -r -s user/userid/blast_database -l .

(For more information on using StashCache and stashcp, see [Introduction to StashCache](https://support.opensciencegrid.org/solution/articles/12000002775-introduction-to-stashcache).)

Finally, we cd into the directory containing the Blast database and execute the Blast command that is read into this script as a list of arguments (provided in the submit script).  

3)  Stashcp copies database files from your stash storage space to the compute site where your job runs.  Therefore, before submitting these jobs, you must copy the database files from their currently location into your own stash directory:

On the osgconnect login node:

	$ cp -r /stash2/user/eharstad/public/blast_database ~/stash/.

4) Open up blast_wrapper.sh with a text editor, and edit the line with the stashcp command by replacing 'userid' with your actual OSG Connect userid. 

Edit this line:

	stashcp -r -s user/userid/data -l . 

Save your changes and close the file. 

4) You are now ready to submit the jobs:

	$ condor_submit blast.submit

5) Each job should run for approximately 3-5 minutes.  You can monitor the jobs with the condor_q command:

	$ condor_q <userid>

## Getting Help

For assistance or questions, please email the OSG User Support team  at [user-support@opensciencegrid.org](mailto:user-support@opensciencegrid.org) or visit the [help desk and community forums](http://support.opensciencegrid.org).
