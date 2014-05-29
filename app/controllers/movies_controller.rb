class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
      @ratings = Movie.select('rating')
      @all_ratings=[]
      @ratings.each {|i| @all_ratings.push i.rating}
      @all_ratings.uniq!

      if !params[:ratings].nil?
        @checked_ratings = params[:ratings].keys
        session[:ratings] = @checked_ratings
      else
        if !session[:ratings].nil?
          @checked_ratings = session[:ratings]
        else
          @checked_ratings = @all_ratings
          session[:ratings] = @checked_ratings
        end
      end

      sort = nil
      unless params[:sort_by_title].nil?
        sort = :sort_by_title
        session[:sort_by_title] = :asc
        session.delete(:sort_by_date)
      else
        sort = :sort_by_title unless session[:sort_by_title].nil?
      end

      unless params[:sort_by_date].nil?
        sort = :sort_by_date
        session[:sort_by_date] = :asc
        session.delete(:sort_by_title)
      else
        sort = :sort_by_date unless session[:sort_by_date].nil?
      end

      if sort == :sort_by_title 
	@movies=Movie.find(:all, :conditions => {'rating' => @checked_ratings}, :order => 'title')
        @title_hilite = true
      elsif sort == :sort_by_date
	@movies=Movie.find(:all, :conditions => {'rating' => @checked_ratings}, :order => 'release_date')
	@date_hilite = true
      else
        @movies=Movie.where('ratings' => @checked_ratings)
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
