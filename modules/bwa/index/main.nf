process BWA_INDEX {
    tag "$fasta"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::bwa=0.7.17" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bwa:0.7.17--hed695b0_7"
    } else {
        container "quay.io/biocontainers/bwa:0.7.17--hed695b0_7"
    }

    input:
    path fasta

    output:
    path "bwa"         , emit: index
    path "versions.yml", emit: versions

    script:
    """
    mkdir bwa
    bwa \\
        index \\
        $options.args \\
        -p bwa/${fasta.baseName} \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
    END_VERSIONS
    """
}
