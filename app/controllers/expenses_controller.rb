class ExpensesController < ApplicationController
  before_filter :login_required
  before_filter :set_cache_buster
  before_filter :get_categories

  # GET /expenses
  # GET /expenses.xml
  def index
    unless params[:date].blank?
      month = params[:date][:month] 
      year = params[:date][:year] 
    else
      month =  Time.now.month
      year =  Time.now.year
    end
    @month = month
    @year = year
    start_date = "#{year.to_s}-#{month.to_s}-01".to_datetime
    end_date = "#{year.to_s}-#{month.to_s}-#{Expense.get_days_in_month(year.to_i,month.to_i).to_s}".to_datetime
    @expenses = current_user.expenses.find(:all, 
                             :order => "exp_date desc", 
                             :conditions =>["exp_date between ? and  ?",start_date,end_date]).group_by { |h| h.exp_date.to_date}
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expenses }
    end
  end
 

  # GET /expenses/1
  # GET /expenses/1.xml
  def show
    @expense = Expense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expense }
    end
  end

  # GET /expenses/new
  # GET /expenses/new.xml
  def new
    @expense = Expense.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expense }
    end
  end

  def add_category
    @expense = Expense.find(params[:eid])
    @expense.category_id = params[:cid]
    @expense.user_id = current_user.id
    if @expense.save
        render :json => {:status => "success",:message=> "Updated to the database",:html => "data updated",:color => @expense.category.colour, :id => @expense.id}
    else
        render :json => {:status => "failure",:message=> "Error in data",:html => "<script> alert('Please check the entered data');</script>"}
    end
  end
  # GET /expenses/1/edit
  def edit
    @expense = Expense.find(params[:id])
  end

  # POST /expenses
  # POST /expenses.xml
  def create
    data = params[:expense]
    amount,description,date = Expense.split_data(data)
    unless amount.nil? 
      @expense = Expense.new
      unless params[:category][:id].blank?
        @expense.category_id = params[:category][:id]
      end
      @expense.amount = amount
      @expense.description = description
      @expense.exp_date = date
      @expense.user_id = current_user.id
      if @expense.save
        @eff_total = Expense.total(@expense.exp_date.to_date, current_user)
        if current_user.use_bayes == 1
          if BayesQueue.uniq? @expense.user_id
            bb = BayesQueue.new
            bb.user_id = @expense.user_id
            bb.save
          end
        end
        if @expense.exp_date.month == DateTime.now.month
          this_month = true
        else
          this_month = false
        end
        unless params[:category][:id].blank?
          color = @expense.category.colour
        else
          color = ""
        end
          respond_to do |format|
              format.js { 
                  render :json => {:id => @expense.id, 
                    :desc => @expense.description, 
                    :amount => @expense.amount,
                    :dt => @expense.exp_date.strftime("%d_%m_%y"), 
                    :total_date => @expense.exp_date.to_date,
                    :total => @eff_total.to_s,
                    :disp_date => @expense.exp_date.strftime("%A, %d-%m-%Y"),
                    :color => color,
                    :this_month => this_month
                    }
               }
              format.html { redirect_to(expenses_url) }
              format.xml  { head :ok }
          end
        #flash[:message] = "Expense saved. "
        #redirect_to :action => "index"
      else
        render :status => 400, :json => {:message=> "Error in data",:html => "<script> alert('Please check the entered data');</script>"}
      end
    else
     #render :status => 400, :json => {:message=> "Error in data",:html => "<script> alert('Please check the entered data');</script>"}
		flash[:message] = "Please use the specified format to enter data."
		redirect_to :action => "index"
    end
    
  end


  # PUT /expenses/1
  # PUT /expenses/1.xml
  def update
    @expense = Expense.find(params[:exp_id])
    amount,description,date = Expense.split_data(params[:expense_data])
    puts amount
    if amount.nil?
        flash[:message] = 'Please enter data in correct format.'
        redirect_to :action => :index 
    else
      if Expense.update(params[:exp_id],{:exp_date => date ,:description => description ,:amount =>amount})
        flash[:message] = 'Expense was successfully updated.'
        redirect_to :action => :index 
      else
        flash[:message] = 'Expense not updated.'
        redirect_to :action => :index 
      end
    end
  end

  # gives the graphview of the data
  def graphview
    month =  Time.now.month
    year =  Time.now.year
    @month = month
    @year = year
    unless @categories.blank?
    pie_url = ''
    line_url = ''
    if params[:date].blank? && params[:type].blank?
      pie_url = url_for(:action => 'month_pie_data', :format => :json )
      line_url = url_for( :action => 'month_line_data', :format => :json ) 
    elsif params[:date]
      month = params[:date][:month]
      year = params[:date][:year]
      if month.blank? && year
        pie_url = "/expenses/year_pie_data?format=json;year=#{year}"
        line_url = "/expenses/year_line_data?format=json;year=#{year}" 
      else month && year
        pie_url = "/expenses/month_pie_data?format=json;month=#{month};year=#{year}"
        line_url = "/expenses/month_line_data?format=json;month=#{month};year=#{year}" 
      end
    elsif params[:type]
      type = params[:type]
      case type
      when 'month'
        pie_url = url_for(:action => 'month_pie_data', :format => :json )
        line_url = url_for( :action => 'month_line_data', :format => :json ) 
      when 'year'
        pie_url = url_for(:action => 'year_pie_data', :format => :json )
        line_url = url_for( :action => 'year_line_data', :format => :json ) 
      end
    end
    @graph = open_flash_chart_object( 400, 300, pie_url)
    @line_chart = open_flash_chart_object( 550, 300, line_url) 
    end
  end

  def month_pie_data
    if params[:month].blank?
      month = Time.now.month
      year = Time.now.year
    else
      month = params[:month]
      year = params[:year]
    end
    data = Expense.pie_month_data(month,year,@categories,current_user)
    render :json => data, :layout => false
  end

  def month_line_data
    if params[:month].blank?
      month = Time.now.month
      year = Time.now.year
    else
      month = params[:month].to_i
      year = params[:year].to_i
    end
    data = Expense.month_line_graph(month,year,@categories,current_user)
    render :text => data, :layout => false
  end

  def year_line_data
    if params[:year].blank?
      year = Time.now.year
    else
      year = params[:year].to_i
    end
    data = Expense.year_bar_graph(year, @categories,current_user)
    render :text => data, :layout => false
  end

  def year_pie_data
    if params[:year].blank?
      year = Time.now.year
    else
      year = params[:year]
    end
    data = Expense.pie_year_graph(year, @categories,current_user)
    render :text => data, :layout => false
  end


  # DELETE /expenses/1
  # DELETE /expenses/1.xml
  def destroy
    @expense = Expense.find(params[:id])
    exp_date = @expense.exp_date.to_date
    @expense.destroy
    eff_total = Expense.total(exp_date, current_user)

    respond_to do |format|
      format.js { 
          render :json => {:id => params[:id], :dt => exp_date.to_s, :total => eff_total.to_s}
      }
      format.html { redirect_to(expenses_url) }
      format.xml  { head :ok }
    end
  end

  def upload_file
    post = Expense.import_file(params[:upload])
    if post
      respond_to do |format|
        format.js { 
            render :json => {:mess => "File imported successfully"}
        }
      end
    else
      respond_to do |format|
        format.js { 
            render :json => {:mess => "FAILURE"}
        }
      end

    end

  end


end
