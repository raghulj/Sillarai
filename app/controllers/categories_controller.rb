class CategoriesController < ApplicationController
  before_filter :login_required
  before_filter :set_cache_buster
  before_filter :get_categories

  # GET /categories
  # GET /categories.xml
  def index
    @category = Category.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    @categories = current_user.categories.find(:all, :conditions => ["id <> ?",params[:id]])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    unless params[:category][:colour]
      @category = 'FFFFFF'
    end
    @category.user_id = current_user.id

    respond_to do |format|
      if @category.save
        format.html { redirect_to('/categories') }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        flash[:message] = "Category name is important"
        format.html { render :action => "index" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to :action => "index" , :notice => 'Category was successfully updated.' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end
end
