view: biodiversity_metrics {
  derived_table: {
    sql: SELECT parks.Park_Name, parks.Park_Acres,
            species_count,
            (case
            when {% parameter biodiversity_metrics.biodiversity_metric %} = "total_species"
              then species_count
            when {% parameter biodiversity_metrics.biodiversity_metric %} = "species_per_acre"
              then species_count / parks.Park_Acres
            end) as biodiversity_score
         FROM biodiversity_in_parks.parks as parks
         JOIN biodiversity_in_parks.species as species on parks.Park_Name = species.Park_Name
         JOIN (SELECT
           parks.Park_Name AS park_name,
           COUNT(species.Species_ID ) AS species_count
         FROM biodiversity_in_parks.parks  AS parks
         LEFT JOIN biodiversity_in_parks.species  AS species ON parks.Park_Name = species.Park_Name
         GROUP BY parks.Park_Name) as species_counts on species_counts.park_name = parks.park_name

        ;;
  }

  dimension: park_name {
    type: string
    sql: ${TABLE}.Park_Name ;;
  }

  dimension: species_count {
    type: number
    sql: ${TABLE}.species_count ;;
  }

  dimension: biodiversity_score {
    type: number
    sql: ${TABLE}.biodiversity_score ;;
  }

  parameter: biodiversity_metric {
    type: string
    allowed_value: {
      label: "Total Species"
      value: "total_species"
    }
    allowed_value: {
      label: "Species Per Acre"
      value: "species_per_acre"
    }
  }

  filter: species_type {

  }
}
