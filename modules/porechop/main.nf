process PORECHOP {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::porechop=0.2.4" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/porechop:0.2.4--py39h7cff6ad_2"
    } else {
        container "quay.io/biocontainers/porechop:0.2.4--py38h8c62d01_2"
    }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq.gz")  , emit: reads
    path "versions.yml"                          , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    porechop \\
        -i ${reads} \\
        -t ${task.cpus} \\
        ${options.args} \\
        -o ${prefix}.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$( porechop --version )
    END_VERSIONS
    """
}
