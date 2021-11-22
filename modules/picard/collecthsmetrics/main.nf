process PICARD_COLLECTHSMETRICS {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::picard=2.26.2" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/picard:2.26.2--hdfd78af_0"
    } else {
        container "quay.io/biocontainers/picard:2.26.2--hdfd78af_0"
    }

    input:
    tuple val(meta), path(bam)
    path fasta
    path fai
    path bait_intervals
    path target_intervals

    output:
    tuple val(meta), path("*collecthsmetrics.txt"), emit: hs_metrics
    path "versions.yml"                           , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def reference = fasta ? "-R $fasta" : ""

    def avail_mem = 3
    if (!task.memory) {
        log.info '[Picard CollectHsMetrics] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    picard \\
        -Xmx${avail_mem}g \\
        CollectHsMetrics \\
        $args \\
        $reference \\
        -BAIT_INTERVALS $bait_intervals \\
        -TARGET_INTERVALS $target_intervals \\
        -INPUT $bam \\
        -OUTPUT ${prefix}_collecthsmetrics.txt

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(echo \$(picard CollectHsMetrics --version 2>&1) | grep -o 'Version:.*' | cut -f2- -d:)
    END_VERSIONS
    """
}
