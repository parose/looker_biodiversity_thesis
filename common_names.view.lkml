view: common_names {
  derived_table: {
    sql: SELECT distinct scientific_name, flattened_common_name
         FROM biodiversity_in_parks.species
         CROSS JOIN UNNEST(split(species.common_names, ",")) as flattened_common_name
         WHERE species.common_names != "None" ;;
  }

  dimension: composite_key {
    type: string
    primary_key: yes
    hidden: yes
    sql: concat(${TABLE}.scientific_name, ${TABLE}.flattened_common_name ;;
  }

  dimension: scientific_name {
    type: string
    sql: ${TABLE}.scientific_name ;;
  }

  dimension: common_name {
    type: string
    sql: ${TABLE}.flattened_common_name ;;
  }
}
