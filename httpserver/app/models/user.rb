class User < ActiveRecord::Base
  acts_as_authentic

  has_many :participations
  has_many :rooms, :through => :participations, :order => 'id ASC'

  # topic に関する進行中の Room を返す
  def current_room_for(topic)
    rooms.find(:last, :conditions => ['topic_id = ? AND finish_at > ?', topic.id, DateTime.current])
  end

  def attitudes_for(room)
    Participation.find_by_room_id_and_user_id(room.id, id).attitudes
  end

  # トピックについて話したことがある相手のIDを含む配列を返す
  def known_user_ids(topic)
    rooms.find(:all, :conditions => {:topic_id => topic.id}).inject(Array.new){ |a, room| a | room.user_ids }
  end
end
