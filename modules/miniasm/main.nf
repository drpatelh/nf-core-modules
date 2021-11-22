process MINIASM {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::miniasm=0.3_r179" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/miniasm:0.3_r179--h5bf99c6_2' :
        'quay.io/biocontainers/miniasm:0.3_r179--h5bf99c6_2' }"

    input:
    tuple val(meta), path(reads), path(paf)

    output:
    tuple val(meta), path("*.gfa.gz")  , emit: gfa
    tuple val(meta), path("*.fasta.gz"), emit: assembly
    path "versions.yml"                , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    miniasm \\
        $args \\
        -f $reads \\
        $paf > \\
        ${prefix}.gfa

    awk '/^S/{print ">"\$2"\\n"\$3}' "${prefix}.gfa" | fold > ${prefix}.fasta

    gzip -n ${prefix}.gfa
    gzip -n ${prefix}.fasta

    cat <<-END_VERSIONS > versions.yml
    ${task.process.tokenize(':').last()}:
        ${getSoftwareName(task.process)}: \$( miniasm -V 2>&1 )
    END_VERSIONS
    """
}
