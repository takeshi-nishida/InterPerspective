require 'test_helper'
require 'rails/performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionDispatch::PerformanceTest
  
  setup :activate_authlogic

  def test_homepage
    nishida1 = login(:nishida1)
    nishida1.participate
  end

  module Behavior
    def participate
      post_via_redirect "/topics/1/participate"
      p path
    end
  end
  
  def login(user)
    open_session do |s|
      u = users(user)
      UserSession.create(u)
      s.extend(Behavior)
    end
  end

end
