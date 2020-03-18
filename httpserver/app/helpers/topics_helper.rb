module TopicsHelper
  def embed_flashvars(flashvars)
    @flashVars.collect{|k,v| k.to_s + ": '" + v.to_s + "'" }.join(', ')
  end
end
