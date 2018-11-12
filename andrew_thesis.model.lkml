connection: "lookerdata_publicdata_standard_sql"

include: "*.view"

# REQUIREMENTS

# One derived table (can also be a PDT or NDT)
#   - currently have common_names view
# At least one explore with 2+ joins
#   - national_parks
# Drill fields on every measure
#   - Done; need more measures though
# At least one Looker Block
#   - Weather block - do this soon

# A feature involving Liquid HTML (like parameters or templated filters) to make your explores dynamic
# Advanced Analysis (such as Ranking, Cohort Analysis, Retention Analysis, Forecasting)
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

  join: cities {
    sql_on: ${cities.state_id} = ${parks.state} ;;
    relationship: many_to_many
  }
}

explore: species {
  fields: [ALL_FIELDS*, -species.species_id]

  join: parks {
    sql_on: ${species.park_name} = ${parks.park_name} ;;
    relationship: many_to_one
  }
}
