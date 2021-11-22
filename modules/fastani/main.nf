process FASTANI {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::fastani=1.32" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/fastani:1.32--he1c1bb9_0"
    } else {
        container "quay.io/biocontainers/fastani:1.32--he1c1bb9_0"
    }

    input:
    tuple val(meta), path(query)
    path reference

    output:
    tuple val(meta), path("*.ani.txt"), emit: ani
    path "versions.yml"               , emit: versions

    script:
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    if (meta.batch_input) {
        """
        fastANI \\
            -ql $query \\
            -rl $reference \\
            -o ${prefix}.ani.txt

        cat <<-END_VERSIONS > versions.yml
        ${getProcessName(task.process)}:
            ${getSoftwareName(task.process)}: \$(fastANI --version 2>&1 | sed 's/version//;')
        END_VERSIONS
        """
    } else {
        """
        fastANI \\
            -q $query \\
            -r $reference \\
            -o ${prefix}.ani.txt

        cat <<-END_VERSIONS > versions.yml
        ${getProcessName(task.process)}:
            ${getSoftwareName(task.process)}: \$(fastANI --version 2>&1 | sed 's/version//;')
        END_VERSIONS
        """
    }
}
