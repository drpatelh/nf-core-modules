process BWAMEM2_INDEX {
    tag "$fasta"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::bwa-mem2=2.2.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bwa-mem2:2.2.1--he513fc3_0"
    } else {
        container "quay.io/biocontainers/bwa-mem2:2.2.1--he513fc3_0"
    }

    input:
    path fasta

    output:
    path "bwamem2"      , emit: index
    path "versions.yml" , emit: versions

    script:
    """
    mkdir bwamem2
    bwa-mem2 \\
        index \\
        $options.args \\
        $fasta -p bwamem2/${fasta}

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$(echo \$(bwa-mem2 version 2>&1) | sed 's/.* //')
    END_VERSIONS
    """
}
