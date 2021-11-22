process NGMASTER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::ngmaster=0.5.8" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/ngmaster:0.5.8--pyhdfd78af_1"
    } else {
        container "quay.io/biocontainers/ngmaster:0.5.8--pyhdfd78af_1"
    }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.tsv"), emit: tsv
    path "versions.yml"           , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    ngmaster \\
        $args \\
        $fasta \\
        > ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$( echo \$(ngmaster --version 2>&1) | sed 's/^.*ngmaster //' )
    END_VERSIONS
    """
}
