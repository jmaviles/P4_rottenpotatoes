require 'spec_helper'

describe MoviesController do
  describe 'rottenpotattoes homepage' do
   it 'should see the index page' do
      get :index
      response.should render_template("index")
   end

   it 'should show a movie by id' do
      m = mock('Film')
      Movie.should_receive(:find).with('5').and_return(m)
      get :show, {:id => 5}
      response.should render_template("show")
    end

    it "should sort by 'title'" do
      session[:sort] = 'title'
      Movie.should_receive(:find_all_by_rating).with(anything(), {:order => :title})
      get :index, {:sort => 'title'}
    end
    
    it "should sort by 'date'" do
      session[:sort] = 'release_date'
      Movie.should_receive(:find_all_by_rating).with(anything(), {:order => :release_date})
      get :index, {:sort => 'release_date'}
    end

    it "modified session[:sort] " do
      session[:sort] = 'release_date'
      get :index, {:sort => 'title'}
      session[:sort].should == 'title'
    end

    it "modified session[:sort] and session[:ratings]" do
      session[:ratings] = 'P'
      get :index, {:ratings => 'PG'}
      session[:ratings].should == 'PG'
    end
  end
  describe 'show movie' do
    it 'Should call show movie' do
      fake_movies = [mock('Film'), mock('Film')]
      Movie.should_receive(:find).with('2').and_return(fake_movies)
      post :show, {:id => '2'}
    end
  end

  describe 'create movie' do
    it 'Should call Create movie' do
      Movie.stub(:create)
      post :create
      render_template('index')
    end
  end
  
  describe 'edit movie' do
    it 'Should call Edit movie' do
      Movie.should_receive(:find).with('5')
      get :edit, {:id => '5'}
    end
  end

  describe 'update movie' do
    it 'Should call update' do
      m=mock('Film')
      m.stub!(:title)
      Movie.should_receive(:find).with('5').and_return(m)
      m.should_receive(:update_attributes!)
      put :update, {:id => '5', :movie => m}
      response.should redirect_to(movie_path(m))
    end
  end

  describe 'destroy movie' do
    it 'Should call destroy' do
      m=mock('Film')
      m.stub!(:title)
      Movie.should_receive(:find).with('5').and_return(m)
      m.should_receive(:destroy).and_return(true)
      post :destroy, {:id => '5'}
      response.should redirect_to(movies_path)
    end
  end
  
  describe 'samedirector' do
    it 'should redirect to home page when director is empty' do
      m=mock('Film', :director =>'')
      m.stub!(:title)
      Movie.should_receive(:find).with('5').and_return(m)
      get :samedirector, {:id => '5'}
      response.should redirect_to(movies_path)
    end
 
    it 'should go to similar page' do
      m=mock('Film', :director =>'x')
      Movie.should_receive(:find).with('5').and_return(m)
      get :samedirector, {:id => '5'}
      response.should render_template('samedirector')
    end
  end

  describe 'searching TMDb' do
    it 'should call the model method that performs TMDb search' do
      Movie.should_receive(:find_in_tmdb).with('hardware')
      post :search_tmdb, {:search_terms => 'hardware'}
    end
    it 'should select the Search Results template for rendering' do
      Movie.stub(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'hardware'}
      response.should render_template('search_tmdb')
    end
    it 'should make the TMDb search results available to that template' do
      fake_results = [mock('Film'), mock('Film')]
      Movie.stub(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'hardware'}
      assigns(:movies).should == fake_results
    end

    describe 'after invalid search' do
      it 'No results for the movie search' do
        result = []
        Movie.stub(:find_in_tmdb).and_return(result)
        post :search_tmdb, {:search_terms => 'hardware'}
        assigns(:movies).should == result
        render_template('index')
      end
    end
  end
end



