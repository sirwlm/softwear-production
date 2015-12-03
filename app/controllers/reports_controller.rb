class ReportsController < ApplicationController
  before_filter :assign_fluid_container


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

        Imprint.search do
          with(:machine_id, machine.id)
          with(:scheduled_at).greater_than(Time.at(d))
          with(:scheduled_at).less_than(Time.at(d + 1.day))
          with(:complete, true)
        end.results.each do |imprint|
          count = imprint.count + count
        end
        @report_data[:machines][machine.name] = {} if @report_data[:machines][machine.name].nil?
        @report_data[:machines][machine.name][date] = count
      end
    end
  end

  def imprint_times
    machines = Machine.where(id: params[:machine_ids])
    @report_data = {
        start_date: params[:start_date],
        end_date: params[:end_date],
        machines: {},
        imprints: []
    }

    if @report_data[:start_date] > @report_data[:end_date]
      @report_data[:start_date] = @report_data[:end_date]
    end

    st = Time.parse(params[:start_date]).to_i
    et = Time.parse(params[:end_date]).to_i
    machines.each do |machine|
      @report_data[:machines][machine.name] = [] if @report_data[:machines][machine.name].nil?
      Imprint.search do
        with(:machine_id, machine.id)
        with(:scheduled_at).greater_than(Time.at(st))
        with(:scheduled_at).less_than(Time.at(et+1.day))
        with(:complete, true)
        order_by(:scheduled_at, :asc)
      end.results.uniq{|imprint| imprint.imprint_group_or_imprint_id_str }.each do |imprint|
        @report_data[:machines][machine.name] << imprint
      end
    end
  end

end
