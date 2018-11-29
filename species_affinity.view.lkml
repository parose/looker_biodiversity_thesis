include: "*.view"


view: park_species {
  derived_table: {
    partition_keys: ["now"]
    cluster_keys: ["park_name"]
    datagroup_trigger: affinity_pdt_rebuild
    sql: SELECT distinct parks.park_name as park_name,
                species.scientific_name as species_name
                current_datetime() as now
         FROM biodiversity_in_parks.parks  AS parks
         JOIN biodiversity_in_parks.species AS species ON parks.park_name = species.park_name ;;
  }
}

view: total_park_species {
  derived_table: {
    datagroup_trigger: affinity_pdt_rebuild
    sql: SELECT species.scientific_name as species_name,
                count(distinct concat(species.scientific_name, parks.park_name)) as species_park_count
         FROM biodiversity_in_parks.parks  AS parks
         JOIN biodiversity_in_parks.species AS species ON parks.park_name = species.park_name
         GROUP BY species.scientific_name
       ;;
  }
}

view: total_parks {
  derived_table: {
    datagroup_trigger: affinity_pdt_rebuild
    sql: SELECT count(*) as count
         FROM biodiversity_in_parks.parks  AS parks ;;
  }

  dimension: count {
    type: number
    sql: ${TABLE}.count ;;
    view_label: "Affinity"
    label: "Total Park Count"
  }
}

view: park_species_affinity_intermediate {
  derived_table: {
    datagroup_trigger: affinity_pdt_rebuild
    # indexes: ["species_a"]
    sql: SELECT op1.species_name as species_a
        , op2.species_name as species_b
        , count(*) as joint_park_count
        FROM ${park_species.SQL_TABLE_NAME} as op1
        JOIN ${park_species.SQL_TABLE_NAME} op2
        ON op1.park_name = op2.park_name
        AND op1.scientific_name <> op2.scientific_name  -- ensures we don't match on the same park items in the same park, which would corrupt our frequency metrics
        GROUP BY species_a, species_b
       ;;
  }
}

view: park_species_affinity {
  derived_table: {
    datagroup_trigger: affinity_pdt_rebuild
    # indexes: ["species_a"]
    sql: SELECT species_a
      , species_b
      , joint_park_count
      , top1.species_park_count as species_a_park_count   -- total number of parks with species A in them
      , top2.species_park_count as species_b_park_count   -- total number of parks with species B in them
      FROM ${park_species_affinity_intermediate.SQL_TABLE_NAME} as prop
      JOIN ${total_park_species.SQL_TABLE_NAME} as top1 ON prop.species_a = top1.species_name
      JOIN ${total_park_species.SQL_TABLE_NAME} as top2 ON prop.species_b = top2.species_name
       ;;
  }

  dimension: primary_key {
    hidden: yes
    primary_key: yes
    sql: concat(${TABLE}.species_a, ${TABLE}.species_b) ;;
  }

  dimension: species_a {
    type: string
    sql: ${TABLE}.species_a ;;
  }

  dimension: species_b {
    type: string
    sql: ${TABLE}.species_b ;;
  }

  dimension: joint_park_count {
    description: "How many times item A and B were purchased in the same park"
    type: number
    sql: ${TABLE}.joint_park_count ;;
    value_format: "#"
  }

  dimension: species_a_park_count {
    description: "Total number of parks with species A in them, during specified timeframe"
    type: number
    sql: ${TABLE}.species_a_park_count ;;
    value_format: "#"
  }

  dimension: species_b_park_count {
    description: "Total number of parks with species B in them, during specified timeframe"
    type: number
    sql: ${TABLE}.species_b_park_count ;;
    value_format: "#"
  }

  #  Frequencies
  dimension: species_a_park_frequency {
    description: "How frequently parks include species A as a percent of total parks"
    type: number
    sql: 1.0*${species_a_park_count}/${total_parks.count} ;;
    value_format: "#.00%"
  }

  dimension: species_b_park_frequency {
    description: "How frequently parks include species B as a percent of total parks"
    type: number
    sql: 1.0*${species_b_park_count}/${total_parks.count} ;;
  }

  #     value_format: '#.00%'

  dimension: joint_park_frequency {
    description: "How frequently parks include both species A and B as a percent of total parks"
    type: number
    sql: 1.0*${joint_park_count}/${total_parks.count} ;;
    value_format: "#.00%"
  }

  # Affinity Metrics

  dimension: add_on_frequency {
    description: "How many times both speciess are purchased when species A is purchased"
    type: number
    sql: 1.0*${joint_park_count}/${species_a_park_count} ;;
    value_format: "#.00%"
  }

  dimension: lift {
    description: "The likelihood that buying species A drove the purchase of species B"
    type: number
    sql: 1*${joint_park_frequency}/(${species_a_park_frequency} * ${species_b_park_frequency}) ;;
  }

  ## Do not display unless users have a solid understanding of  statistics and probability models
  dimension: jaccard_similarity {
    description: "The probability both items would be purchased together, should be considered in relation to total park count, the highest score being 1"
    type: number
    sql: 1.0*${joint_park_count}/(${species_a_park_count} + ${species_b_park_count} - ${joint_park_count}) ;;
    value_format: "#,##0.#0"
  }

  # Aggregate Measures - ONLY TO BE USED WHEN FILTERING ON AN AGGREGATE DIMENSION (E.G. BRAND_A, CATEGORY_A)


  measure: aggregated_joint_park_count {
    description: "Only use when filtering on a rollup of species items, such as brand_a or category_a"
    type: sum
    sql: ${joint_park_count} ;;
  }
}
