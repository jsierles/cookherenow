class HomeController < ApplicationController
  def home
    ip = $geoip.city(request.headers['Fly-Client-Ip']) rescue nil
    @key = nil

    @recipes = if params[:q]
      Recipe.where("lower(data->>'title') LIKE '%#{params[:q].downcase}%'")
      key = params[:q]
    elsif ip
      @appear = ip.city.name || ip.country.name
      Recipe.where("lower(data->>'title') LIKE '%#{ip.city.name.downcase}%' OR lower(data->>'title') LIKE '%#{ip.country.name.downcase}%'")
      key = ip
    else
      Recipe.none
    end
  end
end