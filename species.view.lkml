view: species {
  sql_table_name: biodiversity_in_parks.species ;;

  dimension: species_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.Species_ID ;;
  }

  dimension: abundance {
    type: string
    sql: ${TABLE}.Abundance ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.Category ;;
  }

  dimension: common_names {
    hidden: yes
    type: string
    sql: ${TABLE}.Common_Names ;;
  }

  dimension: conservation_status {
    type: string
    sql: ${TABLE}.Conservation_Status ;;
  }

  dimension: family {
    group_label: "Taxonomy"
    type: string
    sql: ${TABLE}.Family ;;
  }

  dimension: nativeness {
    type: string
    sql: ${TABLE}.Nativeness ;;
  }

  dimension: occurrence {
    type: string
    sql: ${TABLE}.Occurrence ;;
  }

  dimension: order {
    group_label: "Taxonomy"
    type: string
    sql: ${TABLE}.`Order` ;;
  }

  dimension: park_name {
    type: string
    sql: ${TABLE}.Park_Name ;;
  }

  dimension: record_status {
    type: string
    sql: ${TABLE}.Record_Status ;;
  }

  dimension: scientific_name {
    type: string
    sql: ${TABLE}.Scientific_Name ;;
  }

  dimension: seasonality {
    type: string
    sql: ${TABLE}.Seasonality ;;
  }

  dimension: is_threatened {
    hidden: yes
    type: yesno
    sql: ${TABLE}.Conservation_Status != "" ;;
  }

  measure: count {
    type: count
    drill_fields: [species_id, scientific_name, park_name]
  }

  # Measure to add up the total number of acres a species can be found in
  # Should only be used when joined to species_aggregate
  measure: species_range {
    type: sum
    drill_fields: [parks.park_name, parks.location, parks.state, parks.park_acres]
    sql: ${parks.park_acres} ;;
  }
}
