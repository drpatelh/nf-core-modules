def VERSION = '0.1' // Version information not provided by tool on CLI

process CHROMAP_CHROMAP {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::chromap=0.1 bioconda::samtools=1.13" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-1f09f39f20b1c4ee36581dc81cc323c70e661633:2cad7c5aa775241887eff8714259714a39baf016-0' :
        'quay.io/biocontainers/mulled-v2-1f09f39f20b1c4ee36581dc81cc323c70e661633:2cad7c5aa775241887eff8714259714a39baf016-0' }"

    input:
    tuple val(meta), path(reads)
    path fasta
    path index
    path barcodes
    path whitelist
    path chr_order
    path pairs_chr_order

    output:
    tuple val(meta), path("*.bed.gz")     , optional:true, emit: bed
    tuple val(meta), path("*.bam")        , optional:true, emit: bam
    tuple val(meta), path("*.tagAlign.gz"), optional:true, emit: tagAlign
    tuple val(meta), path("*.pairs.gz")   , optional:true, emit: pairs
    path "versions.yml"                                  , emit: versions

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def args_list = args.tokenize()

    def file_extension = args.contains("--SAM") ? 'sam' : args.contains("--TagAlign")? 'tagAlign' : args.contains("--pairs")? 'pairs' : 'bed'
    if (barcodes) {
        args_list << "-b ${barcodes.join(',')}"
        if (whitelist) {
            args_list << "--barcode-whitelist $whitelist"
        }
    }
    if (chr_order) {
        args_list << "--chr-order $chr_order"
    }
    if (pairs_chr_order){
        args_list << "--pairs-natural-chr-order $pairs_chr_order"
    }
    def final_args = args_list.join(' ')
    def compression_cmds = "gzip ${prefix}.${file_extension}"
    if (args.contains("--SAM")) {
        compression_cmds = """
        samtools view $args2 -@ $task.cpus -bh \\
            -o ${prefix}.bam ${prefix}.${file_extension}
        rm ${prefix}.${file_extension}
        """
    }
    if (meta.single_end) {
        """
        chromap \\
            $final_args \\
            -t $task.cpus \\
            -x $index \\
            -r $fasta \\
            -1 ${reads.join(',')} \\
            -o ${prefix}.${file_extension}

        $compression_cmds

        cat <<-END_VERSIONS > versions.yml
        ${task.process.tokenize(':').last()}:
            chromap: $VERSION
        END_VERSIONS
        """
    } else {
        """
        chromap \\
            $final_args \\
            -t $task.cpus \\
            -x $index \\
            -r $fasta \\
            -1 ${reads[0]} \\
            -2 ${reads[1]} \\
            -o ${prefix}.${file_extension}

        $compression_cmds

        cat <<-END_VERSIONS > versions.yml
        ${task.process.tokenize(':').last()}:
            chromap: $VERSION
        END_VERSIONS
        """
    }
}
