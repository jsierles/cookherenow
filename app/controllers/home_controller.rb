class HomeController < ApplicationController
  def home
    ip = $geoip.city(request.headers['Fly-Client-Ip']) rescue nil
    @key = nil

    @recipes = if params[:q]
      @key = params[:q]
      Recipe.where("lower(data->>'title') LIKE '%#{params[:q].downcase}%'")
    elsif ip
      @appear = ip.city.name || ip.country.name
      @key = ip
      Recipe.where("lower(data->>'title') LIKE '%#{ip.city.name.downcase}%' OR lower(data->>'title') LIKE '%#{ip.country.name.downcase}%'")
    else
      Recipe.none
    end
  end
end