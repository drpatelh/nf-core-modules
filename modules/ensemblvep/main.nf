params.use_cache = false
params.vep_tag = ""

process ENSEMBLVEP {
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::ensembl-vep=104.3" : null)
    if (params.use_cache) {
        container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
            'https://depot.galaxyproject.org/singularity/ensembl-vep:104.3--pl5262h4a94de4_0' :
            'quay.io/biocontainers/ensembl-vep:104.3--pl5262h4a94de4_0' }"
    } else {
        container "nfcore/vep:${params.vep_tag}"
    }

    input:
    tuple val(meta), path(vcf)
    val   genome
    val   species
    val   cache_version
    path  cache

    output:
    tuple val(meta), path("*.ann.vcf"), emit: vcf
    path "*.summary.html"             , emit: report
    path "versions.yml"               , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.suffix ? "${meta.id}${task.ext.suffix}" : "${meta.id}"
    def dir_cache = params.use_cache ? "\${PWD}/${cache}" : "/.vep"
    """
    mkdir $prefix

    vep \\
        -i $vcf \\
        -o ${prefix}.ann.vcf \\
        $args \\
        --assembly $genome \\
        --species $species \\
        --cache \\
        --cache_version $cache_version \\
        --dir_cache $dir_cache \\
        --fork $task.cpus \\
        --format vcf \\
        --stats_file ${prefix}.summary.html

    rm -rf $prefix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ensemblvep: \$( echo \$(vep --help 2>&1) | sed 's/^.*Versions:.*ensembl-vep : //;s/ .*\$//')
    END_VERSIONS
    """
}
