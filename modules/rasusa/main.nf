process RASUSA {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::rasusa=0.3.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/rasusa:0.3.0--h779adbc_1"
    } else {
        container "quay.io/biocontainers/rasusa:0.3.0--h779adbc_1"
    }

    input:
    tuple val(meta), path(reads), val(genome_size)
    val   depth_cutoff

    output:
    tuple val(meta), path('*.fastq.gz'), emit: reads
    path "versions.yml"                , emit: versions

    script:
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def output   = meta.single_end ? "--output ${prefix}.fastq.gz" : "--output ${prefix}_1.fastq.gz ${prefix}_2.fastq.gz"
    """
    rasusa \\
        $options.args \\
        --coverage $depth_cutoff \\
        --genome-size $genome_size \\
        --input $reads \\
        $output
    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(rasusa --version 2>&1 | sed -e "s/rasusa //g")
    END_VERSIONS
    """
}
