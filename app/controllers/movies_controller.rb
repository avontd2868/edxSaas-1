class MoviesController < ApplicationController

  attr_accessor :title_style
  attr_accessor :release_date_style
  attr_accessor :all_ratings
  attr_accessor :checked_ratings
  attr_accessor :restful_append
  def create_restful_uri
    @restful_append = "?"
    #Just to check again
    if !params[:sort].nil?
      session[:sort] = params[:sort]
    end
    if !session[:sort].nil?
      @restful_append += "sort=#{session[:sort]}&"
    end
    if !session[:checked_ratings].nil?
      session[:checked_ratings].each do |rating|
        @restful_append += "ratings[#{rating}]=#{rating}&"
      end
    end
    if @restful_append[-1] == "&"
      @restful_append[-1] = ""
    end
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
     create_restful_uri   
  end
  def index 
    @title_style = ""
    @release_date_style = ""
    @all_ratings = []
    @checked_ratings = []
    Movie.select("DISTINCT rating").each do |movie|
      @all_ratings<<movie.rating
    end
    #Read the selected ratings and sort from params
    selected_ratings = params[:ratings]
    sort = params[:sort]

    #Set the ratings value in session
    if !selected_ratings.nil?      
      session[:checked_ratings] = selected_ratings.keys
    elsif session[:checked_ratings].nil?
      #This means user has not clicked refresh yet.
      session[:checked_ratings] = @all_ratings
    else
      create_restful_uri
      url = "/movies" + @restful_append
      redirect_to url
      return
    end

    #Set the sort value in session
    if !sort.nil?
      session[:sort] = sort
    elsif !session[:sort].nil?
      create_restful_uri
      url = "/movies" + @restful_append
      redirect_to url
      return
    end

    #Set the style for column headers
    case session[:sort]
    when "title" then
      @title_style = "hilite"
    when "release_date" then
      @release_date_style = "hilite"
    end

    #Set the instance variables used in view
    @checked_ratings = session[:checked_ratings]
    #No order clause if the session sort value is nil
    if !session[:sort].nil?
      @movies = Movie.find(:all, :conditions => { :rating => session[:checked_ratings] } , :order => session[:sort].to_s + " ASC")
    else
      @movies = Movie.find(:all, :conditions => { :rating => session[:checked_ratings] } )
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
