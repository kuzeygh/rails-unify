class EventsController < ApplicationController
  before_action :set_event, only:[:show, :edit, :update, :destroy]
  before_action :require_login, only: [:new, :create, :attend]

  def index
    @events = Event.all
    # if params[:event].nil? || params[:event][:category].nil? || params[:event][:category] == ""
    #   @events = Event.all
    # else
    #   @category = params[:event][:category]
    #   @events = Event.where(category: @category)
    # end
  end

  def show
    @alert_message = "You are viewing #{@event.title}"
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to events_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    @event.update(event_params)
    @event.save
    redirect_to events_path
  end

  def destroy
    @event.destroy
    redirect_to events_path
  end

  def attend
    @event = Event.find(params[:event_id])
    @user = current_user

   if Attendance.exists?(user_id: @user.id, event_id: @event.id)
      redirect_to event_path(@event)
      flash[:alert] = "You have already booked"
    else Attendance.create(user_id: @user.id, event_id: @event.id)
    redirect_to event_path(@event)
    flash[:notice] = "You have successfully booked this event"
    end
  end

  def search
    # if there is no search parameter
    if params[:search].nil?
      @events = Event.all
    # or a category or a city
      @category = params[:event][:category]
      @location = params[:event][:location]
      q1 = "%#{@location}%"
      q2 = "%#{@category}%"

      @events = Event.where("location ILIKE ? OR category ILIKE ?", q1, q2)

        # if @location == ""
        #   @events = Event.where(location: @location)
        # else
        #   @events = Event.where(category: @category)
        # end
    end

    render :index
      # if a parameter doesn't correspond to anything - add a note
  end
end


  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :organization, :category, :location, :user_id)
  end

  def require_login
    if !current_user
       flash[:alert] = "You need to sign in to do this action"
      redirect_to new_user_session_path
    end
  end
end
