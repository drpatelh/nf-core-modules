process BAMTOOLS_SPLIT {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::bamtools=2.5.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bamtools:2.5.1--h9a82719_9"
    } else {
        container "quay.io/biocontainers/bamtools:2.5.1--h9a82719_9"
    }

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    path "versions.yml"           , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    bamtools \\
        split \\
        -in $bam \\
        $args

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$( bamtools --version | grep -e 'bamtools' | sed 's/^.*bamtools //' )
    END_VERSIONS
    """
}
