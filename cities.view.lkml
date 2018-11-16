view: cities {
  derived_table: {
    sql: SELECT distinct city, lat, lng, state_id, state_name, flattened_zip
         FROM biodiversity_in_parks.cities  AS cities
         CROSS JOIN unnest(split(zip, " ")) as flattened_zip ;;
  }

  dimension: composite_key {
    hidden: yes
    type: string
    sql: concat(city, cast(lat as string), cast(lng as string), cast(flattened_zip as string)) ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: latitude {
    hidden: yes
    type: number
    sql: ${TABLE}.lat ;;
  }

  dimension: longitude {
    hidden: yes
    type: number
    sql: ${TABLE}.lng ;;
  }

  dimension: city_location {
    type: location
    sql_latitude: ${TABLE}.lat ;;
    sql_longitude: ${TABLE}.lng ;;
  }

  dimension: state_id {
    type: string
    sql: ${TABLE}.state_id ;;
    map_layer_name: us_states
  }

  dimension: state_name {
    type: string
    sql: ${TABLE}.state_name ;;
    map_layer_name: us_states
  }

  dimension: zip {
    type: zipcode
    # Some cities span multiple zipcodes, so only get the first one
    sql: ${TABLE}.flattened_zip ;;
  }
}
