view: park_nearest_city {
  derived_table: {
    sql: select park_name, city, zip, city_distance
FROM (SELECT
  parks.Park_Name  AS park_name,
  cities.city,
  cities.flattened_zip as zip,
  MIN(((CASE WHEN parks.Latitude  = cities.lat  AND parks.Longitude  = cities.lng  THEN 0 ELSE ACOS(SIN((IFNULL(parks.Latitude , 0.0) * 3.141592653589793 / 180)) * SIN((IFNULL(cities.lat , 0.0) * 3.141592653589793 / 180)) + COS((IFNULL(parks.Latitude , 0.0) * 3.141592653589793 / 180)) * COS((IFNULL(cities.lat , 0.0) * 3.141592653589793 / 180)) * COS((IFNULL(cities.lng  - parks.Longitude , 0.0) * 3.141592653589793 / 180))) * 6371 END) / 1.60934) ) AS city_distance
FROM biodiversity_in_parks.parks  AS parks
LEFT JOIN (SELECT distinct city, lat, lng, state_id, state_name, flattened_zip
         FROM biodiversity_in_parks.cities  AS cities
         CROSS JOIN unnest(split(zip, " ")) as flattened_zip ) as cities ON cities.state_id = (substr(parks.State, 1, 2))
GROUP BY 1, 2, 3) as city_dists
WHERE city_dists.city_distance =
(SELECT MIN(((CASE WHEN parks.Latitude  = cities.lat  AND parks.Longitude  = cities.lng  THEN 0 ELSE ACOS(SIN((IFNULL(parks.Latitude , 0.0) * 3.141592653589793 / 180)) * SIN((IFNULL(cities.lat , 0.0) * 3.141592653589793 / 180)) + COS((IFNULL(parks.Latitude , 0.0) * 3.141592653589793 / 180)) * COS((IFNULL(cities.lat , 0.0) * 3.141592653589793 / 180)) * COS((IFNULL(cities.lng  - parks.Longitude , 0.0) * 3.141592653589793 / 180))) * 6371 END) / 1.60934) ) AS city_distance
FROM biodiversity_in_parks.parks  AS parks
LEFT JOIN (SELECT distinct city, lat, lng, state_id, state_name, flattened_zip
         FROM biodiversity_in_parks.cities  AS cities
         CROSS JOIN unnest(split(zip, " ")) as flattened_zip ) as cities ON cities.state_id = (substr(parks.State, 1, 2))
WHERE parks.park_name = city_dists.park_name
) ;;
  }

  dimension: park_name {
    type: string
    sql: ${TABLE}.park_name ;;
  }

  dimension: nearest_city {
    group_label: "Nearest City Info"
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: nearest_zip {
    group_label: "Nearest City Info"
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: nearest_city_distance {
    group_label: "Nearest City Info"
    type: number
    sql: ${TABLE}.city_distance ;;
  }
}
