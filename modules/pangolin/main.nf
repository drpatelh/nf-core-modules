process PANGOLIN {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::pangolin=3.1.11' : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container 'https://depot.galaxyproject.org/singularity/pangolin:3.1.11--pyhdfd78af_1'
    } else {
        container 'quay.io/biocontainers/pangolin:3.1.11--pyhdfd78af_1'
    }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.csv'), emit: report
    path  "versions.yml"          , emit: versions

    script:
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    pangolin \\
        $fasta\\
        --outfile ${prefix}.pangolin.csv \\
        --threads $task.cpus \\
        $options.args

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(pangolin --version | sed "s/pangolin //g")
    END_VERSIONS
    """
}
