process NUCMER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::mummer=3.23" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/mummer:3.23--pl5262h1b792b2_12"
    } else {
        container "quay.io/biocontainers/mummer:3.23--pl5262h1b792b2_12"
    }

    input:
    tuple val(meta), path(ref), path(query)

    output:
    tuple val(meta), path("*.delta") , emit: delta
    tuple val(meta), path("*.coords"), emit: coords
    path "versions.yml"              , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def is_compressed_ref   = ref.getName().endsWith(".gz")   ? true : false
    def is_compressed_query = query.getName().endsWith(".gz") ? true : false
    def fasta_name_ref      = ref.getName().replace(".gz", "")
    def fasta_name_query    = query.getName().replace(".gz", "")
    """
    if [ "$is_compressed_ref" == "true" ]; then
        gzip -c -d $ref > $fasta_name_ref
    fi
    if [ "$is_compressed_query" == "true" ]; then
        gzip -c -d $query > $fasta_name_query
    fi

    nucmer \\
        -p $prefix \\
        --coords \\
        $options.args \\
        $fasta_name_ref \\
        $fasta_name_query

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$( nucmer --version 2>&1  | grep "version" | sed -e "s/NUCmer (NUCleotide MUMmer) version //g; s/nucmer//g;" )
    END_VERSIONS
    """
}
