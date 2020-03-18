class TopicsController < ApplicationController
  include PushUtils

  before_filter :require_user, :only => [ :participate ]

  def index
    @topics = Topic.find(:all)
  end

  def show
    @topic = Topic.find(params[:id])
    redirect_to swf_topic_url(@topic)
#    if current_user then
#      redirect_to swf_topic_url(@topic)
##      redirect_to [@topic, current_user.current_room_for(@topic)]
#    else
#      @participation = Participation.new
#    end
  end

  def swf
    @topic = Topic.find(params[:id])
    @flashVars = flash_vars(@topic)
    render :layout => false
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])

    if @topic.save then
      redirect_to @topic
    else
      render :action => 'new'
    end
  end

  ########################################################################
  # GET
  ########################################################################

  def current_room
    @topic = Topic.find(params[:id])
    @room = current_user.current_room_for(@topic)
    if @room then
      @participation = Participation.find_by_room_id_and_user_id(@room.id, current_user.id)
      @attitude = @participation.current_attitude
    end
  end

  def demo_room
    @topic = Topic.find(params[:id])
    @room = @topic.rooms.max_by{|r| rand() }
    @participation = @room.participations.find(:last)
    @attitude = @participation.current_attitude
    render 'current_room'
  end

  def results
    @topic = Topic.find(params[:id])
    @rooms = @topic.rooms.find(:all, :limit => 100)
  end

  def log
    @topic = Topic.find(params[:id])
  end

  ########################################################################
  # POST
  ########################################################################

  def participate
    @topic = Topic.find(params[:id])
    @room = current_user.current_room_for(@topic)

    unless @room then
      push_lines = []

      @topic.transaction do
        @room = @topic.select_room_for(current_user) || @topic.rooms.create
        if @room.users.size < @topic.min_roomsize then
          @room.finish_at = DateTime.current + @topic.roomtime.minutes
          @room.save
          push_lines << "#update_room_finish_time #{@room.id}" unless @room.users.empty?
        end
        @room.users << current_user
      end # end transaction

      @participation = Participation.find_by_room_id_and_user_id(@room.id, current_user.id)
      if @participation then
#        push_lines << process_participate_message(@participation)
#        push_lines << "#update_room_users #{@room.id}"
        push_lines << render_to_string(:partial => 'shared/participation', :locals => { :participation => @participation })
      end
      push_to_room(@room, push_lines)
    end
    
    respond_to do |format|
      format.html { redirect_to [@topic, @room] }
      format.xml { render :action => 'current_room' }
    end
  end


  protected

  def process_participate_message(p)
    message = Message.new do |m|
      m.participation = p
      m.body = "入室"
    end
    message.save
    render_to_string(:partial => 'shared/message', :locals => { :message => message })
  end

  def flash_vars(topic)
    @flashVars = {
      :authenticity_token => form_authenticity_token,
      :root_path => topic_url(topic),
      :title => @topic.title,
      :left => @topic.left,
      :right => @topic.right,
      :user_id => current_user ? current_user.id : -1,
      :host => Config[:public_host],
      :port => Config[:public_port]
    }
  end
end
