class Participation < ActiveRecord::Base
  belongs_to :user
  belongs_to :room

  has_many :messages, :order => 'id ASC'
  has_many :attitudes, :order => 'id ASC'

  def current_attitude
    attitudes.last
  end
end
