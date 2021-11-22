def VERSION = '1.2.2'

process PHANTOMPEAKQUALTOOLS {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::phantompeakqualtools=1.2.2" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/phantompeakqualtools:1.2.2--0"
    } else {
        container "quay.io/biocontainers/phantompeakqualtools:1.2.2--0"
    }

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.out")  , emit: spp
    tuple val(meta), path("*.pdf")  , emit: pdf
    tuple val(meta), path("*.Rdata"), emit: rdata
    path  "versions.yml"            , emit: versions

    script:
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    RUN_SPP=`which run_spp.R`
    Rscript -e "library(caTools); source(\\"\$RUN_SPP\\")" -c="$bam" -savp="${prefix}.spp.pdf" -savd="${prefix}.spp.Rdata" -out="${prefix}.spp.out" -p=$task.cpus
    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(echo $VERSION)
    END_VERSIONS
    """
}
