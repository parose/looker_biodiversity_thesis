connection: "lookerdata_publicdata_standard_sql"

include: "*.view"
include: "/datablocks_gsod_bq/bigquery*.view"

# REQUIREMENTS

# One derived table (can also be a PDT or NDT)
#   - currently have common_names view
#   - use DT for biodiversity score
#   - use PDT to dedupe cities table
#       - make this persistent
#   - DT for unnested city zipcodes?
# At least one explore with 2+ joins
#   - national_parks
# Drill fields on every measure
#   - Done; need more measures though
# At least one Looker Block
#   - Weather block

# A feature involving Liquid HTML (like parameters or templated filters) to make your explores dynamic
#   - Currently using parameters with biodiversity score
# Advanced Analysis - Affinity analysis: which species tend to appear in the same park together?
#   - Looks like this might be difficult; BQ running out of memory?
#     - Check the use of species_id - don't want to cross join on all 100,000 rows
#     - normalize species name - remove "var. ___"?
#     - check duplicate species - reduce dataset size
#     - cluster_keys/partition_keys
# One new feature from the past three releases
#   - Something from Looker 6?
#     - Enhanced color picker
#     - New Cartesian charts
#   - 6.2: Totals for table calcs?

# Split scientific name into genus/species/subspecies
# More biodiversity metrics
# Species "adaptability" score - based on variance of temperature/rainfall/etc. of parks where it is present
#   - Average number of standard deviations a park is from the average?
#   - Track separate adaptability metrics - eg. an animal can have varying rainfall as long as temp is same
#   - Bin temp/precipitation into buckets to make histograms?

# A presentable dashboard centered around a use case

datagroup: andrew_rose_thesis_default_datagroup {
  max_cache_age: "1 hour"
}

datagroup: affinity_pdt_rebuild {
  max_cache_age: "24 hours"
  sql_trigger: SELECT EXTRACT(WEEK from CURRENT_TIMESTAMP()) ;;
}

persist_with: andrew_rose_thesis_default_datagroup

# EXPLORES
explore: biodiversity_metrics {

}

# explore: cities {
#
# }

# Make new view to account for parks in multiple states?
explore: parks {
  label: "National Parks"

  #sql_always_where: ${parks.park_name} LIKE "A%" ;;
  fields: [ALL_FIELDS*]

  join: species {
    sql_on: ${species.park_name} = ${parks.park_name} ;;
    relationship: one_to_many
  }

  join: common_names {
    view_label: "Species"
    fields: [common_names.common_name]
    sql_on: ${species.scientific_name} = ${common_names.scientific_name} ;;
    relationship: one_to_many
  }

  join: cities {
    sql_on: ${cities.state_id} = ${parks.state} ;;
    relationship: many_to_many
  }

  join: biodiversity_metrics {
    sql_on: ${biodiversity_metrics.park_name} = ${parks.park_name} ;;
    relationship: one_to_one
  }

  join: dimensionalized_weather {
    sql_on: ${parks.park_name} = ${dimensionalized_weather.park_name} ;;
    relationship: one_to_one
  }
}

explore: park_weather {
  view_name: parks
  view_label: "Parks"

  sql_always_where: ${gsod.year} = "2017";;

  fields: [ALL_FIELDS*, -parks.miles_to_city, -parks.min_city_distance]

  join: biodiversity_metrics {
    sql_on: ${biodiversity_metrics.park_name} = ${parks.park_name} ;;
    relationship: one_to_one
  }

  join: species {
    sql_on: ${parks.park_name} = ${species.park_name} ;;
    type: left_outer
    relationship: one_to_many
  }

  join: common_names {
    view_label: "Species"
    fields: [common_names.common_name]
    sql_on: ${species.scientific_name} = ${common_names.scientific_name} ;;
    relationship: one_to_many
  }

  join: park_nearest_city {
    view_label: "Parks"
    fields: [park_nearest_city.nearest_city, park_nearest_city.nearest_city_distance]
    sql_on: ${parks.park_name} = ${park_nearest_city.park_name} ;;
    type: left_outer
    relationship: one_to_many
  }

# TO JOIN TO WEATHER:
# Get zip code of nearest city to each park
  join: zipcode_station {
    from: bq_zipcode_station
    sql_on: ${zipcode_station.zipcode} = ${park_nearest_city.nearest_zip} ;;
    relationship: many_to_many
  }
  join: gsod {
    from: gsod_extended
    view_label: "Geography"
    type: left_outer
    relationship: one_to_many
    sql_on: ${gsod.station_id} = ${zipcode_station.nearest_station_id}
      and ${gsod.year} = ${zipcode_station.year};;
  }
  join: stations {
    from: bq_stations
    type: left_outer
    relationship: many_to_one
    sql_on: ${zipcode_station.nearest_station_id} = ${stations.station_id} ;;
  }
  join: zipcode_county{
    from: bq_zipcode_county
    view_label: "Geography"
    type: left_outer
    relationship: many_to_one
    sql_on: ${zipcode_station.zipcode} = ${zipcode_county.zipcode}  ;;
  }
  join: zipcode_facts {
    from: bq_zipcode_facts
    view_label: "Geography"
    type: left_outer
    relationship: one_to_many
    sql_on: ${zipcode_county.zipcode} = ${zipcode_facts.zipcode} ;;
  }
}

# explore: species {
#   fields: [ALL_FIELDS*, -species.species_id]
#
#   join: parks {
#     sql_on: ${species.park_name} = ${parks.park_name} ;;
#     relationship: many_to_one
#   }
# }

explore: park_species_affinity {
  label: "Affinity"
  view_label: "Affinity"

  join: total_parks {
    type: cross
    relationship: many_to_one
  }

  join: species {
    fields: [species.scientific_name, species.common_names, species.conservation_status]
    sql_on: ${park_species_affinity.species_a} = ${species.genus} ;;
    relationship: many_to_many
  }
}

# explore: gsod {
#   from: bq_gsod
#   join: zipcode_station {
#     from: bq_zipcode_station
#     view_label: "Geography"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${gsod.station_id} = ${zipcode_station.nearest_station_id}
#       and ${gsod.year} = ${zipcode_station.year};;
#   }
#   join: stations {
#     from: bq_stations
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${zipcode_station.nearest_station_id} = ${stations.station_id} ;;
#   }
#   join: zipcode_county{
#     from: bq_zipcode_county
#     view_label: "Geography"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${zipcode_station.zipcode} = ${zipcode_county.zipcode}  ;;
#   }
#   join: zipcode_facts {
#     from: bq_zipcode_facts
#     view_label: "Geography"
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${zipcode_county.zipcode} = ${zipcode_facts.zipcode} ;;
#   }
# }

# explore: zipcode_county {
#   from: bq_zipcode_county
#   join: zipcode_facts {
#     from: bq_zipcode_facts
#     type: left_outer
#     sql_on: ${zipcode_county.zipcode} = ${zipcode_facts.zipcode} ;;
#     relationship: one_to_many
#   }
#   join: zipcode_station {
#     from: bq_zipcode_station
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${zipcode_county.zipcode} = ${zipcode_station.zipcode} ;;
#   }
#   join: stations {
#     from: bq_stations
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${zipcode_station.nearest_station_id} = ${stations.station_id} ;;
#   }
# }
