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
    link: {
      label: "Park Details"
      url: "https://productday.dev.looker.com/dashboards/255?Park%20Name={{ value | url_encode }}"
    }
  }

  dimension: state {
    type: string
    # Some parks cross state lines; only keep track of the first state
    sql: substr(${TABLE}.State, 1, 2) ;;
    map_layer_name: us_states
  }

  dimension: miles_to_city {
    type: distance
    start_location_field: parks.park_location
    end_location_field: cities.city_location
    units: miles
  }

  measure: count {
    type: count
    drill_fields: [park_name, state]
  }

  measure: count_threatened_species {
    type: count_distinct
    sql: ${species.species_id} ;;
    drill_fields: [species.scientific_name, species.common_names, species.conservation_status]
    filters: {
      field: species.is_threatened
      value: "yes"
    }
  }

  measure: threatened_species_proportion {
    type: number
    sql:  ${parks.count_threatened_species} / ${species_richness} ;;
    drill_fields: [species.scientific_name, species.common_names, species.conservation_status]
  }

  measure: species_richness {
    type: count_distinct
    drill_fields: [species.scientific_name, species.common_names, species.abundance]
    sql: concat(${species.genus}, ${species.species}) ;;
  }

  measure: biodiversity_per_acre {
    type: number
    drill_fields: [species.scientific_name, species.common_names, species.abundance]
    sql: ${species_richness} / ${park_acres} ;;
  }

  measure: min_city_distance {
    type: min
    sql: ${miles_to_city} ;;
    drill_fields: [parks.miles_to_city, parks.park_name, cities.city, cities.state_id, cities.zip]
  }

}
