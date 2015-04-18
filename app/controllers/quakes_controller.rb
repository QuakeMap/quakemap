class QuakesController < ApplicationController
  caches_page :index, if: ->(c) { !c.request.format.json? }

  def index
    @start_time = params[:start_time] || Time.now - 7.days
    @end_time = Time.now
    @mag_floor = params[:min_mag] || 3.0
    @mag_ceil = params[:max_mag] || magnitude_ceiling

    respond_to do |format|
      format.html
      format.rss { @quakes = filtered_quakes }
      format.json { @quakes = filtered_quakes }
    end
  end

  protected

  def magnitude_ceiling
    Quake.between(origin_time: @start_time..@end_time).max(:magnitude)
  end

  def filtered_quakes
    Quake.search(
      start_time: @start_time,
      end_time:   @end_time + 1.day,
      mag_floor:  @mag_floor,
      mag_ceil:   @mag_ceil)
  end
end
