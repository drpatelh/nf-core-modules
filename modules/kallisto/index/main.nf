process KALLISTO_INDEX {
    tag "$fasta"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::kallisto=0.46.2" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/kallisto:0.46.2--h4f7b962_1"
    } else {
        container "quay.io/biocontainers/kallisto:0.46.2--h4f7b962_1"
    }

    input:
    path fasta

    output:
    path "kallisto" , emit: idx
    path "versions.yml" , emit: versions

    script:
    """
    kallisto \\
        index \\
        $options.args \\
        -i kallisto \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(echo \$(kallisto 2>&1) | sed 's/^kallisto //; s/Usage.*\$//')
    END_VERSIONS
    """
}
