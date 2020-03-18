class Topic < ActiveRecord::Base
  has_many :rooms

  def active_rooms
    rooms.find(:all, :conditions => ['finish_at > ?', DateTime.current])
  end

  def open_rooms
    active_rooms.find_all { |room| room.open? }
  end

  def user_ids
    rooms.users_ids.inject(Array.new) { |array, ids| array | ids }
  end

  def select_room_for(user)
    # まだ話したことがない相手が一番多い部屋を選ぶ
    known_user_ids = user.known_user_ids(self)
    best_candidate = open_rooms.max_by{|room| (room.user_ids - known_user_ids).size }
    return (best_candidate && (best_candidate.user_ids - known_user_ids).size > 0) ? best_candidate : nil
  end
end
