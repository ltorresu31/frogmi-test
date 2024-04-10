require 'net/http'
require 'json'
namespace :gsdata do
  desc "Get data from USGS and store it in database"
  task :get => :environment do
    starting = Time.now
    uri = URI("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
    response = Net::HTTP.get_response(uri)
    parsed_response = JSON.parse(response.body)
    features = parsed_response["features"]
    begin
      count = 0
      features.each do |feature|
        properties = feature["properties"]
        coordinates = feature["geometry"]["coordinates"]
        if properties["mag"] > -1 && properties["mag"] < 10 && coordinates[1] > -90 && coordinates[1] < 90 && coordinates[0] > -180 && coordinates[0] < 180 && properties["title"] && properties["url"] && properties["place"] && properties["magType"]
          existing_feature = Feature.where(feature_id: feature["id"])
          unless existing_feature.present?
            Feature.create(
              feature_id: feature["id"],
              mag: properties["mag"],
              place: properties["place"],
              time: properties["time"],
              url: properties["url"],
              tsunami: properties["tsunami"],
              magType: properties["magType"],
              title: properties["title"],
              longitude: coordinates[0],
              latitude: coordinates[1]
            )
            count += 1
          end
        end
      end
      ending = Time.now
      elapsed = ending - starting
      puts("#{count} new records added in #{elapsed} seconds")
    rescue SQLite3::Exception => e
      puts("Something went wrong: " + e.message)
    end
  end
end