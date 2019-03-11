view: biodiversity_metrics {
  derived_table: {
    sql: SELECT parks.Park_Name, parks.Park_Acres,
            species_count,
            species.category,
            species.conservation_status,
            count_distinct_species,
            (case
            when {% parameter biodiversity_metrics.biodiversity_metric %} = "Total Species"
              then species_count
            when {% parameter biodiversity_metrics.biodiversity_metric %} = "Species Per Acre"
              then (species_count / parks.Park_Acres) * 1000
            when {% parameter biodiversity_metrics.biodiversity_metric %} = "Species Richness"
              then species_richness
            when {% parameter biodiversity_metrics.biodiversity_metric %} = "Percent Species"
              then species_count / count_distinct_species
            when {% parameter biodiversity_metrics.biodiversity_metric %} = "Park Acres"
              then parks.Park_Acres
            else species_count
            end) as biodiversity_score
         FROM biodiversity_in_parks.parks as parks
         JOIN biodiversity_in_parks.species as species on parks.Park_Name = species.Park_Name
         JOIN (SELECT
           parks.Park_Name AS park_name,
           COUNT(species.Species_ID ) AS species_count,
           COUNT(distinct species.scientific_name) as count_distinct_species,
           COUNT(distinct concat(split(species.scientific_name, " ")[safe_offset(0)],
                                 split(species.scientific_name, " ")[safe_offset(1)])) as species_richness
         FROM biodiversity_in_parks.parks  AS parks
         LEFT JOIN biodiversity_in_parks.species  AS species ON parks.Park_Name = species.Park_Name
         WHERE
         {% condition species_type %} species.category {% endcondition %}
         AND
         {% condition at_risk %}
          (species.conservation_status = "Endangered" OR species.conservation_status = "Threatened")
         {% endcondition %}
         GROUP BY parks.Park_Name) as species_counts on species_counts.park_name = parks.park_name

        ;;
  }

  dimension: park_name {
    type: string
    sql: ${TABLE}.Park_Name ;;
  }

  dimension: species_count {
    type: number
    hidden: yes
    sql: ${TABLE}.species_count ;;
  }

  dimension: biodiversity_score {
#     label: "{% if biodiversity_metrics.biodiversity_metric._in_query %}
#               {% parameter biodiversity_metrics.biodiversity_metric %}
#             {% else %}
#               Biodiversity Score
#             {% endif %}"
    type: number
    sql: ${TABLE}.biodiversity_score ;;
  }

  dimension: species_category {
    type: string
    hidden: yes
    sql: ${TABLE}.category ;;
  }

  dimension: conservation_status {
    type: yesno
    hidden: yes
    sql: ${TABLE}.conservation_status = "endangered" or ${TABLE}.conservation_status = "threatened" ;;
  }

  parameter: biodiversity_metric {
    type: string
    allowed_value: {
      label: "Total Species"
      value: "Total Species"
    }
    allowed_value: {
      label: "Percent Species"
      value: "Percent Species"
    }
    allowed_value: {
      label: "Scaled Species Per Acre"
      value: "Species Per Acre"
    }
    allowed_value: {
      label: "Species Richness"
      value: "Species Richness"
    }
    allowed_value: {
      label: "Park Acres"
      value: "Park Acres"
    }
  }

  filter: species_type {
    type: string
    suggest_dimension: species_category
  }

  filter: at_risk {
    label: "At-Risk Species"
    type: yesno
  }
}
