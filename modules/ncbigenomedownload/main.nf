process NCBIGENOMEDOWNLOAD {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::ncbi-genome-download=0.3.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/ncbi-genome-download:0.3.0--pyh864c0ab_1"
    } else {
        container "quay.io/biocontainers/ncbi-genome-download:0.3.0--pyh864c0ab_1"
    }

    input:
    val meta
    path accessions

    output:
    tuple val(meta), path("*_genomic.gbff.gz")        , emit: gbk     , optional: true
    tuple val(meta), path("*_genomic.fna.gz")         , emit: fna     , optional: true
    tuple val(meta), path("*_rm.out.gz")              , emit: rm      , optional: true
    tuple val(meta), path("*_feature_table.txt.gz")   , emit: features, optional: true
    tuple val(meta), path("*_genomic.gff.gz")         , emit: gff     , optional: true
    tuple val(meta), path("*_protein.faa.gz")         , emit: faa     , optional: true
    tuple val(meta), path("*_protein.gpff.gz")        , emit: gpff    , optional: true
    tuple val(meta), path("*_wgsmaster.gbff.gz")      , emit: wgs_gbk , optional: true
    tuple val(meta), path("*_cds_from_genomic.fna.gz"), emit: cds     , optional: true
    tuple val(meta), path("*_rna.fna.gz")             , emit: rna     , optional: true
    tuple val(meta), path("*_rna_from_genomic.fna.gz"), emit: rna_fna , optional: true
    tuple val(meta), path("*_assembly_report.txt")    , emit: report  , optional: true
    tuple val(meta), path("*_assembly_stats.txt")     , emit: stats   , optional: true
    path "versions.yml"                               , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def accessions_opt = accessions ? "-A ${accessions}" : ""
    """
    ncbi-genome-download \\
        $args \\
        $accessions_opt \\
        --output-folder ./ \\
        --flat-output

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        ${getSoftwareName(task.process)}: \$( ncbi-genome-download --version )
    END_VERSIONS
    """
}
