process AGILE1CH {
  publishDir "${ params.outputDir }/${ params.gldsAccession }/GeneLab",
    pattern: "Agile1CMP.html",
    mode: params.publish_dir_mode
  stageInMode 'copy'

  input:
    path(qmd) // quarto qmd file to render
    path(runsheet_csv) // runsheet to supply as parameter
    path(annotation_file_path) // runsheet to supply as parameter
    val(organism) // runsheet to supply as parameter
    val(limit_biomart_query) // DEBUG option, limits biomart queries to the number specified if not set to false

  output:
    path("Agile1CMP.html"), emit: report

    tuple path("02-limma_DGE/contrasts.csv"),
          path("02-limma_DGE/SampleTable.csv"),
          path("02-limma_DGE/differential_expression.csv"),
          path("02-limma_DGE/visualization_PCA_table.csv"),
          path("01-limma_NormExp/normalized_expression.csv"),
          path("00-RawData/raw_intensities.csv"), emit: de

    path("versions.yml"), emit: versions 

  script:
    def limit_biomart_query_parameter = limit_biomart_query ? "-P DEBUG_limit_biomart_query:${limit_biomart_query}" : ''
    """
        quarto render \$PWD/${qmd} \
            -P 'runsheet:${runsheet_csv}' \
            -P 'annotation_file_path:${annotation_file_path}' \
            -P 'organism:${organism}' \
            ${limit_biomart_query_parameter}

        echo "- quarto: \$(quarto --version)" >> versions.yml
    """
}