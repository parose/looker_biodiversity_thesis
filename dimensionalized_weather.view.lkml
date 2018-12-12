# If necessary, uncomment the line below to include explore_source.
# include: "andrew_thesis.model.lkml"

view: dimensionalized_weather {
  derived_table: {
    explore_source: park_weather {
      column: park_name { field: parks.park_name }
      column: average_temperature { field: gsod.average_temperature }
      column: total_precipitation { field: gsod.total_precipitation }
      column: total_snow_inches { field: gsod.total_snow_inches }
      column: total_rainfall { field: gsod.total_rainfall }
    }
  }
  dimension: park_name {}
  dimension: average_temperature {
    label: "Average Temperature"
    value_format: "#,##0.00"
    type: number
    sql: CAST(${TABLE}.average_temperature as STRING) ;;
  }
  dimension: total_precipitation {
    label: "Total Precipitation"
    type: number
    sql: CAST(${TABLE}.total_precipitation as STRING) ;;
  }
  dimension: total_snow_inches {
    label: "Total Snow Inches"
    value_format: "#,##0.00"
    type: number
  }
  dimension: total_rainfall {
    label: "Total Rainfall"
    value_format: "#,##0.00"
    type: number
    sql: CAST(${TABLE}.total_rainfall as STRING) ;;
  }
}
