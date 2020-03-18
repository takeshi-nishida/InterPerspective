class Attitude < ActiveRecord::Base
  belongs_to :participation

  def sender
    participation.user
  end
end
