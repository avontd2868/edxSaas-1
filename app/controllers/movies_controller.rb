class MoviesController < ApplicationController

  attr_accessor :title_style
  attr_accessor :release_date_style
  attr_accessor :all_ratings
  attr_accessor :checked_ratings
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  def index 
    @title_style = ""
    @release_date_style = ""
    @all_ratings = []
    @checked_ratings = []
    Movie.select("DISTINCT rating").each do |movie|
      @all_ratings<<movie.rating
    end
    selected_ratings = params[:ratings]
    if !selected_ratings.nil?      
      flash[:ratings] = selected_ratings
      @checked_ratings = selected_ratings.keys
      if !flash[:sort].nil?
        @movies = Movie.find(:all, :conditions => { :rating => selected_ratings.keys } , :order => flash[:sort].to_s + " ASC")
        if flash[:sort] == "title"
          @title_style = "hilite"
        else
          @release_date_style = "hilite"
        end
      else
        @movies = Movie.find(:all, :conditions => { :rating => selected_ratings.keys })
      end
    else
      @checked_ratings = @all_ratings
      @movies = Movie.all
    end
    sort = params[:sort]
    if !sort.nil?
      flash[:sort] = sort
      if sort == "title"
        if !flash[:ratings].nil?
          @movies = Movie.find(:all, :conditions => { :rating => flash[:ratings].keys } , :order => sort + " ASC")
        else
          @movies = Movie.order("title ASC")
        end
        @title_style = "hilite"
      elsif sort == "release_date"
        if !flash[:ratings].nil?
          @movies = Movie.find(:all, :conditions => { :rating => flash[:ratings].keys } , :order => sort.to_s + " ASC")
        else
          @movies = Movie.order("release_date ASC")
        end
        @release_date_style = "hilite"
      end
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
