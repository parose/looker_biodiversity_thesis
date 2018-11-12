view: parks {
  sql_table_name: biodiversity_in_parks.parks ;;

  dimension: latitude {
    hidden: yes
    type: number
    sql: ${TABLE}.Latitude ;;
  }

  dimension: longitude {
    hidden: yes
    type: number
    sql: ${TABLE}.Longitude ;;
  }

  dimension: park_location {
    type: location
    sql_latitude: ${TABLE}.Latitude ;;
    sql_longitude: ${TABLE}.Longitude ;;
  }

  dimension: park_acres {
    type: number
    sql: ${TABLE}.Park_Acres ;;
  }

  dimension: square_root_acres {
    type: number
    sql: sqrt(${park_acres}) ;;
  }

  dimension: park_code {
    primary_key: yes
    type: string
    sql: ${TABLE}.Park_Code ;;
  }

  dimension: park_name {
    type: string
    sql: ${TABLE}.Park_Name ;;
  }

  dimension: state {
    type: string
    # Some parks cross state lines; only keep track of the first state
    sql: substr(${TABLE}.State, 1, 2) ;;
    map_layer_name: us_states
  }

  measure: count {
    type: count
    drill_fields: [park_name, state]
  }

  measure: biodiversity_index {
    type: count_distinct
    drill_fields: [species.scientific_name, species.common_names, species.abundance]
    sql: ${species.species_id} ;;
  }

  measure: biodiversity_per_acre {
    type: number
    drill_fields: [species.scientific_name, species.common_names, species.abundance]
    sql: ${biodiversity_index} / ${park_acres} ;;
  }
}
