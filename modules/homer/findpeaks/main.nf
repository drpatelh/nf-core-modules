def VERSION = '4.11'

process HOMER_FINDPEAKS {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::homer=4.11=pl526hc9558a2_3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/homer:4.11--pl526hc9558a2_3"
    } else {
        container "quay.io/biocontainers/homer:4.11--pl526hc9558a2_3"
    }

    input:
    tuple val(meta), path(tagDir)

    output:
    tuple val(meta), path("*peaks.txt"), emit: txt
    path  "versions.yml"               , emit: versions

    script:
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """

    findPeaks \\
        $tagDir \\
        $args \\
        -o ${prefix}.peaks.txt

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(echo $VERSION)
    END_VERSIONS
    """
}
