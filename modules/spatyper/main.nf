process SPATYPER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::spatyper=0.3.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/spatyper%3A0.3.3--pyhdfd78af_3"
    } else {
        container "quay.io/biocontainers/spatyper:0.3.3--pyhdfd78af_3"
    }

    input:
    tuple val(meta), path(fasta)
    path repeats
    path repeat_order

    output:
    tuple val(meta), path("*.tsv"), emit: tsv
    path "versions.yml"           , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def input_args = repeats && repeat_order ? "-r ${repeats} -o ${repeat_order}" : ""
    """
    spaTyper \\
        $args \\
        $input_args \\
        --fasta $fasta \\
        --output ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$( echo \$(spaTyper --version 2>&1) | sed 's/^.*spaTyper //' )
    END_VERSIONS
    """
}
