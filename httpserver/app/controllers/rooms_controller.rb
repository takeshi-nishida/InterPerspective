class RoomsController < ApplicationController
  include PushUtils

  before_filter :get_topic
  before_filter :require_user, :only => [ :speak, :express_attitude ]
  before_filter :get_room, :except => [ :index ]
  before_filter :get_participation,  :except => [ :speak, :express_attitude ]

  respond_to :html, :js, :xml
  
  def index
    @rooms = @topic.rooms.find(:all)
  end

  def show
#    @message = Message.new(:participation => @participation)
#    @attitude = Attitude.new(:participation => @participation)
  end

  ########################################################################
  # GET
  ########################################################################

  def messages
    @messages = @room.messages
  end

  def users
  end

  def finish_time
  end

  ########################################################################
  # POST
  ########################################################################

  def speak
    if @participation then
      @message = Message.new(params[:message])
      push_message(@room, @message) if @message.save
      respond_with [@topic, @room]
    end
  end

  def express_attitude
    if @participation then
      @attitude = Attitude.new(params[:attitude])
      push_attitude(@room, @attitude) if @attitude.save
      respond_with [@topic, @room]
    end
  end

  private
  def push_attitude(room, a)
#    push_lines = [ "#update_room_users #{room.id}" ]
    push_lines = [ render_to_string(:partial => 'shared/participation', :locals => { :participation => a.participation }) ]
#    message = Message.new do |m|
#      m.participation = a.participation
#      m.body = "立ち位置設定 #{a.position} (#{a.title}) "
#    end
#    push_lines << render_to_string(:partial => 'shared/message', :locals => { :message => message }) if message.save
    push_to_room(room, push_lines)
  end

  def push_message(room, m)
    push_lines = [ render_to_string(:partial => 'shared/message', :locals => { :message => m }) ]
    push_to_room(room, push_lines)
  end

  def get_topic
    @topic = Topic.find(params[:topic_id])
  end

  def get_room
    @room = @topic.rooms.find(params[:id])
  end

  def get_participation
    @participation = Participation.find_by_room_id_and_user_id(@room.id, current_user.id)
  end
end
