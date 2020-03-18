module ApplicationHelper
  def before_after(p)
    before = p.attitudes.first
    after = p.attitudes.last

    if before
      if before != after
        return content_tag(:before, before.title, :position => before.position) + content_tag(:after, after.title, :position => after.position)
      else
        return content_tag(:before, before.title, :position => before.position)
      end
    else
      return ""
    end
  end
  
  def log_message(a)
    return "[入室] #{a.user.login}" if a.is_a?(Participation)
    return "[立ち位置設定] #{a.sender.login} #{a.position} #{a.title}" if a.is_a?(Attitude)
    "[発言] #{a.sender.login} #{a.body}" # if a.is_a?(Message)
  end

  def log_room_user(room, user)
    attitudes = user.attitudes_for(room)
    case attitudes.length
    when 0
      user.login
    when 1
      "#{user.login}: #{attitudes.first.title}"
    else
      "#{user.login}: #{attitudes.first.title} → #{attitudes.last.title}"
    end
  end
end
