class ReportsController < ApplicationController
  def show
    if defined? params[:report_type]
      if params[:start_date] && params[:end_date]
        send(params[:report_type])
      end
      render params[:report_type]  
    else
      # something about error report doesn't exist
    end
  end

  private

  def imprint_count
    @report_data = {
      start_date: params[:start_date], 
      end_date: params[:end_date], 
      machines: {}
    }
    
    if @report_data[:start_date] > @report_data[:end_date]
      @report_data[:start_date] = @report_data[:end_date]
    end

    st = Time.parse(params[:start_date]).to_i
    et = Time.parse(params[:end_date]).to_i
    Machine.all.each do |machine|
      (st..et).step(1.day) do |d|
        date = Time.at(d).strftime('%F')
        count = 0
        machine.imprints.where("scheduled_at LIKE '#{date}%' and completed_at is not null").each do |imprint|
          count = imprint.count + count
        end
        @report_data[:machines][machine.name] = {} if @report_data[:machines][machine.name].nil?
        @report_data[:machines][machine.name][date] = count
      end    
    end
  end
end
