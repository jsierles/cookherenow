class HomeController < ApplicationController
  def home
    ip = $geoip.city(request.ip) rescue nil

    @recipes = if params[:q]
      Recipe.where("lower(data->>'title') LIKE '%#{params[:q].downcase}%'")
    elsif ip
      Recipe.where("lower(data->>'title') LIKE '%#{ip.city.name.downcase}%' OR lower(data->>'title') LIKE '%#{ip.country.name.downcase}%'")
    else
      Recipe.none
    end
  end
end