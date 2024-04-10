class Api::FeaturesController < ApplicationController
  def index
    unless Integer(params[:per_page]) <= 1000
      render json: { message: 'per_page Must be less than 1000' }
    end
    total = Feature.count
    @features = Feature.all.paginate(page: params[:page], per_page: params[:per_page])
    if params[:mag_type].present?
      @features = @features.where(magType: params[:mag_type])
    end
    data = []
    @features.each do |feature|
      data.push({
         id: feature.id,
         type: "feature",
         attributes: {
           external_id: feature.feature_id,
           magnitude: feature.mag,
           place: feature.place,
           time: feature.time,
           tsunami: feature.tsunami == 1,
           mag_type: feature.magType,
           title: feature.title,
           coordinates: {
             longitude: feature.longitude,
             latitude: feature.latitude,
           }
         },
         links: {
           external_url: feature.url,
         }
       })
    end
    render json: { data: data, pagination: { current_page: params[:page], total: total, per_page: params[:per_page] } }
  end

  def update
    @feature = Feature.find_by_id(params[:id])
    unless @feature
      render json: { message: 'Feature not found' }
    end
    @comment = Comment.create(
      feature_id: params[:id],
      body: params[:body]
    )
    render json: @comment
  end
end
