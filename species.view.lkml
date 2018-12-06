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

  dimension: family {
    group_label: "Taxonomy"
    type: string
    sql: ${TABLE}.Family ;;
  }

  dimension: genus {
    group_label: "Taxonomy"
    type: string
    sql: split(${scientific_name}, " ")[safe_offset(0)] ;;
  }

  dimension: species {
    group_label: "Taxonomy"
    type: string
    sql: split(${scientific_name}, " ")[safe_offset(1)] ;;
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
    link: {
      label: "Species Details"
      url: "https://productday.dev.looker.com/dashboards/256?Species%20Scientific%20Name={{ value | url_encode }}&Genus={{ value | split: ' ' | first | url_encode }}"
    }
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
    drill_fields: [scientific_name, common_names, conservation_status]
  }

  measure: count_distinct_species {
    type: count_distinct
    drill_fields: [scientific_name, common_names, conservation_status]
    sql: ${scientific_name} ;;
  }

  measure: percent_species {
    type: number
    sql: ${count} / (select ${count_distinct_species} from biodiversity_in_parks.species) ;;
    value_format_name: percent_2
  }

  # Measure to add up the total number of acres a species can be found in
  # Should only be used when joined to species_aggregate
  measure: species_range {
    type: sum
    drill_fields: [parks.park_name, parks.location, parks.state, parks.park_acres]
    sql: ${parks.park_acres} ;;
  }
}
