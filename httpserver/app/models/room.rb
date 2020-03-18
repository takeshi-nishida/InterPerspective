class Room < ActiveRecord::Base
  belongs_to :topic
  has_many :participations
  has_many :users, :through => :participations
  has_many :messages, :through => :participations, :order => 'id ASC'
  has_many :attitudes, :through => :participations, :order => 'id ASC'

  def valid?
    participations.size > topic.min_roomsize
  end

  def open?
    participations.size < topic.max_roomsize
  end

  def active?
    finish_at < DateTime.now
  end

  def activities
    a = participations + messages + attitudes
    a.sort_by{|v| v.created_at }
  end
end
