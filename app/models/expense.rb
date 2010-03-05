class Expense < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  RANDOM_COLORS = ['#C94E4E','#FFCB3C','#0FE223','#E2DE0F','#3DB3D4','#D43DBB','#DE3E3E']


  def self.get_days_in_month(year,month)
    (Date.new(year,12,31).to_date << (12-month)).day
  end

  # generates the values for a given month in pie chart
  def self.pie_month_data(month,year,categories,current_user)
    cat_values = []
    days = self.get_days_in_month(year.to_i,month.to_i)
    for category in categories do
      cat_values << PieValue.new(category.expenses.find(:all, 
                                                        :conditions => ["exp_date between ? AND  ? and user_id =?","#{year}-#{month}-01".to_datetime,"#{year}-#{month}-#{days}".to_datetime,current_user.id]).collect{ |e| e.amount}.sum,category.name)
    end
    colours = self.colours_data(categories)
    data = self.pie_chart("Expenses based on category for month "+Time.local(year,month,1).strftime("%B"),cat_values,colours)
    return data
  end

  def self.month_line_graph(month,year,categories,current_user) 
    data1 = []
    days = self.get_days_in_month(year,month)
    start_date = "#{year}-#{month}-1"
    end_date = "#{year}-#{month}-#{days}"
    @exps = current_user.expenses.find(:all, :conditions => ["exp_date between ? AND  ? ",start_date.to_datetime,end_date.to_datetime])
    @exps =  @exps.group_by{|d| d.exp_date.strftime('%Y-%m-%d')}
    mean = [] 
    days.times do |i|
      day = i+1
      x = "#{year}-#{month}-#{day}".to_time.to_i
      tot = 0
      expense_for_day = @exps[self.two_digit_date(year,month,day.to_i)]
      if expense_for_day
        expense_for_day.each{ |d| tot+=d.amount}
      else
        tot =0
      end
      y = tot
      mean << tot
      data1 << ScatterValue.new(x,y)
    end

    y = YAxis.new
    avg = (mean.sum/mean.size).ceil
    y.set_range(0,mean.max.ceil+avg,avg)
    return self.line_chart("Everyday expense for the month "+Time.local(2000,month,1).strftime("%B").to_s ,data1,start_date,end_date,y)
  end

  def self.pie_year_graph(year,categories,current_user)
    cat_values = []
    for cat in categories do
     cat_values << PieValue.new(cat.expenses.find(:all,:conditions => ["exp_date between ? AND  ? and user_id=?","#{year}-01-01".to_datetime,"#{year}-12-31".to_datetime,current_user.id]).collect{ |e| e.amount}.sum,cat.name)
    end
    colours = self.colours_data(categories)
    data = self.pie_chart(" Expenses based on category for year "+year.to_s,cat_values,colours)
    return data
  end

  def self.year_bar_graph(year,categories,current_user) 
    data1 = [] 
    months = []
    for i in 1..12 do months << i end
    months.each{ |m|
      days = self.get_days_in_month(year,m)
      start_date = "#{year}-#{m}-1"
      end_date = "#{year}-#{m}-#{days}"
      tot =0
      current_user.expenses.find(:all, :conditions => ["exp_date between ? AND  ? and user_id =?",start_date.to_date,end_date.to_date,current_user.id]).each{ |d| tot+=d.amount }
      data1 << tot 
    }
    return self.bar_chart("Summary of Monthly expenses for the year "+year.to_s,data1)
  end

  def self.split_data(data)
    data =~ /([0-9]+|\.[0-9]*).*,(.*)/
    amount = $1
    description = $2
    description =~ /([0-9]+\/[0-9]+\/[0-9]+)/
    date = $1
    if date
      description =~ /(.*) ([0-9]*\/[0-9]+\/[0-9]+)/
      description = $1
      date = $2
    end
    unless date
      date = DateTime.now
    else
      date = date.to_datetime
    end
    return amount,description,date
  end
  # returns date in 2 digit format. This is useful for getting the data from the hash
  def self.two_digit_date(year,month,day)
      if day < 10
        da = ("%02d"%day)
      else
        da = day
      end
      if month < 10
        mon = ("%02d"% month)
      else 
        mon = month
      end
      return "#{year}-#{mon}-#{da}"
  end

  # Returns the colours of the categories. This colour is used in pie chart
  def self.colours_data(categories)
    colors = []
    for clr in categories do
      # if no colour is set a random colour is picked from the array
      unless clr.colour.blank?
        colors << "#"+clr.colour
      else
        colors << RANDOM_COLORS[rand(6)]
      end
    end
    colors
  end
  
  # To render bar chart
  def self.bar_chart(title,values)
    title = Title.new(title)
    bar = Bar.new
    bar.set_values(values)
    bar.tooltip = "Amount   #val#"
        
    y_axis = YAxis.new
    avg = values.sum/values.size
    y_axis.set_range(0, values.max+avg , avg)

    x = XAxis.new
    #x.set_offset(false)
    x.set_labels(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'])
    
    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.bg_colour = "#ffffff"
    chart.set_x_axis(x)
    chart.y_axis = y_axis
    chart.add_element(bar)
    return chart
  end
  
  # The piechart component that renders sets the values to the flash object
  def self.pie_chart(title,values,colours)
    pie  = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#val# of #total#<br>#percent# of 100%'
    pie.colours = colours
    pie.values = values
    chart = OpenFlashChart.new(title ) do |c|
      c.set_bg_colour('#ffffff')
      c << pie
    end
    return chart
  end


  def self.line_chart(title_text,scatter_value,start_date,end_date,y_range)
    dot = HollowDot.new
    dot.tooltip = "#date:l d M Y#<br>Amount: #val#"
    dot.size = 3
    dot.halo_size = 2

    line = ScatterLine.new("#554138", 2)
    line.values = scatter_value
    line.default_dot_style = dot

    x = XAxis.new
    x.set_range(start_date.to_time.to_i, end_date.to_time.to_i)
    x.steps = 86400

    labels = XAxisLabels.new
    labels.text = "#date:  jS, M Y#"
    labels.steps = 86400
    labels.visible_steps = 2
    labels.rotate = 45

    x.labels = labels
    chart = OpenFlashChart.new
    chart.set_bg_colour('#ffffff')
    title = Title.new(title_text)

    chart.title = title
    chart.add_element(line)
    chart.x_axis = x
    chart.y_axis = y_range
    return chart
  end

  def self.total(exp_date, user)
     total = 0
     self.find(:all, :select => ['amount'], :conditions => ["exp_date like ? AND user_id = ?", "#{exp_date}%", user.id]).each do |exp|
       total += exp.amount
     end
     total
  end 



end
