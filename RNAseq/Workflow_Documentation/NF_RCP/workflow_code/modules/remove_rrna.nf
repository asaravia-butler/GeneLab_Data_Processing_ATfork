process REMOVE_RRNA {
    /**
     * Filters a RSEM `genes.results` file by removing rRNA gene IDs
     * and counts the number of rRNA genes removed.
     *
     * Inputs:
     *   meta: Metadata with the sample ID.
     *   rrna_ids_file: Path to the file containing rRNA IDs (generated by `EXTRACT_RRNA`).
     *   genes_results_file: Path to the input `genes.results` file.
     *
     * Outputs:
     *   Filtered gene results file (rRNA removed).
     *   rRNA count summary file.
     */

    tag "Sample: ${meta.id}"

    input:
        val meta
        path rrna_ids_file
        path genes_results_file

    output:
        path("${meta.id}_rRNA_removed.genes.results"), emit: genes_results_rrnarm
        path("${meta.id}_rRNA_counts.txt"), emit: rrnarm_summary

    script:
        """
        # Define output file names
        filtered_file="${meta.id}_rRNA_removed.genes.results"
        counts_file="${meta.id}_rRNA_counts.txt"

        echo "Processing: ${meta.id}"

        # Filter rRNA entries
        awk 'NR==FNR {ids[\$1]=1; next} !(\$1 in ids)' ${rrna_ids_file} ${genes_results_file} > \${filtered_file}

        # Count rRNA entries
        rRNA_count=\$(awk 'NR==FNR {ids[\$1]=1; next} \$1 in ids' ${rrna_ids_file} ${genes_results_file} | wc -l)
        echo "${meta.id}: \${rRNA_count} rRNA entries removed." > \${counts_file}
        """
}