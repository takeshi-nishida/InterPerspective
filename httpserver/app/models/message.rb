class Message < ActiveRecord::Base
  belongs_to :participation
  validates :body, :presence => true

  def sender
    participation.user
  end
end
