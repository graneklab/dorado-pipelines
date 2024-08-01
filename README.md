# Which Pipeline?

- *basecall\_demux\_map*
	- Use this pipeline if you want to map the reads to a reference genome
	- This pipeline currently does not call duplex reads
	- Applications:
		- Identifying methylated bases

- *podsplit\_dorado\_demux*
	- Use this pipeline if you want to do duplex basecalling and don't want to map reads to a reference genome
	- Applications:
		- generating FASTQs for MAG assembly

# How do I run a pipeline?
`dorado-pipelines/basecall_demux_map/main_sbatch.sh PATH_TO_CONFIG_FILE`

or

`dorado-pipelines/podsplit_dorado_demux/main_sbatch.sh PATH_TO_CONFIG_FILE`


# Notes
- The pipelines will sometimes fail at one step. If this happens, try running it again, in general it will resume where it died

