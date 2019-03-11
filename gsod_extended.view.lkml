include: "/datablocks_gsod_bq/bigquery*.view"

view: gsod_extended {
  extends: [bq_gsod]

  measure: average_precipitation {
    type: number
    sql: ${average_rainfall} + ${average_snow_inches} ;;
  }

  measure: total_precipitation {
    type: number
    sql: ${total_rainfall} + ${total_snow_inches} ;;
  }
}
