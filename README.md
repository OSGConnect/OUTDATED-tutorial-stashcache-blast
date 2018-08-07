[title]: - "StashCache-Blast"
[TOC]
 
## Overview

This tutorial will use a [BLAST](http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastHome) workflow to demonstrate the functionality of StashCache for transferring input files to active job sites.  BLAST (Basic Local Alignment Search Tool) is an open-source bioinformatics tool developed by the NCBI that searches for alignments between query sequences and a genetic database. 

The input files for a BLAST job include:

* one or more query files
* genetic database file
* database index files

In this exercise, the database is contained in a single 1.3 GB file, and the query is divided into 2 files of approximately 7.5 MB each (small enough to use the HTCondor file transfer mechanism). Each query must be compared to the database file using BLAST, so 2 jobs are needed in this workflow.  If BLAST jobs have an excessively long run time, the query files can be further subdivided into smaller segments.

Usually, the database files used with BLAST are quite large.  Due to its size (1.3 GB) and the fact that it is used for multiple jobs, the database file and corresponding index files will be transferred to the compute sites using StashCache, which takes advantage of proxy caching to improve transfer speed and efficiency.  Learn more about StashCache and basic usage instructions [here](https://support.opensciencegrid.org/solution/articles/12000002775-introduction-to-stashcache).

## Tutorial Instructions

1) First log into the OSG Connect submit host (login.osgconnect.net), download the tutorial files using the *tutorial* command, and cd into the newly created directory:

	$ tutorial stashcache-blast
	$ cd tutorial-stashcache-blast

2) The tutorial-stashcache-blast directory contains a number of files, described below:

* HTCondor submit script: **blast.submit**
* Job wrapper script: **blast_wrapper.sh**
* Query files: **query_0.fa  query_1.fa**

In addition to these files, the following input files are needed for the jobs:
* database file: **nt.fa**
* database index files: **nt.fa.nhr  nt.fa.nin  nt.fa.nsq**

These files are currently being stored in `/cvmfs/stash.osgstorage.org/user/eharstad/public/blast_database_old/`.  Please note that these database files are for demo purposes only!!!!!  They have not been updated and should not be used to run actual analyses.

***
First, let's take a look at the HTCondor job submission script:

	$ cat blast.submit
	universe = vanilla
	
	executable = blast_wrapper.sh
	arguments  = blastn -db /cvmfs/stash.osgstorage.org/user/eharstad/public/blast_database_old/nt.fa -query $(queryfile)
	should_transfer_files = YES
	when_to_transfer_output = ON_EXIT
	transfer_input_files = $(queryfile)
	
    requirements = OSGVO_OS_STRING == "RHEL 6" && Arch == "X86_64" && HAS_MODULES == True && HAS_CVMFS_stash_osgstorage_org == True
	
	output = job.out.$(Cluster).$(Process)
	error = job.err.$(Cluster).$(Process)
	log = job.log.$(Cluster).$(Process)
	
	# For each file matching query*.fa, submit a job
	queue queryfile matching query*.fa

The executable for this job is a wrapper script, `blast_wrapper.sh`, that takes as arguments the blast command that we want to run on the compute host.  We specify which query file we want transferred (using HTCondor) to each job site with the *transfer_input_files* command.

Finally, since there are multiple query files, we submit them with the command `queue queryfile matching query*.fa` command.  Because we have used the $(queryfile) macro in the name of the query input files, only one query file will be transferred to each job.

***
Now, let's take a look at the job wrapper script which is the job's executable:

	$ cat blast_wrapper.sh
	#!/bin/bash
	# Load the blast module
	module load blast

    set -e
	
	"$@"

The wrapper script loads the blast modules so that it can access the Blast software on the compute host.

You are now ready to submit the jobs:

	$ condor_submit blast.submit

 Each job should run for approximately 3-5 minutes.  You can monitor the jobs with the condor_q command:

	$ condor_q <userid>

## Getting Help

For assistance or questions, please email the OSG User Support team  at [user-support@opensciencegrid.org](mailto:user-support@opensciencegrid.org) or visit the [help desk and community forums](http://support.opensciencegrid.org).
