process GENMAP_INDEX {
    tag '$fasta'
    label 'process_high'

    conda (params.enable_conda ? "bioconda::genmap=1.3.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/genmap:1.3.0--h1b792b2_1"
    } else {
        container "quay.io/biocontainers/genmap:1.3.0--h1b792b2_1"
    }

    input:
    path fasta

    output:
    path "genmap"       , emit: index
    path "versions.yml" , emit: versions

    script:
    """
    genmap \\
        index \\
        -F $fasta \\
        -I genmap

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(genmap --version 2>&1 | sed 's/GenMap version: //; s/SeqAn.*\$//')
    END_VERSIONS
    """
}
