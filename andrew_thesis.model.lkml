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
# Advanced Analysis (such as Ranking, Cohort Analysis, Retention Analysis, Forecasting)
#   - Affinity analysis: which species tend to appear in the same park together?
# One new feature from the past three releases
# Check-in with Mentor

# A presentable dashboard centered around a use case

datagroup: andrew_rose_thesis_default_datagroup {
  max_cache_age: "1 hour"
}

persist_with: andrew_rose_thesis_default_datagroup

# EXPLORES
explore: cities {

}

explore: parks {
  label: "National Parks"

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

  join: zipcode_station {
    from: bq_zipcode_station
    sql_on: ${zipcode_station.zipcode} = ${cities.zip} ;;
    relationship: many_to_many
  }

  join: gsod {
    from: bq_gsod
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

explore: gsod {
  from: bq_gsod
  join: zipcode_station {
    from: bq_zipcode_station
    view_label: "Geography"
    type: left_outer
    relationship: many_to_one
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

explore: zipcode_county {
  from: bq_zipcode_county
  join: zipcode_facts {
    from: bq_zipcode_facts
    type: left_outer
    sql_on: ${zipcode_county.zipcode} = ${zipcode_facts.zipcode} ;;
    relationship: one_to_many
  }
  join: zipcode_station {
    from: bq_zipcode_station
    type: left_outer
    relationship: many_to_one
    sql_on: ${zipcode_county.zipcode} = ${zipcode_station.zipcode} ;;
  }
  join: stations {
    from: bq_stations
    type: left_outer
    relationship: one_to_one
    sql_on: ${zipcode_station.nearest_station_id} = ${stations.station_id} ;;
  }
}
